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

int greenSens = -25;

int cWidth = 640;
int cHeight = 480;

int[][] greenP;
int greenCount = 0;

Capture video;

PImage videoMirror;

OscP5 oscP5;
NetAddress dest;

void setup() {
  greenP = new int[2][307000];
  
  // colorMode(HSB);
  size(640, 480, P2D);

  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    video = new Capture(this, cWidth, 480);
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
  oscP5 = new OscP5(this, 12000);
  dest = new NetAddress("127.0.0.1", 6448);
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
        //stroke(ired, igreen, iblue);
        //point(width - x, y);

        
        if(ired+iblue+greenSens<igreen){
           //println("Den er grøn");
           greenCount += 1;
           greenP[0][greenCount] = (int) x;
           greenP[1][greenCount] = (int) y;
        }
  
        
      }
    }
    
    videoMirror.updatePixels();
    image(videoMirror, 0, 0);
    
    int Tx = 0;
    int Ty = 0;
    for(int i=0; i < greenCount; i++){
      Tx+=greenP[0][i];
      Ty+=greenP[1][i];
    }
    float Px= 0;
    float Py = 0;
    
    if(greenCount > 0){
      Px= Tx/greenCount;
      Py= Ty/greenCount;
    
    }
    
    //println("grøn: " + Px + " , "  + Py);
    fill(0,255,0);
    circle(cWidth - Px, Py, 20);
    
    text(greenCount , 200, 70, 20);
    
    if (frameCount % 2 == 0) {
      sendOsc(Px,Py);
    }

    fill(0);
    
  }
  greenCount = 0;
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

void sendOsc(float px, float py) {
  OscMessage msg = new OscMessage("/wek/inputs");
  msg.add(px);
  msg.add(py);
  oscP5.send(msg, dest);
}
