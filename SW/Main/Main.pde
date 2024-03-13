import processing.sound.*;
import processing.serial.*;

enum Emotion {
  EMOTION_NEUTRAL,
  EMOTION_X,
  EMOTION_O,
  EMOTION_U
}

// Global configuration
final boolean hardware = true;
final int proxThreshold = 18;

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
Emotion emotion = Emotion.EMOTION_NEUTRAL;
long nextBlink = 2400;
float[] spectrum = new float[512];
color[] emblemL = new color[128];
color[] emblemR = new color[128];
int maxBand = 0;
float mouthFreq = 0;
float mouthWidth = 0;
boolean blink = false;
float accX = 0;
float accY = 0;
float accZ = 0;
float accZSmooth = 0;
float accYSmooth = 0;
int proximity = 0;
float preIntensity = 0;
float intensity = 0;

void setup()
{
  socket = new SocketSender(this, emblemR, null, null, emblemL);
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
  } else {
   proximity = mouseX; 
  }
  
  preIntensity = constrain((proximity-proxThreshold)/30.0, 0.0, 2.0);
  if(preIntensity > intensity) { // ramp up
    intensity += (preIntensity - intensity) * 0.2;
  } else { // ramp down
      intensity += (preIntensity - intensity) * 0.015;
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
  
  if(intensity > 0.05){ // turn on shader only when we need it
    shade.set("time", (float) millis()/1000.0);
    shade.set("intensity", intensity);
    shader(shade);
  }
 
  drawFace();
  blendMode(MULTIPLY);
  image(face, 0, 0);
  
  resetShader();
  
  colorEmblems();
  
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
  face.translate(width/2 + sin(millis()/1300.0)*1 + (-accYSmooth * 10.0), height/2 + cos(millis()/942.0)*1 + (accZSmooth*10.0));
  //face.translate(width/2, height/2);
  
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
  
  if(intensity > 1){
    face.line(-98,-29,-78,-9);
    face.line(-78,-29,-98,-9);
  } else if(blink) {
    face.line(-107,-16,-72,-18);
  } else {
    switch(emotion) {
      case EMOTION_X:
        face.line(-98,-29,-78,-9);
        face.line(-78,-29,-98,-9);
        break;
        
      case EMOTION_O:
        face.noFill();
        face.circle(-88, -19, 24);
        break;
        
      case EMOTION_U:
        face.noFill();
        face.line(-100,-29,-100,-19);
        face.line(-76,-29,-76,-19);
        face.arc(-88, -19, 24, 24, 0, PI);
        break;
        
        
      case EMOTION_NEUTRAL:
      default:
        face.beginShape();
        face.vertex(-107,-10);
        face.bezierVertex(-105,-35,   -71,-35,  -71,-11);
        face.bezierVertex( -72,-16,  -104,-15, -107,-10);
        face.endShape();
        break;
    }
  }
  
  face.pop();
}

void drawNose(){
  face.push();
  
  face.strokeWeight(5);
  
  face.line(-17,-17-4,-8,-17-4);
  face.line(-8,-17-4,-9,-6-4);
  
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

void colorEmblems(){
  color randColor = color(0, 255, random(0,255));
  for(int i = 0; i < 16; i++){
    emblemL[i] = color((frameCount/16.0 + i*4 - 32) % 256, 255, 255);
    emblemR[i] = color((frameCount/16.0 + i*4 + 32) % 256, 255, 255);
    emblemL[i] = lerpColor(emblemL[i], randColor, intensity);
    emblemR[i] = lerpColor(emblemR[i], randColor, intensity);
    
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
          accZ = float(vals[3])-0.8;
        } catch(Exception e) {
          println(e.getMessage());
        }
      }
  }
  accZSmooth += (accZ - accZSmooth) * 0.1;
  accYSmooth += (accY - accYSmooth) * 0.1;
}

void mouseClicked(){
  println("vertex(" + (mouseX-width/2) + "," + (mouseY-height/2) + ");");
}

void keyPressed(){
  if(key == '-'){
    exit();
  }
  if(key == '0'){
    emotion = Emotion.EMOTION_NEUTRAL; 
  }
  if(key == '4'){
    emotion = Emotion.EMOTION_X;
  }
  if(key == '5'){
    emotion = Emotion.EMOTION_O;
  }
  if(key == '6'){
    emotion = Emotion.EMOTION_U;
  }
}
