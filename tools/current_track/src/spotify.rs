extern crate dbus;
extern crate itertools;

use std::cell::RefCell;
use std::collections::HashMap;
use std::iter::FromIterator;
use std::rc::Rc;
use std::result::Result;
use std::time::Duration;

use dbus::{arg, arg::RefArg, blocking::Connection, blocking::Proxy};

use itertools::Itertools;

use crate::dbus_player::*;

type Variant = arg::Variant<Box<dyn arg::RefArg>>;
type Metadata = HashMap<String, Box<dyn arg::RefArg>>;

static SPOTIFY_DESTINATION: &'static str = "org.mpris.MediaPlayer2.spotify";
static DBUS_PATH: &'static str = "/org/mpris/MediaPlayer2";

static NORMAL_DELAY: Duration = Duration::from_secs(5);

fn handle_error<T>(err: &dbus::Error) -> Option<T> {
    eprintln!("Cannot connect to Spotify: {:?}", err);
    None
}

fn refarg_to_str(v: &dyn arg::RefArg) -> &str {
    if let Some(s) = v.as_str() {
        s
    } else if let Some(mut a) = v.as_iter() {
        if let Some(i) = a.next() {
            refarg_to_str(i)
        } else {
            "?"
        }
    } else {
        "?"
    }
}

fn opt_refarg_to_str(value: Option<&Box<dyn arg::RefArg>>) -> &str {
    if let Some(v) = value {
        refarg_to_str(v)
    } else {
        "?"
    }
}

fn as_metadata(src: &Variant) -> Option<Metadata> {
    if let Some(iter) = src.0.as_iter() {
        let t = iter
            .tuples()
            .map(|t: (&dyn arg::RefArg, &dyn arg::RefArg)| {
                (t.0.as_str().unwrap().to_string(), t.1.box_clone())
            });
        Some(Metadata::from_iter(t))
    } else {
        None
    }
}

fn format_song(meta: &Option<Metadata>) -> String {
    meta.as_ref().map(|m| {
        let artist = opt_refarg_to_str(m.get("xesam:artist"));
        let title = opt_refarg_to_str(m.get("xesam:title"));
        format!("{} - {}", artist, title)
    })
    .unwrap_or("Spotify: Not playing".to_string())
}

fn with_proxy<'a, 'b, F, R>(conn: &'a mut Connection, fun: F) -> R
where
    F: Fn(Proxy<'b, &'a Connection>) -> R,
{
    let p = conn.with_proxy(SPOTIFY_DESTINATION, DBUS_PATH, Duration::from_millis(10000));
    fun(p)
}

fn attach_signal(
    conn: &mut Connection,
    current_track: Rc<RefCell<Option<String>>>,
) -> Result<u32, dbus::Error> {
    let id = with_proxy(conn, move |p| {
        let current_track = Rc::clone(&current_track);
        p.match_signal(
            move |h: OrgFreedesktopDBusPropertiesPropertiesChanged, _: &Connection| {
                let meta = h
                    .changed_properties
                    .get("Metadata")
                    .map(as_metadata)
                    .flatten();
                let track = format_song(&meta);
                current_track.borrow_mut().replace(track);
                true
            },
        )
    })?;
    Ok(id)
}

fn get_first_track(conn: &mut Connection) -> Option<String> {
    with_proxy(conn, |p| match p.get_metadata() {
        Ok(meta) => {
            let meta = meta.iter().map(|(k, v)| (k.to_string(), v.0.box_clone()));
            let meta = Metadata::from_iter(meta);
            Some(format_song(&Some(meta)))
        }
        Err(err) => handle_error(&err),
    })
}

pub struct Spotify {
    connection: Connection,
    match_id: u32,
    current_track: Rc<RefCell<Option<String>>>,
}

impl Spotify {
    fn prepare_connection() -> Result<Self, dbus::Error> {
        let mut conn = Connection::new_session()?;
        let current_track = Rc::new(RefCell::new(get_first_track(&mut conn)));
        let match_id = attach_signal(&mut conn, Rc::clone(&current_track))?;

        Ok(Spotify {
            connection: conn,
            match_id: match_id,
            current_track: current_track,
        })
    }

    pub fn new() -> Option<Self> {
        match Spotify::prepare_connection() {
            Ok(c) => Some(c),
            Err(err) => handle_error(&err),
        }
    }

    pub fn drain_and_get_track(&mut self) -> Option<String> {
        if !self.is_running() {
            None
        } else {
            self.drain()?;
            self.get_last_track()
        }
    }

    pub fn process_and_get_track(&mut self) -> Option<String> {
        let res = self.connection.process(NORMAL_DELAY);
        match res {
            Ok(_) => self.get_last_track(),
            Err(err) => handle_error(&err),
        }
    }

    fn is_running(&mut self) -> bool {
        with_proxy(&mut self.connection, |p| p.ping())
            .as_ref()
            .map_err(handle_error::<()>)
            .is_ok()
    }

    fn drain(&mut self) -> Option<()> {
        match self.connection.process(Duration::from_millis(100)) {
            Ok(true) => self.drain(),
            Ok(false) => Some(()),
            Err(err) => handle_error(&err),
        }
    }

    fn get_last_track(&mut self) -> Option<String> {
        if self.is_running() {
            self.current_track.borrow().as_ref().map(|t| t.to_string())
        } else {
            None
        }
    }
}

impl Drop for Spotify {
    fn drop(&mut self) {
        let player = self.connection.with_proxy(
            SPOTIFY_DESTINATION,
            DBUS_PATH,
            Duration::from_millis(10000),
        );
        player.match_stop(self.match_id, true).unwrap();
    }
}
