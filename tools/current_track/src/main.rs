mod dbus_player;
mod spotify;
mod mpd;

use mpd::Mpd;
use spotify::Spotify;

use std::time::Duration;
use std::thread::sleep;

fn run_mpd() -> Option<()> {
    let mut mpd = Mpd::new()?;

    let track = mpd.get_current_track()?;
    println!("{}", track);

    loop {
        let track = mpd.wait_for_next_song()?;
        println!("{}", track);
    }
}

fn run_spotify(spot: &mut Spotify) -> Option<()> {
    loop {
        let track = spot.drain_and_get_track()?;
        println!("{}", track);
        let track = spot.process_and_get_track()?;
        println!("{}", track);
    }
}

fn main() {
    let mut spot = Spotify::new().unwrap();
    loop {
        let _ign = run_mpd();
        println!("");
        let _ign = run_spotify(&mut spot);
        println!("");
        sleep(Duration::from_secs(5));
    }
}
