import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress dest;

int controlX = 0;
int controlY = 0;

int numClasses = 5;
String messageName = "/outputs-1";
String typeTag = "f"; 

float[] dist = new float[numClasses];

void setup(){
  size(640, 480);
  background(180);
  oscP5 = new OscP5(this,12000);
}

void draw(){
  //controlX = mouseX;
  //controlY = mouseY;
  color background = color(100, 10);
  fill(background);
  rect(0,0,640,480);
  stroke(255, 0);
  fill(255, 150);
  ellipse(controlX, controlY, 10, 10);
 
}

void oscEvent(OscMessage theOscMessage) {
  //println("received message");
 if (theOscMessage.checkAddrPattern("/outputs-1")==true) {
     if(theOscMessage.checkTypetag("f")) { // looking for numClasses values
        for (int i = 0; i < numClasses; i++) {
           float f = theOscMessage.get(i).floatValue(); 
           println(f);
      }
      } else {
        println("Error: unexpected OSC message received by Processing: ");
        theOscMessage.print();
      }
 }else if(theOscMessage.checkAddrPattern("/wek/inputs")){
   println("received coordinate");
   controlX = 640- (int) theOscMessage.get(0).floatValue();
   controlY = (int) theOscMessage.get(1).floatValue();
 }
}
