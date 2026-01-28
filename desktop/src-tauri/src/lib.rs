use std::env;
use tauri::{webview::WebviewWindowBuilder, WebviewUrl};

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    let port = env::var("V2RAYB_PORT").unwrap_or_else(|_| "50541".to_string());
    let url = format!("http://localhost:{}", port);

    tauri::Builder::default()
        .setup(move |app| {
            WebviewWindowBuilder::new(app, "main", WebviewUrl::External(url.parse().unwrap()))
                .title("v2rayB")
                .inner_size(1200.0, 800.0)
                .build()?;
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
