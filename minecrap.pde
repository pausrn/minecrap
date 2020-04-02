/*
On est reparti de la v0.7 pour voir si ce qui ralentit tout quand on met un PShape par chunk c etait les appels multiples a texture
apparement c'est pas le cas parce que meme avec un texture par face pour tout les chunks on as tjr 30 fps. Mais apres en interne PShape (enfin PShapeOpenGL plus exactement)
il set la texture a chaque child d un group quand on applique une texture au group donc ca change rien. Donc soit il faut tout mettre dans un gros PShape comme en v0.7 mais ça va etre galere
a loader a chaque modif du monde, ou alors on trouve un moyen de mofdifier les vertex direct dans le vbo du PShape mais c est galere un peu.
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

float[] movement=new float[2];
int[] movementNb=new int[2];

final int FORWARD=103;
final int BACKWARD=104;
final int UPWARD=105;
final int DOWNWARD=106;

inputManager im;

void setup() {
  //fullScreen(P3D);
  size(500, 500, P3D);
  
  //textureMode(NORMAL);
  noSmooth();
  
  frameRate(1000);
  noCursor();
  
  float cameraZ=((height/2.0) / tan(PI*60.0/360.0));
  perspective(PI/3.0, (float)width/height, 0.1/*cameraZ/10.0*/, cameraZ*10.0);
  
  blocks=loadBlocks("blocksData.json");
  
  p=new player();
  p.moveTo(0, 0, 0);
  
  cm=new chunkManager(blocks,p,10);
  
  p.cm=cm;
  
  im=new inputManager(p);

  PGraphicsOpenGL gl=((PGraphicsOpenGL)g);
  gl.textureSampling(2);

  GLWindow win=(com.jogamp.newt.opengl.GLWindow)getSurface().getNative();
  windowX=win.getX();
  windowY=win.getY();

  try {
    r=new Robot();
  }
  catch(AWTException e) {
    e.printStackTrace();
  }
  cm.createChunkShape();
}

void draw() {
  background(255);
  
  //directionalLight(255,255,200, -0.5, 1, -.1);

  camera(p.x, p.y-1, p.z, p.x-sin(p.lr)*cos(p.ud), p.y-1-sin(p.ud), p.z-cos(p.lr)*cos(p.ud), 0, 1, 0);

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
  text(frameRate+"\n"+p.x+";"+p.y+";"+p.z+"\n"+p.lr+";"+p.ud, 10, 10 + textAscent());
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
    p.ud=constrain(p.ud-(mouseY-pmouseY)*sensi,-HALF_PI,HALF_PI);//map(mouseY,height,0,-HALF_PI,HALF_PI);
  } else resettingMouse=false;
  if (mouseX<width/4||mouseX>width/4*3||mouseY<height/4||mouseY>height/4*3) {
    r.mouseMove(windowX+width/2, windowY+height/2);
    resettingMouse=true;
  }
}
