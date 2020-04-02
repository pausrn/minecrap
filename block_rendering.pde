
block[] loadBlocks(String jsonPath) {
  JSONArray blocks=loadJSONArray(jsonPath);
  block[] out=new block[blocks.size()];
  for (int i=0; i<blocks.size()-1; i++) {
    JSONObject obj=blocks.getJSONObject(i+1);
    String name=obj.getString("name");
    out[i]=new block(name);
  }
  return out;
}

int[][] boxCoords={
  new int[]{0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 1}, //south
  new int[]{1, 1, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1}, //est
  new int[]{0, 1, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0}, //north
  new int[]{0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1}, //west
  new int[]{0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0}, //top
  new int[]{0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0} //bottom
};

class block {
  PImage up, sides, bottom;

  block(String name) {
    this.up=loadImage(name+"/top.png");
    this.sides=loadImage(name+"/sides.png");
    this.bottom=loadImage(name+"/bottom.png");
  }

  void draw(int[] facesToRender) {
    //println(facesToRender.length);
    for (int i=0; i<facesToRender.length; i++) {
      int faceId=facesToRender[i];
      //pushMatrix();
      beginShape();
      if (faceId<4) texture(this.sides);
      else if (faceId==4) texture(this.bottom);
      else if (faceId==5) texture(this.up);
      else texture(this.up);
      int[] c=boxCoords[faceId];
      for (int j=0; j<c.length; j+=3) {
        int jm=j/3;
        vertex(c[j]*100,c[j+1]*100,c[j+2]*100,jm==0|jm==3?16:0,jm==1|jm==0?16:0);
      }
      endShape();
      //popMatrix();
    }
  }
}

int[][] order={
  new int[]{0,0,1},
  new int[]{1,0,0},
  new int[]{0,0,-1},
  new int[]{-1,0,0},
  new int[]{0,1,0},
  new int[]{0,-1,0}
};

class chunck {
  int[][][] blocksData=new int[16][256][16];
  block[] blocks;

  chunck(block[] blocks) {
    blocksData[0][0][0]=1;
    //for (int x=0; x<blocksData.length; x++) for (int y=0; y<blocksData.length; y++) for (int z=0; z<blocksData[0][0].length; z++) blocksData[x][y][z]=(int)random(0,3);
    this.blocks=blocks;
  }
  void render(player p) {
    for (int x=0; x<blocksData.length; x++) {
      pushMatrix();
      for (int y=0; y<blocksData[0].length; y++) {
        pushMatrix();
        for (int z=0; z<blocksData[0][0].length; z++) {
          if(blocksData[x][y][z]!=0){
            int[] faces=shouldRender(x, y, z,p);
            blocks[blocksData[x][y][z]-1].draw(faces);
          }
          translate(0, 0, 100);
        }
        popMatrix();
        translate(0, 100, 0);
      }
      popMatrix();
      translate(100, 0, 0);
    }
  }

  int[] shouldRender(int ox, int oy, int oz,player p){
    
    int[] tempFaces=new int[6];
    int ind=0;
    
    for(int i=0;i<6;i++){
      int x=ox+order[i][0];
      int y=oy+order[i][1];
      int z=oz+order[i][2];
      if(!isIn(x,0,blocksData.length-1)||!isIn(y,0,blocksData[0].length-1)||!isIn(z,0,blocksData[0][0].length-1)||blocksData[x][y][z]==0){
        tempFaces[ind]=i;
        ind++;
      }
    }
    
    int[] facesToRender=new int[ind];
    for(int i=0;i<ind;i++) facesToRender[i]=tempFaces[i];
    
    pos=new int[0][3];
    for(int i=0;i<1/*facesToRender.length*/;i++){
      for(int j=0;j<1/*boxCoords[i].length*/;j+=3){
        float vx=ox+boxCoords[i][j];
        float vy=oy+boxCoords[i][j+1];
        float vz=oz+boxCoords[i][j+2];
        
        float x=p.x-vx;
        float y=p.y-vy;
        float z=p.z-vz;
        println(x,y,z);
        
        float rad=sqrt(sq(x)+sq(y)+sq(z));
        theta=atan2(x,z);
        omega=atan(sqrt(sq(x)+sq(z))/y);
        for(int d=0;d<rad;d++){
          int cx=round(cos(theta)*d);
          int cy=round(sin(omega)*d);
          int cz=round(sin(theta)*d);
          pos=(int[][])append(pos,new int[]{cx,cy,cz});
        }
      }
    }
    println(pos.length);
    for(int i=0;i<pos.length;i++) printArray(pos[i]);
    
    return facesToRender;
  }
}

boolean isIn(int val,int min,int max){
  return val>=min&&val<max;
}
