// Socket sender to send framebuffer to the actual FTDI driver program.
// USAGE:
// Create a new SocketSender(this, X, X, X, X) in the setup function of your main program.
// where X is a reference to a Color[128] array for each LED strip.
// or null if no LED strip is required

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
  color[] strip1, strip2, strip3, strip4;
  SocketChannel channel;
  ByteBuffer buffer;
  boolean connected;
  
  SocketSender(PApplet parent, color[] strip1, color[] strip2, color[] strip3, color[] strip4)
  {
    buffer = ByteBuffer.allocateDirect(((width*height) + (128*4))*3);
    parent.registerMethod("draw", this);
    this.strip1 = strip1;
    this.strip2 = strip2;
    this.strip3 = strip3;
    this.strip4 = strip4;
    this.connected = false;
  }
  
  boolean connect(){
    
    String tmpdir = System.getProperty("java.io.tmpdir");
    try{
      UnixDomainSocketAddress socketAddress = UnixDomainSocketAddress.of(tmpdir + "/screen.socket"); // create socketAddress
      
      channel = SocketChannel.open(StandardProtocolFamily.UNIX); // create the channel
      channel.connect(socketAddress); // connect channel to address;
    }
    catch(IOException ex){
      ex.printStackTrace();
      System.out.println("Could not connect to socket file. Is the server running?");
      return false;
    }
    this.connected = true;
    return true;
  }
  
  void draw()
  {
    if(this.connected){
      loadPixels();
      buffer.clear();
      for (int i = 0; i < width*height; i++) {
        int p = pixels[i];
        buffer.put((byte)(p >> 16));  //R
        buffer.put((byte)(p >> 8));   //G
        buffer.put((byte) p);         //B
      }
      
      if(strip1 == null){
        for (int i = 0; i < 128; i++) {
          int p = pixels[i];
          buffer.put((byte)(p >> 16)); //R
          buffer.put((byte)(p >> 8)); //G
          buffer.put((byte) p); //B
        }
      } else {
        for (int i = 0; i < 128; i++) {
          buffer.put((byte)(strip1[i] >> 16)); //R
          buffer.put((byte)(strip1[i] >> 8)); //G
          buffer.put((byte) strip1[i]); //B
        }
      }
      
      if(strip2 == null){
        for (int i = 0; i < 128; i++) {
          int p = pixels[i];
          buffer.put((byte)(p >> 16)); //R
          buffer.put((byte)(p >> 8)); //G
          buffer.put((byte) p); //B
        }
      } else {
        for (int i = 0; i < 128; i++) {
          buffer.put((byte)(strip2[i] >> 16)); //R
          buffer.put((byte)(strip2[i] >> 8)); //G
          buffer.put((byte) strip2[i]); //B
        }
      }
      
      if(strip3 == null){
        for (int i = 0; i < 128; i++) {
          int p = pixels[i];
          buffer.put((byte)(p >> 16)); //R
          buffer.put((byte)(p >> 8)); //G
          buffer.put((byte) p); //B
        }
      } else {
        for (int i = 0; i < 128; i++) {
          buffer.put((byte)(strip3[i] >> 16)); //R
          buffer.put((byte)(strip3[i] >> 8)); //G
          buffer.put((byte) strip3[i]); //B
        }
      }
      
      if(strip4 == null){
        for (int i = 0; i < 128; i++) {
          int p = pixels[i];
          buffer.put((byte)(p >> 16)); //R
          buffer.put((byte)(p >> 8)); //G
          buffer.put((byte) p); //B
        }
      } else {
        for (int i = 0; i < 128; i++) {
          buffer.put((byte)(strip4[i] >> 16)); //R
          buffer.put((byte)(strip4[i] >> 8)); //G
          buffer.put((byte) strip4[i]); //B
        }
      }
      
      buffer.flip();
      
      try{
        channel.write(buffer);
      }
      catch(IOException ex){
        ex.printStackTrace();
        System.out.println("Could not write to socket file. Did the server crash?");
        this.connected = false;
      }
    }
  }
}
