import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import controlP5.*;

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

ControlP5 cp5;

Kinect2 kinect2;
PImage depthImg;

int thresholdMin=0;
int thresholdMax=4499;

float avgX=0;
float avgY=0;

int bookOneL = 200;
int bookOneT = 120;
int bookOneW = 90;
int bookOneH = 140;

int bookTwoL = 340;
int bookTwoT = 130;
int bookTwoW = 85;
int bookTwoH = 130;


void setup() {
  size(512, 424, P2D);
  //fullScreen(P2D);

  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();

  // Blank image
  depthImg = new PImage(kinect2.depthWidth, kinect2.depthHeight, ARGB);

  // add gui
  int sliderW = 100;
  int sliderH = 20;
  cp5 = new ControlP5( this );
  cp5.addSlider("thresholdMin")
    .setPosition(10, 40)
    .setSize(sliderW, sliderH)
    .setRange(1, 4499)
    .setValue(610)
    //.setValue(540)
    ;
  cp5.addSlider("thresholdMax")
    .setPosition(10, 70)
    .setSize(sliderW, sliderH)
    .setRange(1, 4499)
    .setValue(620)
    ;

  oscP5 = new OscP5(this, 6800);
  myRemoteLocation = new NetAddress("127.0.0.1", 1234);
}


void draw() {
  background(0);

  float sumX = 0;
  float sumY = 0;
  int count = 0;
  int[] rawDepth = kinect2.getRawDepth();
  depthImg.loadPixels();
  for (int i=0; i < rawDepth.length; i++) {
    int depth = rawDepth[i];

    if (depth >= thresholdMin
      && depth <= thresholdMax
      && depth != 0) {

      int x = i % kinect2.depthWidth;
      int y = floor(i / kinect2.depthWidth);

      float r = map(depth, thresholdMin, thresholdMax, 255, 0);
      float b = map(depth, thresholdMin, thresholdMax, 0, 255);
      depthImg.pixels[i] = color(r, 0, b);
      if (x>200 && y<260 && x<430 && y>120) {
        sumX += x;
        sumY += y;
        count++;
      }
      //} else {
      //  depthImg.pixels[i] = color(0, 0);
      //}
    } else {
      depthImg.pixels[i] = color(0, 0);
    }
  }
  depthImg.updatePixels();

  image(kinect2.getDepthImage(), 0, 0);
  image(depthImg, 0, 0);

  // get the center position
  avgX = 0;
  avgY = 0;
  if (count > 100) {
    avgX = sumX / count;
    avgY = sumY / count;
  }

  // draw the center position
  stroke(0, 255, 0);
  line(avgX, 0, avgX, height);
  line(0, avgY, width, avgY);
  //println(avgX, avgY);
  checkSurface();

  pushStyle();
  stroke(0, 255, 255);
  line(0, 260, width, 260);
  line(0, 120, width, 120);
  line(200, 0, 200, height);
  line(430, 0, 430, height);
  popStyle();

  fill(255);
  text(frameRate, 10, 20);
}

void checkSurface() {
  if (avgX>bookOneL && avgX<bookOneL+bookOneW && avgY<bookOneT+bookOneH && avgY>bookOneT) {
    bookOne();
  }
  else if (avgX>bookTwoL && avgX<bookTwoL+bookTwoW && avgY<bookTwoT+bookTwoH && avgY>bookTwoT) {
    bookTwo();
  } else {
    sendOsc(0);
  }
}

void bookOne() {
  pushStyle();
  fill(255, 0, 0, 50);
  rect(bookOneL, bookOneT, bookOneW, bookOneH);
  popStyle();
  sendOsc(1);
}

void bookTwo() {
  pushStyle();
  fill(0, 255, 0, 20);
  rect(bookTwoL, bookTwoT, bookTwoW, bookTwoH);
  popStyle();
  sendOsc(2);
}

void sendOsc(int bookIdx) {
  /* in the following different ways of creating osc messages are shown by example */
  OscMessage myMessage = new OscMessage("/bookIdx");

  myMessage.add(bookIdx); /* add an int to the osc message */

  /* send the message */
  oscP5.send(myMessage, myRemoteLocation);
}
