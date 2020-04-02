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
  new int[]{1,1,0, 0,1,0, 0,0,0, 1,0,0}, //south
  new int[]{0,1,0, 0,1,1, 0,0,1, 0,0,0}, //est
  new int[]{0,1,1, 1,1,1, 1,0,1, 0,0,1}, //north
  new int[]{1,1,1, 1,1,0, 1,0,0, 1,0,1}, //west
  new int[]{0,0,1, 1,0,1, 1,0,0, 0,0,0}, //top
  new int[]{0,1,1, 1,1,1, 1,1,0, 0,1,0} //bottom
};

int[][] uvCoords={
  new int[]{16,48},
  new int[]{16,32},
  new int[]{16,16},
  new int[]{16,0},
  new int[]{0,16},
  new int[]{32,16},
};

int[][] coordsForMapping={
  new int[]{0,1},
  new int[]{2,1},
  new int[]{0,1},
  new int[]{2,1},
  new int[]{0,2},
  new int[]{0,2},
};

class block {
  PImage up, sides, bottom,merged;
  String name;

  block(String name) {
    this.up=loadImage(name+"/top.png");
    this.sides=loadImage(name+"/sides.png");
    this.bottom=loadImage(name+"/bottom.png");
    this.merged=loadImage(name+"/merged.png");
    this.name=name;
  }

  void draw(int x,int y,int z,int[] facesToRender) {
    for (int i=0; i<facesToRender.length; i++) {
      int faceId=facesToRender[i];
      int[] c=boxCoords[faceId];
      for (int j=0; j<c.length; j+=3) {
        vertex((x+c[j]),(y+c[j+1]),(z+c[j+2]),uvCoords[faceId][0]+16*c[j+coordsForMapping[faceId][0]],uvCoords[faceId][1]+16*c[j+coordsForMapping[faceId][1]]);
      }
    }
  }
}

int[][] order={
  new int[]{0,0,-1},
  new int[]{-1,0,0},
  new int[]{0,0,1},
  new int[]{1,0,0},
  new int[]{0,-1,0},
  new int[]{0,1,0}
};

class chunk {
  int[][][] blocksData=new int[16][256][16];
  block[] blocks;

  chunk(block[] blocks) {
    //for(int y=0;y<16;y++) for(int z=0;z<16;z++) blocksData[15][y][z]=1;
    //blocksData[10][10][15]=1;
    //for(int x=-1;x<=1;x++) for(int y=-1;y<=1;y++) blocksData[x+10][y+10][14]=1;
    //blocksData[1][0][0]=1;
    //for(int x=-1;x<=1;x++) for(int y=-1;y<=1;y++) for(int z=-1;z<=1;z++) blocksData[10+x][10+y][10+z]=1;
    for (int x=0; x<blocksData.length; x++) for (int y=0; y<blocksData.length; y++) for (int z=0; z<blocksData[0][0].length; z++) blocksData[x][y][z]=(int)random(0,3);
    this.blocks=blocks;
  }
  
  void render(player p) {
    for(int i=0;i<blocks.length-1;i++){
      beginShape(QUADS);
      texture(blocks[i].merged);
      for (int x=0; x<blocksData.length; x++) {
        for (int y=0; y<blocksData[0].length; y++) {
          for (int z=0; z<blocksData[0][0].length; z++) {
            if(blocksData[x][y][z]==i+1){
              int[] faces=shouldRender(x, y, z,p);
              blocks[i].draw(x,y,z,faces);
            }
          }
        }
      }
      endShape();
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
    
    return facesToRender;
  }
  
  boolean rayToPlayer(int ox,int oy,int oz,int faceId,player p){
    boolean hitBlock=false;
    for(int j=0;j<boxCoords[faceId].length;j+=3){
      int vx=ox+boxCoords[faceId][j];
      int vy=oy+boxCoords[faceId][j+1];
      int vz=oz+boxCoords[faceId][j+2];
      
      float x=p.x-vx;
      float y=p.y-1-vy;
      float z=p.z-vz;
      
      float rad=sqrt(sq(x)+sq(y)+sq(z));
      float theta=atan2(x,z);
      float omega=atan2(sqrt(sq(x)+sq(z)),y);
      
      float coeffX=sin(theta)*sin(omega);
      float coeffY=cos(omega);
      float coeffZ=cos(theta)*sin(omega);
      
      thisRay:
      for(int d=1;d<rad;d++){
        int cx=vx+floor(coeffX*d);
        int cy=vy+floor(coeffY*d);
        int cz=vz+floor(coeffZ*d);
        while(cx==ox&&cy==oy&&cz==oz){
          d++;
          if(d>rad){
            break thisRay;
          }
          cx=vx+floor(coeffX*d);
          cy=vy+floor(coeffY*d);
          cz=vz+floor(coeffZ*d);
        }
        
        if(!isIn(cx,0,blocksData.length)||!isIn(cy,0,blocksData[0].length)||!isIn(cz,0,blocksData[0][0].length)){
          return true;
        }
        if(blocksData[cx][cy][cz]!=0){
          hitBlock=true;
          break;
        }
      }
    }
    if(!hitBlock) return true;
    return false;
  }
}

class chunkManager{
  chunk[] chunks;
  int renderDist=3;
  
  chunkManager(){
    
  }
}

boolean isIn(int val,int min,int max){
  return val>=min&&val<max;
}
