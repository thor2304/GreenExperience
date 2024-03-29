import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress dest;

int controlX = 0;
int controlY = 0;
int controlXr = 0;
int controlYr = 0;

int numClasses = 5;
String messageName = "/outputs-1";
String typeTag = "f"; 

float[] dist = new float[numClasses];

float circleRadius = 10;
int colAlpha = 50;
color drawCol = color(255);
float fadeOutTime = 2000;

boolean settingsmode = false;
boolean fadeSelect = false;
boolean fadeTimer = false;

int cWidth = 640;
int cHeight = 480;

ArrayList <PVector> points = new ArrayList <PVector> ();


void setup(){
  size(640, 480);
  background(180);
  oscP5 = new OscP5(this,12000);
  //frameRate(20);
}

void draw(){
  //controlX = mouseX;
  //controlY = mouseY;
  color background = color(150);
  fill(background);
  rect(0,0,640,480);
  for (int i=points.size()-1; i>=0; i--) {
    PVector p = points.get(i);
    
    float timeAlive = millis() - p.z;
    if (timeAlive > fadeOutTime ) {   
      points.remove(i);
    } else {
      float transparency = map(timeAlive, 0, fadeOutTime, 255, 0);
      stroke(drawCol, transparency);
      strokeWeight(circleRadius);  
      if(i >3 && i%1 == 0){
        PVector p2 = points.get(i-1);
        PVector p3 = points.get(i-2);
        PVector p4 = points.get(i-3);
        
        curve(p.x, p.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y);
        
      }
    }
  }
  
  if(settingsmode && !fadeSelect){
    fill(255, 0, 0);
    rect(cWidth/2, cHeight/2, cWidth/2, cHeight/2);
    fill(0, 255, 0);
    rect(cWidth/2, 0, cWidth/2, cHeight/2);
    fill(0, 0, 255);
    rect(0, cHeight/2, cWidth/2, cHeight/2);
    fill(255);
    rect(0, 0, cWidth/2, cHeight/2);
    stroke(0);
    strokeWeight(4);
    fill(drawCol);
    circle(controlXr, controlYr, circleRadius);
  }else if(settingsmode && fadeSelect){
    background(0);
    fill(255, 200);
    rect(cWidth/2, cHeight/2, cWidth/2, cHeight/2);
    fill(255, 150);
    rect(cWidth/2, 0, cWidth/2, cHeight/2);
    fill(255, 100);
    rect(0, cHeight/2, cWidth/2, cHeight/2);
    fill(255, 50);
    rect(0, 0, cWidth/2, cHeight/2);
    stroke(0);
    strokeWeight(4);
    fill(drawCol);
    circle(controlXr, controlYr, circleRadius);
  }
 
}

void oscEvent(OscMessage theOscMessage) {
  //println("received message");
 if (theOscMessage.checkAddrPattern("/wek/outputs")) {
     if(theOscMessage.checkTypetag("fff")) { // looking for numClasses values
        float o = theOscMessage.get(0).floatValue();
        float c = theOscMessage.get(1).floatValue();
        float h = theOscMessage.get(2).floatValue();
        println(o, c, h);

        if(c== 2){
          settingsmode = true;
          
          if(h == 2 && fadeTimer){
            fadeSelect = !fadeSelect;
            fadeTimer = false;
          }else if(h==1){
            fadeTimer = true;
          }
          
          if(fadeSelect){
            if(o == 4){
             fadeOutTime = 4000;
            }else if(o == 3){
             fadeOutTime = 3000;
            }else if(o == 2){
             fadeOutTime = 2000;
            }else if(o == 1){
             fadeOutTime = 1000;
            }
          }else if(fadeSelect == false){
            if(o == 1){
             drawCol = color(255);
            }else if(o == 2){
             drawCol = color(0, 255, 0);
            }else if(o == 3){
             drawCol = color(0,0,255);
            }else if(o == 4){
             drawCol = color(255, 0, 0);
            }
          }
          
        }else{
          settingsmode = false;
          fadeSelect = false;
        }
        /*for (int i = 0; i < numClasses; i++) {
           float f = theOscMessage.get(i).floatValue(); 
           println(f);
      }*/ //useless example code from fiebrink
      } else {
        println("Error: unexpected OSC message received by Processing: ");
        theOscMessage.print();
      }
 }else if(theOscMessage.checkAddrPattern("/wek/inputs")){
   //println("received coordinate");
   controlX = 640- (int) theOscMessage.get(0).floatValue();
   controlY = (int) theOscMessage.get(1).floatValue();
   controlXr = 640- (int) theOscMessage.get(2).floatValue();
   controlYr = (int) theOscMessage.get(3).floatValue();
   
   if(controlX != 640 && controlY != 0){
   points.add(new PVector(640- (int) theOscMessage.get(0).floatValue(), (int) theOscMessage.get(1).floatValue(), millis()));
   } //makes sure we dont have any irrelevant pixels in the array (helps smoothen the curve)
 }else{
  theOscMessage.print();
   println("from a weird place");
 }
}
