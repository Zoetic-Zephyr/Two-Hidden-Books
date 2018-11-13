//Flocking by Daniel Shiffman. 

//An implementation of Craig Reynold's Boids program to simulate the flocking behavior of birds. Each boid steers itself based on rules of avoidance, alignment, and coherence. 

//Click the mouse to add a new boid.

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;


Flock flock;
Animation butterfly;

int text1X = 276+237;
//float text1W = 451*1.05;
float text1W = 2;
float text1H = 685*1.05;
int text1Y = 382;
int text2X = 993-272;
//float text2W = 517*1.05;
float text2W = 2;
float text2H = 791*1.05;
int text2Y = 367;
PImage borderMask;

PImage img;
PImage img2;
boolean tint1 = false;
boolean tint2 = false;


void setup() {
  float offset = 0.1;
  borderMask = loadImage("borderMask.png");
  fullScreen(P3D);
  frameRate(45);
  //size(1280, 720);
  flock = new Flock();
  butterfly = new Animation("flyw_", 40);
  // Add an initial set of boids into the system
  //
  for (int i = 0; i < 41; i++) {
    color clr = color(random(255), random(255), random(255), random(150, 255));
    if (random(1)<0.25) {
      flock.addBoid(new Boid(random(-width*(offset), 0), random(0, height), random(0.5, 1.5), clr));
    } else if (random(1)<0.5) {
      flock.addBoid(new Boid(random(width, width*(1+offset)), random(0, height), random(0.5, 1.5), clr));
    } else if (random(1)<0.75) {
      flock.addBoid(new Boid(random(0, width), random(-height*(offset), 0), random(0.5, 1.5), clr));
    } else {
      flock.addBoid(new Boid(random(0, width), random(height, height*(1+offset)), random(0.5, 1.5), clr));
    }
  }

  oscP5 = new OscP5(this, 1234);
  //myRemoteLocation = new NetAddress("127.0.0.1", 8338);
  img = loadImage("book1.jpg");
  img2 = loadImage("book2.jpg");
}

void draw() {
  background(0);
  pushMatrix();
  pushStyle();
  imageMode(CORNER);
  image(borderMask, 0, 0);
  popStyle();
  popMatrix();
  //noFill();
  //stroke(100);
  //rectMode(CENTER);
  //rect(text1X, text1Y, text1W, text1H);
  //rect(text2X, text2Y, text2W, text2H);

  flock.run();

  pushMatrix();
  pushStyle();
  imageMode(CENTER);
  if (!tint2) {
    tint(0);
  }
  image(img, 276, 382);
  popStyle();
  popMatrix();

  pushMatrix();
  pushStyle();
  imageMode(CENTER);
  if (!tint1) {
    tint(0);
  }
  image(img2, 993, 367);
  popStyle();
  popMatrix();
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/bookIdx")==true) {
    int bookIdx = theOscMessage.get(0).intValue();
    if (bookIdx == 0) {
      tint1 = false;
      tint2 = false;
    } else if (bookIdx == 1) {
      tint1 = true;
    } else {
      tint2 = true;
    }
  }
}
