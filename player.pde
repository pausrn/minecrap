class player{
  float x,y,z;
  float fov=PI/3.0;
  float lr=0,ud=0;
  float speed=0.5;
  
  player(){
    
  }
  
  void move(float x,float y,float z){
    this.x+=x;
    this.y+=y;
    this.z+=z;
  }
  
  void moveTo(float x,float y,float z){
    this.x=x;
    this.y=y;
    this.z=z;
  }
}
