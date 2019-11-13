use mpd_client::idle::*;
use mpd_client::Client;

fn handle_error<T>(err: &mpd_client::error::Error) -> Option<T> {
    eprintln!("Cannot connect to MPD: {:?}", err);
    None
}

fn format_song(song: &Option<mpd_client::Song>) -> String {
    song.as_ref()
        .map(|s| {
            let t = s.title.as_ref().map_or("?", String::as_str);
            let a = s.tags.get("Artist").map_or("?", String::as_str);
            format!("{} - {}", a, t)
        })
        .unwrap_or("MPD: Not playing".to_string())
}

pub struct Mpd {
    connection: Client,
}

impl Mpd {
    pub fn new() -> Option<Self> {
        let conn = Client::connect("127.0.0.1:6600");
        match conn {
            Ok(client) => Some(Mpd { connection: client }),
            Err(err) => handle_error(&err),
        }
    }

    pub fn get_current_track(&mut self) -> Option<String> {
        let song = self.connection.currentsong();
        match song {
            Ok(song) => Some(format_song(&song)),
            Err(err) => handle_error(&err),
        }
    }

    pub fn wait_for_next_song(&mut self) -> Option<String> {
        let res = self.wait_for_queue_item();
        match res {
            Ok(_) => self.get_current_track(),
            Err(err) => handle_error(&err),
        }
    }

    fn wait_for_queue_item(&mut self) -> mpd_client::error::Result<()> {
        let idle = self.connection.idle(&[Subsystem::Player])?;
        let _subs = idle.get()?;
        Ok(())
    }
}

impl Drop for Mpd {
    fn drop(&mut self) {
        let _res = self.connection.close().as_ref().map_err(handle_error::<()>);
    }
}
