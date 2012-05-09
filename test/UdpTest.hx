package ;

import cpp.vm.Thread;
import cpp.vm.Lock;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import hxudp.UdpSocket;

class UdpTest {
	static function server():Void {
		var lock:Lock = Thread.readMessage(true);
		
		var s = new UdpSocket();
		trace("server create: " + s.create());
		trace("server bind 11999: " + s.bind(11999));
		trace("server setNonBlocking false: " + s.setNonBlocking(false));
		trace("server getMaxMsgSize: " + s.getMaxMsgSize());
		trace("server getReceiveBufferSize: " + s.getReceiveBufferSize());
		
		var b = Bytes.alloc(80);
		trace("server receive: " + s.receive(b));
		trace("server receive dump:");
		var input = new BytesInput(b);
		var n = 0;
		for (i in 0...10){
			var str = "";
			for (j in 0...8) {
				var byte = input.readByte();
				var char = String.fromCharCode(byte);
				str += StringTools.hex(byte, 2) 
					+ (byte >= 32 && byte < 127 ? "(" + char + ")" : "   ") + ", ";
			}
			trace(str);
		}
		
		var b = Bytes.alloc(80);
		trace("server receive: " + s.receive(b));
		trace("server received: " + new BytesInput(b).readUntil(0));
		
		s.close();
		
		lock.release();
	}
	
	static public function main():Void {
		//create a lock for knowing when server exit
		var lock = new Lock();
		
		var serverThread = Thread.create(server);
		serverThread.sendMessage(lock);
		
		var s = new UdpSocket();
		trace("client create: " + s.create());
		trace("client getSendBufferSize: " + s.getSendBufferSize());
		trace("client connect: " + s.connect("127.0.0.1", 11999));
		trace("client send 'testing': " + s.send(Bytes.ofString("testing")));
		trace("client sendAll 'testing2': " + s.sendAll(Bytes.ofString("testing2")));
		trace("client close: " + s.close());
		
		//wait for server to exit
		while (!lock.wait(100)) {
			trace("waiting...");
		}
		trace("server-client test finished");
	}
}