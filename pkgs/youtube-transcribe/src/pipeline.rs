use crate::types::{AppEvent, InputSource, Language, Phase, PipelineCommand, TranscriptResult};
use anyhow::{bail, Context};
use std::sync::mpsc::Sender;
use std::fs;
use std::io::{BufRead, BufReader};
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use std::sync::{Arc, Mutex};
use uuid::Uuid;

pub struct Pipeline {
    pub sender: Sender<AppEvent>,
    pub session_id: Uuid,
    pub cache_dir: PathBuf,
    pub session_dir: PathBuf,
    pub cancel_flag: Arc<Mutex<bool>>,
}

impl Pipeline {
    pub fn new(
        sender: Sender<AppEvent>,
        session_id: Uuid,
        cache_dir: PathBuf,
        session_dir: PathBuf,
        cancel_flag: Arc<Mutex<bool>>,
    ) -> Self {
        Self {
            sender,
            session_id,
            cache_dir,
            session_dir,
            cancel_flag,
        }
    }

    pub fn run(&mut self, command: PipelineCommand) -> anyhow::Result<()> {
        match command {
            PipelineCommand::Start {
                input_source,
                language,
                session_id,
            } => {
                self.session_id = session_id;
                self.session_dir = self.cache_dir.join("sessions").join(session_id.to_string());
                fs::create_dir_all(&self.session_dir)?;
                self.run_pipeline(input_source, language)?;
            }
            PipelineCommand::Cancel => {
                *self.cancel_flag.lock().unwrap() = true;
                self.sender.send(AppEvent::StatusUpdate("Cancellation requested...".to_string()))?;
            }
        }
        Ok(())
    }

    fn run_pipeline(
        &mut self,
        input_source: InputSource,
        language: Language,
    ) -> anyhow::Result<()> {
        let audio_file_path = self.prepare_audio(&input_source)?;
        let transcoded_audio_path = self.transcode_audio(&audio_file_path)?;
        let whisper_model_path = self.get_or_download_model(language.clone())?;

        let transcript_result = self.transcribe(
            &transcoded_audio_path,
            &whisper_model_path,
            language,
        )?;

        self.sender.send(AppEvent::JobFinished(Ok(transcript_result)))?;

        // Clean up session directory on success
        if let Err(e) = fs::remove_dir_all(&self.session_dir) {
            self.sender.send(AppEvent::LogLine(format!(
                "Warning: Failed to clean up session directory {}: {}",
                self.session_dir.display(),
                e
            )))?;
        }

        Ok(())
    }

    fn prepare_audio(&mut self, input_source: &InputSource) -> anyhow::Result<PathBuf> {
        self.sender.send(AppEvent::ProgressPhase(Phase::FetchingAudio))?;
        self.sender.send(AppEvent::StatusUpdate("Fetching audio...".to_string()))?;

        let (downloaded_path, _original_filename) = match input_source {
            InputSource::YoutubeUrl(url) => {
                let downloaded_path = self.session_dir.join("audio.wav");
                let mut cmd = Command::new("yt-dlp");
                cmd.arg("--format")
                    .arg("18")
                    .arg("--extract-audio")
                    .arg("--audio-format")
                    .arg("wav")
                    .arg("--output")
                    .arg(&downloaded_path)
                    .arg(url);

                let output = cmd.output().context("yt-dlp command failed")?;
                if !output.status.success() {
                    let stderr = String::from_utf8_lossy(&output.stderr);
                    bail!("yt-dlp failed: {}", stderr);
                }

                

                (downloaded_path, "audio".to_string())
            }
            InputSource::LocalFile(path) => {
                let filename = path
                    .file_stem()
                    .unwrap()
                    .to_os_string()
                    .into_string()
                    .unwrap();
                let dest_path = self.session_dir.join(format!("{}.wav", filename));
                fs::copy(path, &dest_path)
                    .context(format!("Failed to copy local file: {}", path.display()))?;
                (dest_path, filename)
            }
        };

        // Log downloaded file info
        self.sender.send(AppEvent::LogLine(format!(
            "Downloaded audio to: {}",
            downloaded_path.display()
        )))?;

        Ok(downloaded_path)
    }

    fn transcode_audio(&mut self, input_path: &Path) -> anyhow::Result<PathBuf> {
        self.sender.send(AppEvent::ProgressPhase(Phase::Transcoding))?;
        self.sender.send(AppEvent::StatusUpdate("Transcoding audio...".to_string()))?;

        let output_filename = format!(
            "{}-16khz.wav",
            input_path
                .file_stem()
                .unwrap()
                .to_os_string()
                .into_string()
                .unwrap()
        );
        let output_path = self.session_dir.join(output_filename);

        let mut cmd = Command::new("ffmpeg");
        cmd.arg("-loglevel")
            .arg("warning")
            .arg("-i")
            .arg(input_path)
            .arg("-vn") // No video
            .arg("-acodec")
            .arg("pcm_s16le") // PCM signed 16-bit little-endian
            .arg("-ar")
            .arg("16000") // Sample rate 16kHz
            .arg("-ac")
            .arg("1") // Mono channel
            .arg("-f")
            .arg("wav")
            .arg(&output_path);

        let mut child = cmd.spawn().context("ffmpeg command failed to spawn")?;
        let status = child.wait().context("ffmpeg command failed to wait")?;

        if !status.success() {
            bail!("ffmpeg failed with status: {}", status);
        }

        self.sender.send(AppEvent::LogLine(format!(
            "Transcoded audio to: {}",
            output_path.display()
        )))?;

        Ok(output_path)
    }

    fn get_or_download_model(&mut self, language: Language) -> anyhow::Result<PathBuf> {
        self.sender.send(AppEvent::ProgressPhase(Phase::Transcribing))?;
        self.sender.send(AppEvent::StatusUpdate("Checking for Whisper model...".to_string()))?;

        if let Language::Custom(ref path) = language {
            if path.exists() {
                self.sender.send(AppEvent::LogLine(format!("Using custom model: {}", path.display())))?;
                return Ok(path.clone());
            } else {
                bail!("Custom model path does not exist: {}", path.display());
            }
        }

        let (model_name, model_url_opt) = language.to_model_info();
        let model_filename = format!("ggml-{}.bin", model_name);
        let model_path = self.cache_dir.join("models").join(&model_filename);

        if model_path.exists() {
            self.sender.send(AppEvent::LogLine(format!("Using cached model: {}", model_path.display())))?;
            return Ok(model_path);
        }

        let url = model_url_opt.context("No URL available for model")?;
        self.sender.send(AppEvent::StatusUpdate(format!("Downloading model: {}...", model_name)))?;

        // Ensure the model directory exists
        fs::create_dir_all(model_path.parent().unwrap())?;

        let mut cmd = Command::new("curl");
        cmd.arg("-L")
            .arg("-o")
            .arg(&model_path)
            .arg(url);

        // Redirect stdout and stderr to capture logs
        cmd.stdout(Stdio::piped());
        cmd.stderr(Stdio::piped());

        let mut child = cmd.spawn().context("curl command failed to spawn")?;

        let stdout_pipe = child.stdout.take().unwrap();
        let stderr_pipe = child.stderr.take().unwrap();

        let stdout_reader = BufReader::new(stdout_pipe);
        let stderr_reader = BufReader::new(stderr_pipe);

        // Process stdout and stderr in separate threads to avoid deadlocks
        let sender_clone = self.sender.clone();
        let log_handle = std::thread::spawn(move || {
            for line in stdout_reader.lines() {
                if let Ok(line) = line {
                    if !line.trim().is_empty() {
                        sender_clone.send(AppEvent::LogLine(format!("[download] {}", line))).unwrap();
                    }
                }
            }
        });

        let sender_clone = self.sender.clone();
        let error_handle = std::thread::spawn(move || {
            for line in stderr_reader.lines() {
                if let Ok(line) = line {
                    if !line.trim().is_empty() {
                        sender_clone.send(AppEvent::LogLine(format!("[download-err] {}", line))).unwrap();
                    }
                }
            }
        });

        let status = child.wait().context("curl command failed to wait")?;

        log_handle.join().unwrap();
        error_handle.join().unwrap();

        if !status.success() {
            bail!("curl failed with status: {}", status);
        }

        // Verify the model file exists after download
        if !model_path.exists() {
            bail!("Model file {} not found after download.", model_path.display());
        }

        self.sender.send(AppEvent::LogLine(format!("Model downloaded to: {}", model_path.display())))?;
        Ok(model_path)
    }

    fn transcribe(
        &mut self,
        audio_path: &Path,
        model_path: &Path,
        language: Language,
    ) -> anyhow::Result<TranscriptResult> {
        self.sender.send(AppEvent::StatusUpdate("Transcribing...".to_string()))?;

        let mut cmd = Command::new("whisper-cli");
        cmd.arg("--file")
            .arg(audio_path)
            .arg("--output-file")
            .arg(self.session_dir.join("transcript")) // Base name for output files
            .arg("--language")
            .arg(language.lang_code())
            .arg("--model")
            .arg(model_path)
            .arg("--output-txt")
            .arg("--output-srt");

        // Redirect stdout and stderr to capture logs
        cmd.stdout(Stdio::piped());
        cmd.stderr(Stdio::piped());

        let mut child = cmd.spawn().context("whisper-cpp command failed to spawn")?;

        let stdout_pipe = child.stdout.take().unwrap();
        let stderr_pipe = child.stderr.take().unwrap();

        let stdout_reader = BufReader::new(stdout_pipe);
        let stderr_reader = BufReader::new(stderr_pipe);

        // Process stdout and stderr in separate threads to avoid deadlocks
        let sender_clone = self.sender.clone();
        let log_handle = std::thread::spawn(move || {
            for line in stdout_reader.lines() {
                if let Ok(line) = line {
                    if !line.trim().is_empty() {
                        sender_clone.send(AppEvent::LogLine(line)).unwrap();
                    }
                }
            }
        });

        let sender_clone = self.sender.clone();
        let error_handle = std::thread::spawn(move || {
            for line in stderr_reader.lines() {
                if let Ok(line) = line {
                    if !line.trim().is_empty() {
                        sender_clone.send(AppEvent::LogLine(format!("[whisper-err] {}", line))).unwrap();
                    }
                }
            }
        });

        let status = child.wait().context("whisper-cpp command failed to wait")?;

        log_handle.join().unwrap();
        error_handle.join().unwrap();

        if !status.success() {
            bail!("whisper-cpp failed with status: {}", status);
        }

        // Read the generated transcript and SRT files
        let transcript_path = self.session_dir.join("transcript.txt");
        let srt_path = self.session_dir.join("transcript.srt");

        let transcript = fs::read_to_string(&transcript_path)
            .context(format!("Failed to read transcript file: {}", transcript_path.display()))?;
        let srt = fs::read_to_string(&srt_path)
            .context(format!("Failed to read SRT file: {}", srt_path.display()))?;

        Ok(TranscriptResult { transcript, srt })
    }
}
