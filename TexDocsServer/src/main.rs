extern crate mio;
#[macro_use] extern crate log;
extern crate env_logger;

// extern crate concurrent_hashmap;
// extern crate uuid;
// extern crate serde;
// extern crate serde_json;
//
// #[macro_use]
// extern crate serde_derive;
//
// use serde_json::{Value, Error};
//
// use std::net::{TcpListener, TcpStream};
// use std::io::{Read, Write};
//
// use std::thread;
// use std::sync::Arc;
//
// use uuid::Uuid;
//
// use concurrent_hashmap::*;
//
// struct TexDocsServer {
//     clients: Arc<ConcHashMap<Uuid, TcpStream>>
// }
//
// impl TexDocsServer {
//     fn create_server() -> TexDocsServer {
//         TexDocsServer {
//             clients: Arc::new(ConcHashMap::<Uuid, TcpStream>::new())
//         }
//     }
//
//     fn listen(&mut self) {
//         let socket = TcpListener::bind("127.0.0.1:8080").unwrap();
//         let clients = self.clients.clone();
//         let t1 = thread::spawn(move || {
//             loop {
//                 match socket.accept() {
//                     Ok((mut _socket, addr)) => {
//                         let user_id = Uuid::new_v4();
//                         println!("new client: {:?} -> {:?}", addr, user_id);
//                         _socket.write((user_id.hyphenated().to_string() + "\n").as_bytes()).unwrap();
//                         clients.insert(user_id, _socket);
//                     },
//                     Err(e) => println!("couldn't get client: {:?}", e),
//                 }
//             }
//         });
//
//         t1.join().unwrap();
//     }
// }
//
// fn main() {
//     println!("Hello, world!");
//
//     let mut server = TexDocsServer::create_server();
//
//     server.listen();
// }

use std::net::SocketAddr;
use std::str::FromStr;

use mio::*;
use mio::tcp::*;

mod server;
use server::Server;

fn main() {
    // Before doing anything, let us register a logger. The mio library has really good logging
    // at the _trace_ and _debug_ levels. Having a logger setup is invaluable when trying to
    // figure out why something is not working correctly.
    env_logger::init().ok().expect("Failed to init logger");

    let addr: SocketAddr = FromStr::from_str("127.0.0.1:8000")
        .ok().expect("Failed to parse host:port string");
    let sock = TcpListener::bind(&addr).ok().expect("Failed to bind address");

    let mut event_loop = EventLoop::new().ok().expect("Failed to create event loop");

    // Create our Server object and register that with the event loop. I am hiding away
    // the details of how registering works inside of the `Server#register` function. One reason I
    // really like this is to get around having to have `const SERVER = Token(0)` at the top of my
    // file. It also keeps our polling options inside `Server`.
    let mut server = Server::new(sock);
    server.register(&mut event_loop).ok().expect("Failed to register server with event loop");

    info!("Even loop starting...");
    event_loop.run(&mut server).ok().expect("Failed to start event loop");
}
