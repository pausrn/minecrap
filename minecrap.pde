/*
- cleanup des fonctions inutiles
- chunk : 
  - ajout des posX/chunkX pour la position dans le monde/dans le tableau de chunk (*16)
  - chaque chunk à son PShape qui est loadé dans son propre thread
    => fonction createRenderShape pour generer le PShape
    => ajout des variables isLoaded, isRendering et isRendered pour voir l'avancement du render par les autres threads
    => ajout de la fonction startThread qui permet de demarrer le thread dee render
    => ajout de la fonction renderShape pour creer le tableau de faces à render
- chunkManager
  => tout les chunks non remplis (bords du cercle d'affichage) auront l'id -1 dans le tableau chunkCoords
  => on repart sur un translate au render (translater tout les PShape etait trop lent)
  => ajout des fonction chunkLoadingFinished qui est activé par les chunks quand ils ont finis de loader/generer
     et de la fonction tryToRender pour render le chunk si tout ses voisins sont loadés
- leger changement dans le mouseMoved pour garder le lr et le ud du player dans l'intervalle [-PI;PI]
- !!! Le code éxecuté dans les thread semble pour une raison inconnue bloquer l'execution du thread principal (je sais pas pk et sa me fait chier un peu, a etudier)
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

boolean once=true;

inputManager im;

void setup() {
  //fullScreen(P3D);
  size(500, 500, P3D);

  //textureMode(NORMAL);
  noSmooth();
  hint(DISABLE_TEXTURE_MIPMAPS);

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
  
  //cm.createChunkShape();
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
    p.ud=constrain(p.ud-(mouseY-pmouseY)*sensi,-HALF_PI,HALF_PI);//map(mouseY,height,0,-HALF_PI,HALF_PI);
  } else resettingMouse=false;
  if (mouseX<width/4||mouseX>width/4*3||mouseY<height/4||mouseY>height/4*3) {
    r.mouseMove(windowX+width/2, windowY+height/2);
    resettingMouse=true;
  }
}
