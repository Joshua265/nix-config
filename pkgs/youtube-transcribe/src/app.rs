use crate::pipeline::Pipeline;
use crate::types::{AppEvent, InputSource, Language, PipelineCommand};
use crate::ui::AppWindow;

use libadwaita::Application as AdwApplication;
use std::io::Write;
use std::sync::mpsc::{Receiver, Sender};
use gtk4::prelude::*;
use gtk4::FileDialog;
use std::path::PathBuf;
use std::sync::{Arc, Mutex};
use std::fs::File;
use uuid::Uuid;
use gio::Cancellable;

pub struct App {
    pub window: AppWindow,
    pub pipeline_sender: Sender<PipelineCommand>,
    pub pipeline_receiver: Arc<Mutex<Receiver<AppEvent>>>,
}

impl App {
    pub fn new(
        window: AppWindow,
        pipeline_sender: Sender<PipelineCommand>,
        pipeline_receiver: Arc<Mutex<Receiver<AppEvent>>>,
    ) -> Self {
        let app = Self {
            window,
            pipeline_sender,
            pipeline_receiver,
        };

        app.setup_connections();
        app.setup_pipeline_receiver();

        app
    }

    fn setup_connections(&self) {
        // Start button
        let window = self.window.clone();
        let pipeline_sender = self.pipeline_sender.clone();
        self.window.start_button.connect_clicked(move |_| {
            window.start_button.set_sensitive(false);
            window.cancel_button.set_sensitive(true);
            window.status_label.set_text("Starting...");
            let buffer = window.transcript_view.buffer();
            buffer.set_text("");

            let url_text = window.url_entry.text().to_string();
            let input_source = if url_text.is_empty() {
                if let Some(file_path) = window.selected_file_path.lock().unwrap().clone() {
                    InputSource::LocalFile(file_path)
                } else {
                    InputSource::YoutubeUrl("".to_string())
                }
            } else {
                InputSource::YoutubeUrl(url_text)
            };

            let selected = window.language_dropdown.selected();
            let language = match selected {
                0 => Language::English,
                1 => Language::German,
                _ => Language::English,
            };

            let session_id = window.session_id;

            let command = PipelineCommand::Start {
                input_source,
                language,
                session_id,
            };

            if pipeline_sender.send(command).is_err() {
                window.status_label.set_text("Error: Pipeline not running.");
            }
        });
        // URL entry changed handler
        let window = self.window.clone();
        let selected_file_path = Arc::clone(&self.window.selected_file_path);
        self.window.url_entry.connect_changed(move |_| {
            let has_url = !window.url_entry.text().is_empty();
            let has_file = selected_file_path.lock().unwrap().is_some();
            window.start_button.set_sensitive(has_url || has_file);
        });


        // File chooser button -> FileDialog::open (callback API)
                let window = self.window.clone();
        let selected_file_path = Arc::clone(&window.selected_file_path);
        self.window.file_chooser_button.connect_clicked(move |_| {
            let dialog = FileDialog::builder()
                .title("Choose Audio File")
                .build();

            // Pre-clone handles for the callback
            let win_for_cb = window.clone();
            let sel_for_cb = Arc::clone(&selected_file_path);

            dialog.open(
                Some(&window.window),
                None::<&Cancellable>,
                move |res| {
                    match res {
                        Ok(file) => {
                            if let Some(file_path) = file.path() {
                                win_for_cb.url_entry.set_text("");
                                win_for_cb.url_entry.set_sensitive(false);
                                win_for_cb
                                    .file_chooser_button
                                    .set_label(&file_path.display().to_string());
                                *sel_for_cb.lock().unwrap() = Some(file_path);
                                win_for_cb.start_button.set_sensitive(true);
                            }
                        }
                        Err(err) => {
                            win_for_cb.status_label.set_text(&format!("Open failed: {err}"));
                        }
                    }
                },
            );
        });

        // Cancel button
        let window = self.window.clone();
        let pipeline_sender = self.pipeline_sender.clone();
        self.window.cancel_button.connect_clicked(move |_| {
            if pipeline_sender.send(PipelineCommand::Cancel).is_err() {
                window.status_label.set_text("Error: Failed to send cancel command.");
            }
        });

    // Save button -> FileDialog::save (callback API)
let window = self.window.clone();
self.window.save_button.connect_clicked(move |_| {
    if let Some(transcript) = window
        .transcript_content
        .lock()
        .unwrap()
        .as_ref()
        .map(|s| s.clone())
    {
        let dialog = FileDialog::builder().title("Save Transcript").build();
        dialog.set_initial_name(Some("transcript.txt"));

        let transcript_text = transcript.clone();
        let win_for_cb = window.clone();

        dialog.save(
            Some(&window.window),
            None::<&Cancellable>,
            move |res| {
                match res {
                    Ok(file) => {
                        if let Some(path) = file.path() {
                            match File::create(&path) {
                                Ok(mut out) => {
                                    if let Err(e) = out.write_all(transcript_text.as_bytes()) {
                                        win_for_cb.status_label.set_text(&format!("Error saving file: {e}"));
                                    } else {
                                        win_for_cb.status_label.set_text("Transcript saved successfully.");
                                    }
                                }
                                Err(e) => {
                                    win_for_cb.status_label.set_text(&format!("Error creating file: {e}"));
                                }
                            }
                        } else {
                            win_for_cb.status_label.set_text("Invalid file path.");
                        }
                    }
                    Err(err) => {
                        win_for_cb.status_label.set_text(&format!("Save failed: {err}"));
                    }
                }
            },
        );
    } else {
        window.status_label.set_text("No transcript available to save.");
    }
});

        // Reset button
        let window = self.window.clone();
        self.window.reset_button.connect_clicked(move |_| {
            window.url_entry.set_text("");
            window.url_entry.set_sensitive(true);
            window.file_chooser_button.set_label("Choose Audio File...");
            *window.selected_file_path.lock().unwrap() = None;
            window.transcript_view.buffer().set_text("");
            *window.transcript_content.lock().unwrap() = None;
            window.status_label.set_text("Ready");
            let has_url = !window.url_entry.text().is_empty();
            let has_file = window.selected_file_path.lock().unwrap().is_some();
            window.start_button.set_sensitive(has_url || has_file);
            window.cancel_button.set_sensitive(false);
            window.save_button.set_sensitive(false);
        });

    }

    fn setup_pipeline_receiver(&self) {
        let receiver: Arc<Mutex<Receiver<AppEvent>>> = Arc::clone(&self.pipeline_receiver);

        // Cloned references for the closure
        let status_label = self.window.status_label.clone();
        let transcript_view = self.window.transcript_view.clone();
        let start_button = self.window.start_button.clone();
        let cancel_button = self.window.cancel_button.clone();
        let save_button = self.window.save_button.clone();
        let transcript_content = Arc::clone(&self.window.transcript_content);

        // Poll events without blocking main thread
        glib::timeout_add_local(std::time::Duration::from_secs(1), move || {
            let  receiver = receiver.lock().unwrap();

            if let Ok(event) = receiver.try_recv() {
                match event {
                    AppEvent::StatusUpdate(status) => {
                        status_label.set_text(&status);
                    }
                    AppEvent::LogLine(log) => {
                        let buffer = transcript_view.buffer();
                        buffer.insert_at_cursor(&format!("{}\n", log));
                        // Auto-scroll to the end
                        let mut end_iter = buffer.end_iter();
                        transcript_view.scroll_to_iter(&mut end_iter, 0.0, true, 0.0, 0.0);
                    }
                    AppEvent::ProgressPhase(phase) => {
                        status_label.set_text(&format!("Phase: {:?}", phase));
                    }
                    AppEvent::JobFinished(result) => {
                        match result {
                            Ok(transcript_result) => {
                                status_label.set_text("Transcription Complete!");
                                // Display transcript
                                let buffer = transcript_view.buffer();
                                buffer.set_text(&transcript_result.transcript);
                                save_button.set_sensitive(true);
                                // Store transcript for saving
                                *transcript_content.lock().unwrap() = Some(transcript_result.transcript);
                            }
                            Err(e) => {
                                status_label.set_text(&format!("Error: {}", e));
                                let buffer = transcript_view.buffer();
                                buffer.insert_at_cursor(&format!("Error: {}\n", e));
                            }
                        }
                        // Re-enable UI controls
                        start_button.set_sensitive(true);
                        cancel_button.set_sensitive(false);
                    }
                }
            }
            glib::ControlFlow::Continue
        });
    }
}

pub fn build_ui(app: &AdwApplication) {
    let (command_sender, command_receiver) = std::sync::mpsc::channel::<PipelineCommand>();
    let (event_sender, event_receiver) = std::sync::mpsc::channel::<AppEvent>();
    let pipeline_receiver = Arc::new(Mutex::new(event_receiver));

    // Get cache directory
    let cache_dir = directories::ProjectDirs::from("com", "youtube-transcribe", "youtube-transcribe")
        .map(|p| p.cache_dir().to_path_buf())
        .unwrap_or_else(|| {
            let mut fallback_path = PathBuf::new();
            fallback_path.push(std::env::var("HOME").unwrap_or_else(|_| "/tmp".to_string()));
            fallback_path.push(".cache");
            fallback_path.push("youtube-transcribe");
            fallback_path
        });

    let session_id = Uuid::new_v4();
    let session_dir = cache_dir.join("sessions").join(session_id.to_string());
    let cancel_flag = Arc::new(Mutex::new(false));

    // Create the main window
    let window = AppWindow::new(app);

    // Create the pipeline
    let mut pipeline = Pipeline::new(
        event_sender,
        session_id,
        cache_dir,
        session_dir,
        cancel_flag.clone(),
    );

    // Spawn the pipeline in a separate thread
    std::thread::spawn(move || {
        loop {
            match command_receiver.recv() {
                Ok(command) => {
                    if let Err(e) = pipeline.run(command) {
                        let _ = pipeline.sender.send(AppEvent::JobFinished(Err(e)));
                    }
                }
                Err(_) => {
                    break;
                }
            }
        }
    });

    // Create the App struct (connections set up in App::new)
    let app_instance = App::new(window, command_sender, pipeline_receiver);

    // Show the window
    app_instance.window.window.present();
}
