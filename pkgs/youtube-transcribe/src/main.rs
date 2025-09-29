use adw::prelude::*;
use anyhow::Context;
use libadwaita as adw;

mod app;
mod pipeline;
mod types;
mod ui;

fn main() {
    if let Err(error) = launch() {
        eprintln!("youtube-transcribe failed: {error:?}");
        std::process::exit(1);
    }
}

fn launch() -> anyhow::Result<()> {
    adw::init().context("failed to initialize libadwaita")?;

    let app = adw::Application::builder()
        .application_id("de.youtube_transcribe.GtkApp")
        .build();

    app.connect_activate(|application| {
        app::build_ui(application);
    });

    app.run();

    Ok(())
}