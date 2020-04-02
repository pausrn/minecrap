Float[][] ang={
  new Float[]{0.0,null},        //FORWARD
  new Float[]{HALF_PI,null},    //LEFT
  new Float[]{PI,null},         //BACKWARD
  new Float[]{-HALF_PI,null},   //RIGHT
  new Float[]{null,-HALF_PI},    //UP
  new Float[]{null,HALF_PI},   //DOWN
};

int[] keyBinds={
  'z',   //forward
  'q',   //left
  's',   //backward
  'd',   //right
  ' ',   //up
  SHIFT  //down
};

class inputManager{
  player p;
  float[] angs=new float[2];
  int[] nbOfInp=new int[2];
  
  
  
  inputManager(player p){
    this.p=p;
  }
  
  void keyPressed(){
    int cKey=Character.toLowerCase(key);
    if(key==CODED) cKey=keyCode;
    
    for(int i=0;i<keyBinds.length;i++) if(keyBinds[i]==cKey) for(int j=0;j<ang[i].length;j++) if(ang[i][j]!=null){
      angs[j]+=ang[i][j];
      nbOfInp[j]++;
    }
  }
  void keyReleased(){
    int cKey=Character.toLowerCase(key);
    if(key==CODED) cKey=keyCode;
    
    for(int i=0;i<keyBinds.length;i++) if(keyBinds[i]==cKey) for(int j=0;j<ang[i].length;j++) if(ang[i][j]!=null){
      angs[j]-=ang[i][j];
      nbOfInp[j]--;
    }
  }
  
  float[] getAngs(){
    float[] out=new float[2];
    boolean stopped=true;
    for(int i=0;i<out.length;i++) if(nbOfInp[i]>0){
      out[i]=angs[i]/nbOfInp[i];
      stopped=false;
    }
    //printArray(out);
    if(stopped) return null;
    return out;
  }
}
