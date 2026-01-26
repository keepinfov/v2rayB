use tauri::{webview::WebviewWindowBuilder, WebviewUrl};

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    let port: u16 = 9527;

    tauri::Builder::default()
        .plugin(tauri_plugin_localhost::Builder::new(port).build())
        .setup(move |app| {
            let url = format!("http://localhost:{}", port).parse().unwrap();
            WebviewWindowBuilder::new(app, "main".to_string(), WebviewUrl::External(url))
                .title("v2rayB")
                .inner_size(1200.0, 800.0)
                .build()?;
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
