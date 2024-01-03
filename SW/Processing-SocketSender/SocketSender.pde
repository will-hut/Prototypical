// Socket sender to send framebuffer to the actual FTDI driver program.
// USAGE:
// Create a new SocketSender(this) in the setup function of your main program.

import java.net.*;
import java.util.Arrays;

import java.io.IOException;
import java.net.StandardProtocolFamily;
import java.net.UnixDomainSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.SocketChannel;
import java.nio.file.Path;
import java.nio.*;

public class SocketSender
{
  byte[] packetData;
  SocketChannel channel;
  ByteBuffer buffer;
  
  SocketSender(PApplet parent)
  {
    buffer = ByteBuffer.allocateDirect(width*height*3);
    parent.registerMethod("draw", this);
    
    try{
      UnixDomainSocketAddress socketAddress = UnixDomainSocketAddress.of("/tmp/screen.socket"); // create socketAddress
      
      channel = SocketChannel.open(StandardProtocolFamily.UNIX); // create the channel
      channel.connect(socketAddress); // connect channel to address;
    }
    catch(IOException ex){
      ex.printStackTrace();
      System.out.println("Could not connect to socket file. Is the server running?");
      System.exit(1);
    }
  }
  
  void draw()
  {
    loadPixels();
    buffer.clear();
    for (int i = 0; i < width*height; i++) {
        int p = pixels[i];
        buffer.put((byte)(p >> 16));  //R
        buffer.put((byte)(p >> 8));   //G
        buffer.put((byte)p);          //B
    }
    buffer.flip();
    
    try{
      channel.write(buffer);
    }
    catch(IOException ex){
      ex.printStackTrace();
      System.out.println("Could not write to socket file. Did the server crash?");
      System.exit(1);
    }
  }
}
