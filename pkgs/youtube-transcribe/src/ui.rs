use gio::ListStore;
use gtk4::prelude::*;
use libadwaita::Application as AdwApplication;
use gtk4::{
    Align, Box, Button, DropDown, Entry, Label, Orientation, ScrolledWindow, TextView,
    WrapMode, StringObject, StringList
};
use std::path::PathBuf;
use std::sync::{Arc, Mutex};
use uuid::Uuid;
// Removed unused import, as it was not needed

#[derive(Debug, Clone)]
pub enum InputSource {
    YoutubeUrl(String),
    LocalFile(PathBuf),
}

#[derive(Debug)]
pub enum Language {
    English,
    German,
}

impl Language {
    pub fn to_model_name(&self) -> &'static str {
        match self {
            Language::English => "ggml-small.en",
            Language::German => "ggml-medium",
        }
    }
}

#[derive(Clone)]
pub struct AppWindow {
    pub window: libadwaita::ApplicationWindow, // Reverted to libadwaita::ApplicationWindow for type
    pub url_entry: Entry,
    pub file_chooser_button: Button,
    pub language_dropdown: DropDown,
    pub start_button: Button,
    pub cancel_button: Button,
    pub save_button: Button,
    pub reset_button: Button,
    pub status_label: Label,
    pub transcript_view: TextView,
    pub session_id: Uuid,
    pub selected_file_path: Arc<Mutex<Option<PathBuf>>>,
    pub transcript_content: Arc<Mutex<Option<String>>>,
}

impl AppWindow {
    pub fn new(app: &AdwApplication) -> Self {
        let session_id = Uuid::new_v4();

        // Input selection widgets
        let url_entry = Entry::builder()
            .placeholder_text("Enter YouTube URL...")
            .margin_top(12)
            .margin_bottom(12)
            .margin_start(12)
            .margin_end(12)
            .build();

        let file_chooser_button = Button::builder()
            .label("Choose Audio File...")
            .margin_top(12)
            .margin_bottom(12)
            .margin_start(12)
            .margin_end(12)
            .build();

        // Language selection
        let languages: Vec<(&'static str, Language)> = vec![
            ("English", Language::English),
            ("German", Language::German),
        ];


        let language_strings = languages.iter().map(|language| language.0).collect::<Vec<&str>>();
        let language_list_model = StringList::new(&language_strings);

        let language_dropdown = DropDown::builder()
            .model(&language_list_model)
            .selected(0) // Default to English
            .margin_top(12)
            .margin_bottom(12)
            .margin_start(12)
            .margin_end(12)
            .build();

        // Status and transcript widgets
        let status_label = Label::builder()
            .label("Ready")
            .margin_top(12)
            .margin_bottom(12)
            .margin_start(12)
            .margin_end(12)
            .build();

        let transcript_view = TextView::builder()
            .editable(false)
            .cursor_visible(false)
            .wrap_mode(WrapMode::WordChar)
            .margin_top(12)
            .margin_bottom(12)
            .margin_start(12)
            .margin_end(12)
            .build();

        let scrolled_window = ScrolledWindow::builder()
            .child(&transcript_view)
            .vexpand(true)
            .build();

        // Action buttons
        let start_button = Button::builder()
            .label("Start Transcription")
            .margin_top(12)
            .margin_bottom(12)
            .margin_start(12)
            .margin_end(12)
            .sensitive(false) // Disabled initially
            .build();

        let cancel_button = Button::builder()
            .label("Cancel")
            .margin_top(12)
            .margin_bottom(12)
            .margin_start(12)
            .margin_end(12)
            .sensitive(false) // Disabled initially
            .build();

        // Save Transcript button
        let save_button = Button::builder()
            .label("Save Transcript...")
            .margin_top(12)
            .margin_bottom(12)
            .margin_start(12)
            .margin_end(12)
            .sensitive(false) // Disabled initially
            .build();

        // Reset button
        let reset_button = Button::builder()
            .label("Reset")
            .margin_top(12)
            .margin_bottom(12)
            .margin_start(12)
            .margin_end(12)
            .build();

        // Main layout
        let vbox = Box::builder()
            .orientation(Orientation::Vertical)
            .margin_top(12)
            .margin_bottom(12)
            .margin_start(12)
            .margin_end(12)
            .build();

        // Input selection stack
        let input_stack = Box::builder()
            .orientation(Orientation::Vertical)
            .build();
        input_stack.append(&url_entry);
        input_stack.append(&file_chooser_button);

        // Add widgets to vbox
        vbox.append(&input_stack);
        vbox.append(&language_dropdown);
        vbox.append(&status_label);
        vbox.append(&scrolled_window);

        let button_box = Box::builder()
            .orientation(Orientation::Horizontal)
            .halign(Align::Center)
            .build();
        button_box.append(&start_button);
        button_box.append(&cancel_button);
        button_box.append(&save_button);
        button_box.append(&reset_button);
        vbox.append(&button_box);

        let window = libadwaita::ApplicationWindow::builder()
            .application(app)
            .title("YouTube Transcriber")
            .default_width(600)
            .default_height(700)
            .content(&vbox)
            .build();

        Self {
            window,
            url_entry,
            file_chooser_button,
            language_dropdown,
            start_button,
            cancel_button,
            save_button,
            reset_button,
            status_label,
            transcript_view,
            session_id,
            selected_file_path: Arc::new(Mutex::new(None)),
            transcript_content: Arc::new(Mutex::new(None)),
        }
    }

    }
