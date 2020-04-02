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

float[][] uvCoords={
  new float[]{16.5,48.5},
  new float[]{16.5,32.5},
  new float[]{16.5,16.5},
  new float[]{16.5,0.5},
  new float[]{0.5,16.5},
  new float[]{32.5,16.5},
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
        //println(uvCoords[faceId][0]+15*c[j+coordsForMapping[faceId][0]],uvCoords[faceId][1]+15*c[j+coordsForMapping[faceId][1]]);
        vertex((x+c[j]),(y+c[j+1]),(z+c[j+2]),uvCoords[faceId][0]+15*c[j+coordsForMapping[faceId][0]],uvCoords[faceId][1]+15*c[j+coordsForMapping[faceId][1]]);
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
  int[][][][] renderBlocks;
  block[] blocks;
  chunkLoader cLoad;
  Thread loadThread;
  int px,py;

  chunk(block[] blocks,int px,int py) {
    this.blocks=blocks;
    this.renderBlocks=new int[blocks.length-1][0][2][];
    this.px=px;
    this.py=py;
    cLoad=new chunkLoader(this);
  }
  
  void render(int apx,int apy){
    for(int i=0;i<blocks.length-1;i++){
      beginShape(QUADS);
      texture(blocks[i].merged);
      for(int j=0;j<renderBlocks[i].length;j++){
        int[] pos=renderBlocks[i][j][0];
        blocks[i].draw(pos[0]+px+apx,pos[1],pos[2]+py+apy,renderBlocks[i][j][1]);
      }
      endShape();
    }
  }

  int[] shouldRender(int ox, int oy, int oz){
    int[] tempFaces=new int[6];
    int ind=0;
    
    for(int i=0;i<6;i++){
      int x=ox+order[i][0];
      int y=oy+order[i][1];
      int z=oz+order[i][2];
      if(!isIn(x,0,blocksData.length)||!isIn(y,0,blocksData[0].length)||!isIn(z,0,blocksData[0][0].length)||blocksData[x][y][z]==0){
        tempFaces[ind]=i;
        ind++;
      }
    }
    
    int[] facesToRender=new int[ind];
    arrayCopy(tempFaces,facesToRender,ind);
    //for(int i=0;i<ind;i++) facesToRender[i]=tempFaces[i];
    
    return facesToRender;
  }
  
  void generate(){
    for(int x=0; x<blocksData.length; x++) for (int y=0; y<blocksData.length; y++) for (int z=0; z<blocksData[0][0].length; z++) blocksData[x][y][z]=1;//(int)random(0,3);
    for(int x=0; x<blocksData.length; x++) for (int y=0; y<blocksData[0].length; y++) for (int z=0; z<blocksData[0][0].length; z++) if(blocksData[x][y][z]!=0){
      int[] faces=shouldRender(x,y,z);
      renderBlocks[blocksData[x][y][z]-1]=(int[][][])append(renderBlocks[blocksData[x][y][z]-1],new int[][]{new int[]{x,y,z},faces});
    }
  }
}

class chunkLoader implements Runnable{
  chunk c;
  
  chunkLoader(chunk c){
    this.c=c;
  }
  
  void run(){
    c.generate();
  }
}

class chunkManager{
  chunk[] chunk;
  block[] blocks;
  player p;
  int[][] chunkCoords;
  int renderDist=3;
  int px,py;
  
  chunkManager(block[] blocks,player p,int rd){
    this.blocks=blocks;
    this.p=p;
    px=0;
    py=0;
    
    renderDist=rd;
    int area=0;
    for(int x=-renderDist;x<renderDist;x++) for(int y=-renderDist;y<renderDist;y++) if(abs(x+0.5)<sqrt(1-sq((float)(y+0.5)/renderDist))*renderDist) area++;
    chunk=new chunk[area];
    chunkCoords=new int[2*rd][2*rd];
    int ind=0;
    for(int x=-renderDist;x<renderDist;x++) for(int y=-renderDist;y<renderDist;y++) if(abs(x+0.5)<sqrt(1-sq((float)(y+0.5)/renderDist))*renderDist){
      chunkCoords[x+rd][y+rd]=ind;
      chunk[ind]=new chunk(blocks,x<<4,y<<4);
      chunk[ind].loadThread=new Thread(chunk[ind].cLoad);
      chunk[ind].loadThread.start();
      ind++;
    }
  }
  
  void render(){
    for(int x=0;x<chunkCoords.length;x++) for(int y=0;y<chunkCoords[0].length;y++){
      chunk cc=chunk[chunkCoords[x][y]];
      /*if(isInView(cc))*/ cc.render(px<<4,py<<4);
    }
  }
  
  void updateChunk(){
    int cx=floor(p.x)>>4;
    int cy=floor(p.z)>>4;
    if(cx!=px||cy!=py){
      px=cx;
      py=cy;
    }
  }
  
  boolean isInView(chunk c){
    float ang=PI-atan2((c.py+8-p.y),-(c.px+8-p.x))%PI;
    float dist=abs(ang-p.lr)%PI;
    
    return false;
    //return (ang>angMin&&ang<angMax);
  }
}

boolean isIn(int val,int min,int max){
  return val>=min&&val<max;
}
