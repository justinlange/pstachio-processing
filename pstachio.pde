import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import httprocessing.*;
import rekognition.faces.*;

Capture video;
OpenCV opencv;
PImage frame1;
int stachCount = 7;
int currentStach = 0;
int appFrameCount = 2;
int appState = 0;

PImage[] staches = new PImage[stachCount];
PImage[] appFrame = new PImage[appFrameCount];
PImage instructionsbg;
PImage instructionshand;

float x, targetX;
float easing = 0.05;

int numPixels;
int[] backgroundPixels;

int vidW = 640;
int vidH = 480;

String currentUser;

boolean recImgDebug = false;
boolean showMatches = false;

Timer splashScreen;
Timer handDraw;

Rekognition rekog;
RFace[] faces;
float sureNum = .7;
boolean sureBool = false;

color green = color(22, 89, 20); 
color red = color(135, 46, 21);
PFont aller;
PFont allerbold;

String[] rewardPhrases = {
    "You get a\n05% off today!", 
    "You get a\n10% off today!", 
    "You get a\n20% off today!"
  };

void setup() {
  size(1024, 768);
  setupFonts();

  currentUser = "unknown-user";
  video = new Capture(this, vidW, vidH);
  opencv = new OpenCV(this, vidW, vidH);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);

  setUpRec();
  loadInstructionsPage();

  frame1 = loadImage("page-frame-flipped.png");

  for (int i=0;i<stachCount;i++) {
    staches[i] = loadImage("0" + (i+1) + ".png");
  }

  for (int i=0;i<appFrameCount; i++) {
    appFrame[i] = loadImage("appFrame" + (i+1) + ".png");
  }

  video.start();
  splashScreen = new Timer(3000);
  handDraw = new Timer(2000);
  loadPixels();
}

void setUpRec() {
  // Load the API keys
  String[] keys = loadStrings("key.txt");
  String api_key = keys[0];
  String api_secret = keys[1];

  // Create the face recognizer object
  rekog = new Rekognition(this, api_key, api_secret);
  rekog.setNamespace("stachio");
  rekog.setUserID("processing");
}

void tryFaceRec() {
  println("saving video");
  video.read(); // Read a new video frame
  String fileName = "data/" + currentUser + ".jpg";
  video.save(fileName);
  println("rekognizing face");
  faces = rekog.recognize(fileName);
  showMatches = true;
}

void trainFace() {
}

void showMatches() {
  for (int i = 0; i < faces.length; i++) {
    // Possible face matches come back in a FloatDict
    // A string (name of face) is paired with a float from 0 to 1 (how likely is it that face)
    FloatDict matches = faces[i].getMatches();
    saluteUser(matches.maxKey(), matches.maxValue());
    
    /*
    for (String key : matches.keys()) {
      float likely = matches.get(key);
      display += key + ": " + likely + "\n";
      if (likely > sureNum) sureBool = true;
    }
    */

    if(sureBool){
    }else{
      //persistantText = "we don't seem to recognize you! \n  stach to create a new account";
//      text(persistantText, 50, 60);
    }
    
  }
}


void draw() {
  background(255);

  //if(splashScreen.isTimeUp()) appState = 1;

  if (appState == 0) {
    instructionsPage();
  }
  else if (appState == 1) {
    mainPage();   
    if (showMatches) showMatches();
  }
  else if (appState == 2) {
  }
}

void captureEvent(Capture c) {
  c.read();
}


void loadInstructionsPage() {
  instructionsbg = loadImage("instructions-bg.png");
  instructionshand = loadImage("instructions-hand.png");
  targetX = width * .2;
}


void instructionsPage() {
  if (handDraw.isTimeUp() == true) {
    if (targetX < width * .8) targetX+= 10;
  } 
  float dx = targetX - x;
  if (abs(dx) > 1) {
    x += dx * easing;
  } 
  image(instructionsbg, 0, 0);
  image(instructionshand, x, height-instructionshand.height);
}


void mainPage() {
  float scaleFactor = 1.6;

  pushMatrix();
  pushMatrix();
  opencv.loadImage(video);

  translate(width, 0);
  scale(-1, 1);
  //scale(1.6);

  image(video, 0, 0, 1024, 768);

  noFill();
  stroke(0, 255, 0);
  strokeWeight(3);
  Rectangle[] faces = opencv.detect();

  popMatrix();

  for (int i = 0; i < faces.length; i++) {
    //println(faces[i].x + "," + faces[i].y);
    pushMatrix();
    translate(width, 0);
    scale(-1, 1);
    //rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
    imageMode(CORNER);
    image(staches[currentStach], faces[i].x*scaleFactor, (faces[i].y+(faces[i].height * .3))*scaleFactor, faces[i].width*scaleFactor, faces[i].height*scaleFactor);
    popMatrix();
  }
  imageMode(CORNER);
  popMatrix();
  image(frame1, 0, 0);
}


//--- MOUSE AND KEYBOARD INPUT --//

void keyPressed() {
  switch(key) {
  case 's':  
    currentStach = (currentStach + 1)%stachCount;
    break;
  case 'r':
    tryFaceRec();  
    break;
  case 'p':
    recImgDebug = !recImgDebug;
  }
}

void mousePressed() {
  //appState = 1;
}

void mouseReleased() {
  appState = 1;
}

void mouseMoved() {
}

