/*

*/

import java.awt.Robot;
import java.awt.AWTException;
import com.jogamp.newt.opengl.GLWindow;

block[] blocks;
chunkManager cm;

player p;

Robot r;
int windowX, windowY;
float sensi=0.01;

inputManager im;

void setup() {
  fullScreen(P3D,2);
  //size(500, 500, P3D);

  frameRate(1000);
  noCursor();

  float cameraZ=((height/2.0) / tan(PI*60.0/360.0));
  perspective(PI/3.0, (float)width/height, 0.1/*cameraZ/10.0*/, cameraZ*10.0);

  PGraphicsOpenGL gl=((PGraphicsOpenGL)g);
  gl.textureSampling(2);

  GLWindow win=(com.jogamp.newt.opengl.GLWindow)getSurface().getNative();
  windowX=win.getX();
  windowY=win.getY();

  blocks=loadBlocks("blocksData.json");

  p=new player();
  p.moveTo(5, 200, 5);
  
  cm=new chunkManager(blocks,p,10);
    
  p.cm=cm;
  
  im=new inputManager(p);

  try {
    r=new Robot();
  }
  catch(AWTException e) {
    e.printStackTrace();
  }
}

void draw() {
  background(255);

  camera(p.x, -p.y-1, p.z, p.x-sin(p.lr)*cos(p.ud), -p.y-1-sin(p.ud), p.z-cos(p.lr)*cos(p.ud), 0, 1, 0);

  //directionalLight(255,255,200, -0.5, 1, -0.1);

  //pointLight(50,50,50,p.x, p.y-1, p.z);

  beginShape(LINES);
  stroke(255, 0, 0);
  vertex(p.x+sin(p.lr), p.y-1-sin(p.ud), p.z+cos(p.lr));
  vertex(p.x+sin(p.lr)+0.1, p.y-1-sin(p.ud), p.z+cos(p.lr));
  stroke(0, 255, 0);
  vertex(p.x+sin(p.lr), p.y-1-sin(p.ud), p.z+cos(p.lr));
  vertex(p.x+sin(p.lr), p.y-1-sin(p.ud)+0.1, p.z+cos(p.lr));
  stroke(0, 0, 255);
  vertex(p.x+sin(p.lr), p.y-1-sin(p.ud), p.z+cos(p.lr));
  vertex(p.x+sin(p.lr), p.y-1-sin(p.ud), p.z+cos(p.lr)+0.1);
  endShape();

  noStroke();
  //stroke(0);
  noFill();
  cm.renderShape();

  p.walk(im.getAngs());

  fill(0);
  camera();
  hint(DISABLE_DEPTH_TEST);
  noLights();
  textMode(MODEL);
  textSize(20);
  text(frameRate+"\n"+p.x+";"+p.y+";"+p.z+"\n"+p.lr+";"+p.ud+"\n"+floor(p.x/16)+";"+floor(p.z/16)+";"+cm.getChunkIndex(floor(p.x/16),floor(p.z/16)), 10, 10 + textAscent());
  hint(ENABLE_DEPTH_TEST);
}

void keyPressed() {
  im.keyPressed();
}
void keyReleased() {
  im.keyReleased();
}

boolean resettingMouse=false;
void mouseMoved(MouseEvent e) {
  if (!resettingMouse) {
    p.lr=(p.lr-(mouseX-pmouseX)*sensi);//map(mouseX,0,width,-PI,PI);
    if(p.lr>PI) p.lr-=TWO_PI;
    if(p.lr<-PI) p.lr+=TWO_PI;
    p.ud-=(mouseY-pmouseY)*sensi;
    if(p.ud<=-HALF_PI) p.ud=-HALF_PI+0.01;
    if(p.ud>HALF_PI) p.ud=HALF_PI;
  }
  else resettingMouse=false;
  if (mouseX<width/4||mouseX>width/4*3||mouseY<height/4||mouseY>height/4*3) {
    r.mouseMove(windowX+width/2, windowY+height/2);
    resettingMouse=true;
  }
}
