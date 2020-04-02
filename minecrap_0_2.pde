//import peasy.PeasyCam;

//PeasyCam cam;

block[] blocks;
chunck c;

player p;

void setup() {
  size(500, 500, P3D);
  blocks=loadBlocks("blocksData.json");
  c=new chunck(blocks);
  PGraphicsOpenGL gl=((PGraphicsOpenGL)g);
  gl.textureSampling(3);

  p=new player();
  p.moveTo(0,0,0);
  //cam = new PeasyCam(this, 400);
}
void draw(){
  background(255);
  p.lr=map(mouseX,0,width,-PI,PI);
  p.ud=map(mouseY,height,0,-HALF_PI,HALF_PI);
  if(keyPressed){
    switch(key){
      case 'z':
        p.move(p.speed*cos(p.lr),0,p.speed*sin(p.lr));
      break;
      case 'q':
        p.move(p.speed*sin(p.lr),0,-p.speed*cos(p.lr));
      break;
      case 's':
        p.move(-p.speed*cos(p.lr),0,-p.speed*sin(p.lr));
      break;
      case 'd':
        p.move(-p.speed*sin(p.lr),0,p.speed*cos(p.lr));
      break;
      case ' ':
        p.move(0,-p.speed,0);
      break;
    }
    if(key==CODED) switch(keyCode){
      case SHIFT:
        p.move(0,p.speed,0);
      break;
    }
  }
  camera(p.rx,p.ry-100,p.rz,p.rx+cos(p.lr),p.ry-100-sin(p.ud),p.rz+sin(p.lr),0,1,0);
  beginShape(LINES);
  stroke(255,0,0);
  vertex(0,0,0);
  vertex(100,0,0);
  stroke(0,255,0);
  vertex(0,0,0);
  vertex(0,100,0);
  stroke(0,0,255);
  vertex(0,0,0);
  vertex(0,0,100);
  endShape();

  fill(0);
  text(frameRate,10,10);
  noStroke();
  stroke(0);
  noFill();
  c.render(p);

  camera();
  hint(DISABLE_DEPTH_TEST);
  noLights();
  textMode(MODEL);
  text(frameRate, 10, 10 + textAscent());
  text(p.x+";"+p.y+";"+p.z,10,35);
  hint(ENABLE_DEPTH_TEST);
}

void keyPressed(){

}
