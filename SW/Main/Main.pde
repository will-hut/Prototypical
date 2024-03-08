import processing.sound.*;
import processing.serial.*;

// Global configuration
final boolean hardware = true;
final int proxThreshold = 35;

// Objects
Serial mcu;
SocketSender socket;
PGraphics face;
PShader shade;
PImage shaderNoise;
AudioIn audioIn;
FFT fft;
Amplitude amp;

// Global Variables
long nextBlink = 2400;
float[] spectrum = new float[512];
int maxBand = 0;
float mouthFreq = 0;
float mouthWidth = 0;
boolean blink = false;
float accX = 0;
float accY = 0;
float accZ = 0;
int proximity = 0;

void setup()
{
  socket = new SocketSender(this, null, null, null, null);
  face = createGraphics(256, 64, P2D);
  
  shaderNoise = loadImage("noise.png");
  shade = loadShader("glitch.glsl");
  shade.set("noiseTexture", shaderNoise);
  
  size(256, 64, P2D);
  colorMode(HSB, 255);
  noStroke();
  frameRate(240);
  
  audioIn = new AudioIn(this, 0);
  audioIn.start();
  
  fft = new FFT(this, 512);
  fft.input(audioIn);
  
  amp = new Amplitude(this);
  amp.input(audioIn);
  
  if(hardware){
      mcu = new Serial(this, Serial.list()[0], 115200);
      while(!socket.connect()) {delay(1000);}
  }
}

void draw(){
  
  if(hardware){
    readMCU();
  }
  
  mouthWidth = amp.analyze();
  maxBand = maxFFT();
  mouthFreq += (maxBand - mouthFreq) * 0.06;
  
  blink = false;
  if(frameCount > nextBlink){
    nextBlink += random(1800, 3200);
  } else if(frameCount > nextBlink - 16) {
    blink = true;
  }
  
  background(0);
  blendMode(NORMAL);
  
  for(int i = 0; i < 256; i++){
    fill((frameCount/16 + i/4) % 256, 255, 255);
    rect(i, 0, width, height);
  }
  
  float intensity = constrain((proximity-proxThreshold)/20.0, 0.0, 2.0);
  
  if(intensity > 0.05){ // turn on shader only when we need it
    shade.set("time", (float) millis()/1000.0);
    shade.set("intensity", intensity);
    shader(shade);
  }
 
  drawFace();
  blendMode(MULTIPLY);
  image(face, 0, 0);
  
  resetShader();
  
  if(hardware && !socket.connected){
    delay(500);
    socket.connect();
  }
}

void drawFace(){
  face.beginDraw();
  
  face.background(0);
  
  face.fill(255);
  face.stroke(255);
  face.strokeJoin(ROUND);
  face.translate(width/2 + sin(millis()/1300.0)*1.5, height/2 + cos(millis()/942.0)*1.5);
  
  drawEye(blink);
  drawNose();
  drawMouth(mouthWidth, mouthFreq);
  
  face.scale(-1, 1);
  
  drawEye(blink);
  drawNose();
  drawMouth(mouthWidth, mouthFreq);
  
  face.endDraw();
}
  
  
void drawEye(boolean blink){
  face.push();
  
  face.strokeWeight(5);
  
  if(blink){
    face.line(-107,-16,-72,-18);
  } else {
    face.beginShape();
    face.vertex(-107,-10);
    face.bezierVertex(-105,-35,   -71,-35,  -71,-11);
    face.bezierVertex( -72,-16,  -104,-15, -107,-10);
    face.endShape();
  }
  
  face.pop();
}

void drawNose(){
  face.push();
  
  face.strokeWeight(7);
  
  face.line(-17,-17,-8,-17);
  face.line(-8,-17,-9,-6);
  
  face.pop();
}

void drawMouth(float mouthWidth, float mouthFreq){
  face.push();
  float j = map(mouthFreq, 0, 32, 0.9, 1.1);
  float i = map(mouthWidth, 0, 1, 0, 1.5);
  
  face.strokeWeight(4);
  
  face.beginShape();
  face.vertex(-96 * j,12              );
  face.vertex(-87 * j,24    +(i*1.5)  );
  face.vertex(-71 * j,12    +(i*2.5)  );
  face.vertex(-58 * j,25    +(i*5.0)  );
  face.vertex(-27 * j,12    +(i*7.5)  );
  face.vertex(-13 * j,22    +(i*7.5)  );
  face.vertex(0      ,15    +(i*7.5)  );
  face.vertex(0      ,15    +(i*-10.0));
  face.vertex(-13 * j,22    +(i*-10.0));
  face.vertex(-27 * j,12    +(i*-10.0));
  face.vertex(-58 * j,25    +(i*-7.5) );
  face.vertex(-71 * j,12    +(i*-5.0) );
  face.vertex(-87 * j,24    +(i*-2.5) );
  face.vertex(-96 * j,12              );
  face.vertex(-96 * j,12              );
  face.endShape();
  
  face.pop();
}

void mouseClicked(){
  println("vertex(" + (mouseX-width/2) + "," + (mouseY-height/2) + ");");
}

void keyPressed(){
  if(key == '0'){
    exit();
  }
}


int maxFFT() {
  fft.analyze(spectrum);
  float maxAmp = 0;
  int maxIndex = 0;
  
  for(int i = 0; i < 32; i++){
    float amp = spectrum[i]*log(i+1)*log(i+4);
    if(amp > maxAmp){
      maxAmp = amp;
      maxIndex = i;
    }
  }
  if(maxAmp < 0.2){
    return 0;
  }
  return maxIndex;
}

void readMCU(){
  if(mcu.available() > 0){
    
    String inBuffer = mcu.readStringUntil('\n');
    
      if(inBuffer != null && inBuffer != ""){
        try{
          String[] vals = inBuffer.split(",");
          proximity = int(vals[0]);
          accX = float(vals[1]);
          accY = float(vals[2]);
          accZ = float(vals[3]);
          println(proximity);
          
        } catch(Exception e) {
          println(e.getMessage());
        }
      }
  }
}
