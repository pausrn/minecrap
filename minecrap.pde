/*
- changement de la facon dont les mouvements sont gérés (coordonnées spheriques pour le mouvement a effectuer)
  --> ajout de la class InputManager
- essai pour faire disparaitre les espaces entre le bocks a distance (texture_sampling a 2 et mipmaps_disabled; changement des coords u/v)
- ajout d'une lumiere directionnelle
- changement des mouvements de camera pour eviter l inversion de sens en haut/bas
- les chunks peuvent mnt etre render a une position
- changement de l'offset pour verifier si un bloc doit etre dessiner (au bordure deux blocks etaient desinees au lieu d'un)
- utilisation d'ArrayCopy au lieu d'une boucle for pour la creation des tableau facesToRender
- le monde est maintenant infini
  --> ajout d une pX et pY pour le chunkMananger
  --> ajout de la fonction update chunk pour verifier si le joueur est sorti du chunk est le cas echeant modifier les chuunks loadés (actuellemtn la fonction translate juste les chunk pour etre au niveau du joueur)
- changement de la fonction pour voir si un chunk doit etre render (marche toujours pas)
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
  hint(DISABLE_TEXTURE_MIPMAPS);
  
  frameRate(1000);
  noCursor();
  
  float cameraZ=((height/2.0) / tan(PI*60.0/360.0));
  perspective(PI/3.0, (float)width/height, 0.1/*cameraZ/10.0*/, cameraZ*10.0);
  
  blocks=loadBlocks("blocksData.json");
  
  p=new player();
  p.moveTo(0, 0, 0);
  
  cm=new chunkManager(blocks,p,3);
  
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
}

void draw() {
  background(255);
  
  directionalLight(255,255,150, -0.5, 1, 0);

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
  cm.render();
  
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
