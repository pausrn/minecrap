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
  int[][][][] renderBlocks;
  block[] blocks;
  chunkLoader cLoad;
  Thread loadThread;
  int px,py;

  chunk(block[] blocks,int px,int py) {
    //for(int y=0;y<16;y++) for(int z=0;z<16;z++) blocksData[15][y][z]=1;
    //blocksData[10][10][15]=1;
    //for(int x=-1;x<=1;x++) for(int y=-1;y<=1;y++) blocksData[x+10][y+10][14]=1;
    //blocksData[1][0][0]=1;
    //for(int x=-1;x<=1;x++) for(int y=-1;y<=1;y++) for(int z=-1;z<=1;z++) blocksData[10+x][10+y][10+z]=1;
    //for (int x=0; x<blocksData.length; x++) for (int y=0; y<blocksData.length; y++) for (int z=0; z<blocksData[0][0].length; z++) blocksData[x][y][z]=(int)random(0,3);
    this.blocks=blocks;
    this.renderBlocks=new int[blocks.length-1][0][2][];
    this.px=px;
    this.py=py;
    cLoad=new chunkLoader(this);
  }
  
  void render() {
    for(int i=0;i<blocks.length-1;i++){
      beginShape(QUADS);
      texture(blocks[i].merged);
      for(int j=0;j<renderBlocks[i].length;j++){
        int[] pos=renderBlocks[i][j][0];
        blocks[i].draw(pos[0]+px,pos[1],pos[2]+py,renderBlocks[i][j][1]);
      }
      /*for (int x=0; x<blocksData.length; x++) {
        for (int y=0; y<blocksData[0].length; y++) {
          for (int z=0; z<blocksData[0][0].length; z++) {
            if(blocksData[x][y][z]==i+1){
              int[] faces=shouldRender(x, y, z);
              blocks[i].draw(x+px,y,z+py,faces);
            }
          }
        }
      }*/
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
      if(!isIn(x,0,blocksData.length-1)||!isIn(y,0,blocksData[0].length-1)||!isIn(z,0,blocksData[0][0].length-1)||blocksData[x][y][z]==0){
        tempFaces[ind]=i;
        ind++;
      }
    }
    
    int[] facesToRender=new int[ind];
    for(int i=0;i<ind;i++) facesToRender[i]=tempFaces[i];
    
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
  
  chunkManager(block[] blocks,player p,int rd){
    this.blocks=blocks;
    this.p=p;
    
    renderDist=rd;
    int area=0;
    for(int x=-renderDist;x<renderDist;x++) for(int y=-renderDist;y<renderDist;y++) if(abs(x+0.5)<sqrt(1-sq((float)(y+0.5)/renderDist))*renderDist) area++;
    chunk=new chunk[area];
    chunkCoords=new int[2*rd][2*rd];
    int ind=0;
    for(int x=-renderDist;x<renderDist;x++) for(int y=-renderDist;y<renderDist;y++) if(abs(x+0.5)<sqrt(1-sq((float)(y+0.5)/renderDist))*renderDist){
      chunkCoords[x+rd][y+rd]=ind;
      chunk[ind]=new chunk(blocks,x*16,y*16);
      chunk[ind].loadThread=new Thread(chunk[ind].cLoad);
      chunk[ind].loadThread.start();
      ind++;
    }
  }
  
  void render(){
    for(int x=0;x<chunkCoords.length;x++) for(int y=0;y<chunkCoords[0].length;y++){
      chunk cc=chunk[chunkCoords[x][y]];
      if(isInView(cc)) cc.render();
    }
  }
  
  boolean isInView(chunk c){
    float ang=TWO_PI-(atan2((c.py+8),-(c.px+8))+PI);
    return (ang>(p.lr-p.fov)%TWO_PI&&ang<(p.lr+p.fov)%TWO_PI);
  }
}

boolean isIn(int val,int min,int max){
  return val>=min&&val<max;
}
