use std::future;
use std::future::IntoFuture;

use crate::messages;
use crate::tokio;
use process_stream::{Process, ProcessExt, StreamExt};
use rinf::debug_print;
use tokio::sync::Mutex;
static EXECUTEABLE: &str = "/home/zfn/repos/my/arp-attacker/target/debug/arp-attacker";

pub async fn list_interfaces() {
    use messages::arp_interface::*;
    let mut receiver = InterfaceReq::get_dart_signal_receiver();
    while let Some(dart_signal) = receiver.recv().await {
        let req = dart_signal.message;
        let mut arp_attack: Process = vec![EXECUTEABLE, "-l"].into();
        let outputs = arp_attack
            .spawn_and_stream()
            .unwrap()
            .filter(|e| future::ready(e.is_output()))
            .map(|e| e.as_output().unwrap().to_string())
            .collect::<Vec<_>>()
            .await;
        println!("r: {:?}", outputs);
        InterfaceRes {
            interfaces: outputs,
        }
        .send_signal_to_dart(None);
    }
}

pub async fn do_attack() {
    use messages::arp_interface::*;
    let mut receiver = InterfaceReq::get_dart_signal_receiver();
    let mut arp_attack: Process;
    while let Some(dart_signal) = receiver.recv().await {
        let req = dart_signal.message;
        arp_attack = vec![EXECUTEABLE, "-l"].into();
        arp_attack.abort();
        let outputs = arp_attack
            .spawn_and_stream()
            .unwrap()
            .for_each(|e|{

                InterfaceRes {
                    interfaces: vec![],
                }
                .send_signal_to_dart(None);
                future::ready(())
            });
        tokio::spawn(outputs);
    }
}