use anyhow::Error;
use std::path::PathBuf;
use uuid::Uuid;

#[derive(Debug)]
pub enum InputSource {
    YoutubeUrl(String),
    LocalFile(PathBuf),
}

#[derive(Debug, Clone)]
pub enum Language {
    English,
    German,
    Custom(PathBuf),
}

impl Language {
    pub fn to_model_info(&self) -> (&'static str, Option<&'static str>) {
        match self {
            Language::English => ("large-v3-turbo", Some("https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin?download=true")),
            Language::German => ("large-v3-turbo-german", Some("https://huggingface.co/cstr/whisper-large-v3-turbo-german-ggml/resolve/main/ggml-model.bin?download=true")),
            Language::Custom(_) => ("custom", None),
        }
    }

    pub fn lang_code(&self) -> &str {
        match self {
            Language::English => "en",
            Language::German => "de",
            Language::Custom(_) => "en",
        }
    }
}

#[derive(Debug)]
pub enum Phase {
    FetchingAudio,
    Transcoding,
    Transcribing,
    Completed,
    Error(String),
}

#[derive(Debug)]
pub struct TranscriptResult {
    pub transcript: String,
    pub srt: String,
}

#[derive(Debug)]
pub enum AppEvent {
    StatusUpdate(String),
    LogLine(String),
    ProgressPhase(Phase),
    JobFinished(Result<TranscriptResult, Error>),
}

#[derive(Debug)]
pub enum PipelineCommand {
    Start {
        input_source: InputSource,
        language: Language,
        session_id: Uuid,
    },
    Cancel,
}
