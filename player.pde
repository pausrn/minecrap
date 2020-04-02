class player{
  float x,y,z;
  int rx,ry,rz;
  float lr,ud;
  float speed=0.1;
  
  player(){
    
  }
  
  void move(float x,float y,float z){
    this.x+=x;
    this.y+=y;
    this.z+=z;
    
    rx+=round(x*100);
    ry+=round(y*100);
    rz+=round(z*100);
  }
  
  void moveTo(float x,float y,float z){
    this.x=x;
    this.y=y;
    this.z=z;
    
    rx=round(x*100);
    ry=round(y*100);
    rz=round(z*100);
  }
}
