/*
- changement des coordonnées des sommets du bloc pour avoir une orientation de textures constante
- utilisation d'une texture globale par cube au lieu d'une texture par face
- ajout d'une variable dans la class bloc pour le nom
- les texture ne sont appeles qu une fois par type de bloc (i.e tout les blocks d un meme type sont consideres comme une shape)
- suppression de la fonction "ray"
- changement du mouvement de la camera
- changement du mouvement dans l espace (support pour multi-touches)
- les coordonnées de render sont maintenant les memes que les coordonnées de save (avant elles etaient *100) 
  --> changement du champ de vue pour activer la vision des object proches (<0.1)
*/

import java.awt.Robot;
import java.awt.AWTException;
import com.jogamp.newt.opengl.GLWindow;

//import peasy.PeasyCam;

//PeasyCam cam;

block[] blocks;
chunck c;

player p;

Robot r;
int windowX, windowY;
float sensi=0.01;

int[] movement=new int[0];

final int FORWARD=103;
final int BACKWARD=104;
final int UPWARD=105;
final int DOWNWARD=106;

void setup() {
  //fullScreen(P3D);
  size(500, 500, P3D);
  frameRate(1000);
  noCursor();

  blocks=loadBlocks("blocksData.json");
  c=new chunck(blocks);

  PGraphicsOpenGL gl=((PGraphicsOpenGL)g);
  gl.textureSampling(3);

  GLWindow win=(com.jogamp.newt.opengl.GLWindow)getSurface().getNative();
  windowX=win.getX();
  windowY=win.getY();

  try {
    r=new Robot();
  }
  catch(AWTException e) {
    e.printStackTrace();
  }

  p=new player();
  p.moveTo(0, 0, 0);
  //cam = new PeasyCam(this, 400);
  float cameraZ=((height/2.0) / tan(PI*60.0/360.0));
  ;
  perspective(PI/3.0, (float)width/height, 0.1/*cameraZ/10.0*/, cameraZ*10.0);
}
void draw() {
  background(255);

  for (int i=0; i<movement.length; i++) switch(movement[i]) {
  case FORWARD:
    p.move(p.speed*cos(p.lr), 0, p.speed*sin(p.lr));
    break;
  case LEFT:
    p.move(p.speed*sin(p.lr), 0, -p.speed*cos(p.lr));
    break;
  case RIGHT:
    p.move(-p.speed*sin(p.lr), 0, p.speed*cos(p.lr));
    break;
  case BACKWARD:
    p.move(-p.speed*cos(p.lr), 0, -p.speed*sin(p.lr));
    break;
  case UPWARD:
    p.move(0, -p.speed, 0);
    break;
  case DOWNWARD:
    p.move(0, p.speed, 0);
    break;
  }

  camera(p.x, p.y-1, p.z, p.x+cos(p.lr), p.y-1-sin(p.ud), p.z+sin(p.lr), 0, 1, 0);

  beginShape(LINES);
  stroke(255, 0, 0);
  vertex(p.x+cos(p.lr), p.y-1-sin(p.ud), p.z+sin(p.lr));
  vertex(p.x+cos(p.lr)+0.1, p.y-1-sin(p.ud), p.z+sin(p.lr));
  stroke(0, 255, 0);
  vertex(p.x+cos(p.lr), p.y-1-sin(p.ud), p.z+sin(p.lr));
  vertex(p.x+cos(p.lr), p.y-1-sin(p.ud)+0.1, p.z+sin(p.lr));
  stroke(0, 0, 255);
  vertex(p.x+cos(p.lr), p.y-1-sin(p.ud), p.z+sin(p.lr));
  vertex(p.x+cos(p.lr), p.y-1-sin(p.ud), p.z+sin(p.lr)+0.1);
  endShape();

  noStroke();
  //stroke(0);
  noFill();
  c.render(p);

  fill(0);
  camera();
  hint(DISABLE_DEPTH_TEST);
  noLights();
  textMode(MODEL);
  textSize(20);
  text(frameRate+"\n"+p.x+";"+p.y+";"+p.z, 10, 10 + textAscent());
  //text(p.x+";"+p.y+";"+p.z,10,35);
  hint(ENABLE_DEPTH_TEST);
}

import java.awt.event.KeyEvent.*;

void keyPressed() {
  /*KeyEvent e=(java.awt.event.KeyEvent)event;
   println("aaa"+event.isActionKey());*/
  if (key==CODED) switch(keyCode) {
  case SHIFT:
    movement=append(movement, DOWNWARD);
    break;
  } else switch(Character.toLowerCase(key)) {
  case 'z':
    movement=append(movement, FORWARD);
    break;
  case 'q':
    movement=append(movement, LEFT);
    break;
  case 's':
    movement=append(movement, BACKWARD);
    break;
  case 'd':
    movement=append(movement, RIGHT);
    break;
  case ' ':
    movement=append(movement, UPWARD);
    break;
  }
}
void keyReleased() {
  if (key==CODED) switch(keyCode) {
  case SHIFT:
    movement=rmEl(movement, DOWNWARD);
    break;
  } else switch(Character.toLowerCase(key)) {
  case 'z':
    movement=rmEl(movement, FORWARD);
    break;
  case 'q':
    movement=rmEl(movement, LEFT);
    break;
  case 's':
    movement=rmEl(movement, BACKWARD);
    break;
  case 'd':
    movement=rmEl(movement, RIGHT);
    break;
  case ' ':
    movement=rmEl(movement, UPWARD);
    break;
  }
}

void keyEvent(KeyEvent ev) {
  println(ev);
}

int[] rmAct(int[] array, int id) {
  for (int i=0; i<array.length; i++) if (array[i]==id) {
    return rmEl(array, i);
  }
  return array;
}

int[] rmEl(int[] array, int ind) {
  for (int i=ind; i<array.length-1; i++) array[i]=array[i+1];
  if (array.length>0) array=shorten(array);
  return array;
}

boolean resettingMouse=false;
void mouseMoved(MouseEvent e) {
  if (!resettingMouse) {
    p.lr+=(mouseX-pmouseX)*sensi;//map(mouseX,0,width,-PI,PI);
    p.ud-=(mouseY-pmouseY)*sensi;//map(mouseY,height,0,-HALF_PI,HALF_PI);
  } else resettingMouse=false;
  if (mouseX<width/4||mouseX>width/4*3||mouseY<height/4||mouseY>height/4*3) {
    r.mouseMove(windowX+width/2, windowY+height/2);
    resettingMouse=true;
  }
}
