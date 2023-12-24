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
      Path socketPath = Path.of(System.getProperty("user.home")).resolve("screen.socket"); // resolve path
      UnixDomainSocketAddress socketAddress = UnixDomainSocketAddress.of(socketPath); // create socketAddress
      
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
    for (int y = 0; y < height/2; y++) {
      for (int x = 0; x < width/2; x++) {
        
        // top left
        int p = pixels[x + (y * height)];
        buffer.put((byte)(p >> 16));
        buffer.put((byte)(p >> 8));
        buffer.put((byte)p);
        
        // top right
        p = pixels[(x + width/2) + (y * height)];
        buffer.put((byte)(p >> 16));
        buffer.put((byte)(p >> 8));
        buffer.put((byte)p);
        
        // bottom left
        p = pixels[x + ((y+height/2) * height)];
        buffer.put((byte)(p >> 16));
        buffer.put((byte)(p >> 8));
        buffer.put((byte)p);
        
        // bottom right
        p = pixels[(x + width/2) + ((y+height/2) * height)];
        buffer.put((byte)(p >> 16));
        buffer.put((byte)(p >> 8));
        buffer.put((byte)p);
        
      }
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
