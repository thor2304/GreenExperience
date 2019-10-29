/**
 * REALLY simple processing sketch for using webcam input
 * This sends 100 input values to port 6448 using message /wek/inputs
 **/

import processing.video.*;
import oscP5.*;
import netP5.*;

int numPixelsOrig;
int numPixels;
boolean first = true;

int greenSens = 20;  //lægges til r og b, for at sammenligne med grøn 20 anbefales
int redSens = 95;  //lægges til g og b, for at sammenligne med rød 20 anbefales

int cWidth = 640;
int cHeight = 480;

int[][] greenP;
int greenCount = 0;
int[][] redP;
int redCount = 0;

Capture video;

PImage videoMirror;

OscP5 oscP5;
NetAddress dest;
NetAddress dest2;

void setup() {
  greenP = new int[2][307000];
  redP = new int[2][307000];
  
  // colorMode(HSB);
  size(640, 480, P2D);

  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    video = new Capture(this, cWidth, cHeight);
  } 
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    /* println("Available cameras:");
     for (int i = 0; i < cameras.length; i++) {
     println(cameras[i]);
     } */

    video = new Capture(this, cWidth, cHeight);

    // Start capturing the images from the camera
    video.start();

    videoMirror = new PImage(video.width, video.height);

    numPixelsOrig = video.width * video.height;
    loadPixels();
    noStroke();
  }

  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 1000);
  dest = new NetAddress("127.0.0.1", 6448);
  dest2 = new NetAddress("127.0.0.1", 12000);
}

void draw() {

  if (video.available() == true) {
    video.read();
    //set(0, 0, video);
    
    video.loadPixels(); // Make the pixels of video available
 
    
    for (int x = 0; x < cWidth; x++) {
      for (int y = 0; y < cHeight; y++) {
        float ired = 0, igreen = 0, iblue = 0;
        
        videoMirror.pixels[x+y*video.width] = video.pixels[(video.width-(x+1))+y*video.width];
          
        int index = (x) + (y) * cWidth;
        ired = red(video.pixels[index]);
        igreen = green(video.pixels[index]);
        iblue = blue(video.pixels[index]);
        
        if(ired+greenSens<igreen && iblue + greenSens < igreen){
           greenP[0][greenCount] = x;
           greenP[1][greenCount] = y;
           greenCount++;
        } else if(igreen+redSens<ired && iblue + redSens < ired){
           redP[0][redCount] = x;
           redP[1][redCount] = y;
           redCount++;
        }
            

      }
    }
    
    videoMirror.updatePixels();
    image(videoMirror, 0, 0);
    
    /*
    for (int x = 0; x < cWidth; x++) {
      for (int y = 0; y < cHeight; y++) {
        float ired = 0, igreen = 0, iblue = 0;
        int index = (x) + (y) * cWidth;
        ired = red(video.pixels[index]);
        igreen = green(video.pixels[index]);
        iblue = blue(video.pixels[index]);

        if(ired+greenSens<igreen && iblue + greenSens < igreen){
         
           stroke(255,0,0);
           point(width - x,y);
        }
  
        
      }
    }*/
    
    int gTx = 0;
    int gTy = 0;
    for(int i=0; i < greenCount; i++){
      gTx+=greenP[0][i];
      gTy+=greenP[1][i];
    }
    float gPx= 0;
    float gPy = 0;
    
    if(greenCount > 0){
      gPx= gTx/greenCount;
      gPy= gTy/greenCount;
    
    }
    
    // nu når vi til at arbejde med de røde pixels
    
    int rTx = 0;
    int rTy = 0;
    for(int i=0; i < redCount; i++){
      rTx+=redP[0][i];
      rTy+=redP[1][i];
    }
    float rPx = 0;
    float rPy = 0;
    
    if(redCount > 0){
      rPx= rTx/redCount;
      rPy= rTy/redCount;
    
    }
    
    //println("grøn: " + gPx + " , "  + gPy);
    // den grønne cirkel
    fill(255,0);
    stroke(0,255,0);
    circle(cWidth - gPx, gPy, 2* sqrt(greenCount/PI));
    
    fill(0,255,0);
    text("greenCount: " + greenCount , 200, 70, 20);
    
    // den røde cirkel
    fill(255,0);
    stroke(255,0,0);
    circle(cWidth - rPx, rPy, 2* sqrt(redCount/PI));
    
    fill(255,0,0);
    text("redCount: "+ redCount , 200, 100, 20);
    
    if (frameCount % 1 == 0) {
      sendOsc(gPx,gPy, rPx, rPy);
    }

    fill(0);
    
  }
  greenCount = 0;
  redCount = 0;
}


void oscEvent(OscMessage theOscMessage) {

  }

float diff(int p, int off) {
  if (p + off < 0 || p + off >= numPixels)
    return 0;
    return red(video.pixels[p+off]) - red(video.pixels[p]) +
    green(video.pixels[p+off]) - green(video.pixels[p]) +
    blue(video.pixels[p+off]) - blue(video.pixels[p]);
}

void sendOsc(float gpx, float gpy, float rpx, float rpy) {
  OscMessage msg = new OscMessage("/wek/inputs");
  msg.add(gpx);
  msg.add(gpy);
  msg.add(rpx);
  msg.add(rpy);
  oscP5.send(msg, dest);
  oscP5.send(msg, dest2);
}

void keyPressed() {
  if (key == '7') {
    greenSens ++;
    println("greenSens: " + greenSens);
  }else if (key == '1') {
    greenSens --;
    println("greenSens: " + greenSens);
  }else if (key == '9') {
    redSens ++;
    println("redSens: " + redSens);
  }else if (key == '3') {
    redSens --;
    println("redSens: " + redSens);
  }else{
  println(key);
  }
}
