mod dbus_player;
mod spotify;

use std::{thread::sleep, time::Duration};
use spotify::Spotify;

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
        let _ign = run_spotify(&mut spot);
        println!("");
        sleep(Duration::from_secs(5));
    }
}
