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

int boxWidth = 32;
int boxHeight = 24;

int greenSens = 10;

int cWidth = 640;
int cHeight = 480;

int numHoriz = cWidth/boxWidth;
int numVert = 480/boxHeight;

int[][] greenP;

color[] downPix = new color[numHoriz * numVert];


Capture video;

OscP5 oscP5;
NetAddress dest;

void setup() {
  greenP = new int[3][400];
  
  // colorMode(HSB);
  size(1280, 960, P2D);

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

    video.loadPixels(); // Make the pixels of video available

    int boxNum = 0;
    int tot = boxWidth*boxHeight;
    for (int x = 0; x < cWidth; x += boxWidth) {
      for (int y = 0; y < cHeight; y += boxHeight) {
        float red = 0, green = 0, blue = 0;

        for (int i = 0; i < boxWidth; i++) {
          for (int j = 0; j < boxHeight; j++) {
            int index = (x + i) + (y + j) * cWidth;
            red += red(video.pixels[index]);
            green += green(video.pixels[index]);
            blue += blue(video.pixels[index]);
          }
        }
        downPix[boxNum] = color(red/tot, green/tot, blue/tot);
        fill(downPix[boxNum]);

        if(red+blue+greenSens<green){
           //println("Den er grøn");
           greenP[0][0] += 1;
           greenP[1][greenP[0][0]-1] = (int) Math.floor(boxNum/20);
           greenP[2][greenP[0][0]-1] = (boxNum +20) % (20*(1+ greenP[1][greenP[0][0]-1]));
        }

        int index = x + cWidth*y;
        red += red(video.pixels[index]);
        green += green(video.pixels[index]);
        blue += blue(video.pixels[index]);
        rect(width - boxWidth*2 - x*2, y*2, boxWidth*2, boxHeight*2);
        
        fill(184, 40, 50, 100);

        textAlign(CENTER);
        text(boxNum, width - (x + boxWidth / 2)*2, y*2 + boxHeight);
        
        
        
        boxNum++;
      }
    }
    int Tx = 0;
    int Ty = 0;
    for (int i=0; i < greenP[0][0];i++){
      Tx+=greenP[1][i];
      Ty+=greenP[2][i];
    }
    float Px= 0;
    float Py = 0;
    
    if(greenP[0][0] > 0){
    Px=Tx/greenP[0][0];
    Py=Ty/greenP[0][0];
    
    }
    
    println("grøn: " + Px + " , "  + Py);
    
    if (frameCount % 2 == 0) {
      sendOsc(downPix);
    }

    fill(0);
    text("Sending 100 inputs to port 6448 using message /wek/inputs", 10, 10);
    greenP[0][0] = 0;
    
  }
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

void sendOsc(int[] px) {
  OscMessage msg = new OscMessage("/wek/inputs");
  // msg.add(px);
  for (int i = 0; i < px.length; i++) {
    msg.add(float(px[i]));
  }
  oscP5.send(msg, dest);
}
