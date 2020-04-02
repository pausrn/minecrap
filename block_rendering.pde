block[] loadBlocks(String jsonPath) {
  JSONArray blocks=loadJSONArray(jsonPath);
  block[] out=new block[blocks.size()-1];
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

int[][] coordsForMapping={
  new int[]{0,1},
  new int[]{2,1},
  new int[]{0,1},
  new int[]{2,1},
  new int[]{0,2},
  new int[]{0,2},
};

class block {
  PImage[] tex=new PImage[6];
  String name;

  block(String name){
    tex[0]=loadImage(name+"/sides.png");
    for(int i=1;i<4;i++) tex[i]=tex[0];
    tex[4]=loadImage(name+"/top.png");
    tex[5]=loadImage(name+"/bottom.png");
    this.name=name;
  }

  void draw(int x,int y,int z,int[] facesToRender) {
    for (int i=0; i<facesToRender.length; i++) {
      int faceId=facesToRender[i];
      int[] c=boxCoords[faceId];
      for (int j=0; j<c.length; j+=3) {
        vertex((x+c[j]),(y+c[j+1]),(z+c[j+2]),c[j+coordsForMapping[faceId][0]]<<4,c[j+coordsForMapping[faceId][1]]<<4);
      }
    }
  }
  
  void draw(int x,int y,int z,int faceToRender) {
    int[] c=boxCoords[faceToRender];
    for (int j=0; j<c.length; j+=3) {
      vertex((x+c[j]),(y+c[j+1]),(z+c[j+2]),c[j+coordsForMapping[faceToRender][0]]<<4,c[j+coordsForMapping[faceToRender][1]]<<4);
    }
  }
  
  void draw(int x,int y,int z,int faceToRender,PShape shape) {
    int[] c=boxCoords[faceToRender];
    for (int j=0; j<c.length; j+=3) {
      shape.vertex((x+c[j]),(y+c[j+1]),(z+c[j+2]),c[j+coordsForMapping[faceToRender][0]]<<4,c[j+coordsForMapping[faceToRender][1]]<<4);
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
    this.renderBlocks=new int[blocks.length][boxCoords.length][0][3];
    this.px=px;
    this.py=py;
    cLoad=new chunkLoader(this);
  }
  
  void render(int apx,int apy){
    for(int i=0;i<blocks.length-1;i++){
      beginShape(QUADS);
      for(int k=0;k<6;k++){
        texture(blocks[i].tex[0]);
        for(int j=0;j<renderBlocks[i][k].length;j++){
          int[] pos=renderBlocks[i][k][j];
          blocks[i].draw(pos[0]+px+apx,pos[1],pos[2]+py+apy,new int[]{k}/*renderBlocks[i][j][1]*/);
        }
      }
      endShape();
    }
  }
  
  void render(int apx,int apy,int blockId,int faceId){
    for(int j=0;j<renderBlocks[blockId][faceId].length;j++){
      int[] pos=renderBlocks[blockId][faceId][j];
      blocks[blockId].draw(pos[0]+px+apx,pos[1],pos[2]+py+apy,faceId);
    }
  }
  
  void render(int apx,int apy,int blockId,int faceId,PShape shape){
    for(int j=0;j<renderBlocks[blockId][faceId].length;j++){
      int[] pos=renderBlocks[blockId][faceId][j];
      blocks[blockId].draw(pos[0]+px+apx,pos[1],pos[2]+py+apy,faceId,shape);
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
      for(int i=0;i<faces.length;i++) renderBlocks[blocksData[x][y][z]-1][faces[i]]=(int[][])append(renderBlocks[blocksData[x][y][z]-1][faces[i]],new int[]{x,y,z});
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
  PShape[] chunkShapes;
  
  chunkManager(block[] blocks,player p,int rd){
    this.blocks=blocks;
    this.p=p;
    px=0;
    py=0;
    
    renderDist=rd;
    int area=0;
    for(int x=-renderDist;x<renderDist;x++) for(int y=-renderDist;y<renderDist;y++) if(abs(x+0.5)<sqrt(1-sq((float)(y+0.5)/renderDist))*renderDist) area++;
    chunk=new chunk[area];
    chunkShapes=new PShape[area];
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
  
  void renderAll(){
    for(int blockId=0;blockId<blocks.length;blockId++){
      for(int faceId=0;faceId<boxCoords.length;faceId++){
        beginShape(QUADS);
        texture(blocks[blockId].tex[faceId]);
        for(int x=0;x<chunkCoords.length;x++) for(int y=0;y<chunkCoords[0].length;y++){
          chunk cc=chunk[chunkCoords[x][y]];
          /*if(isInView(cc))*/ cc.render(px<<4,py<<4,blockId,faceId);
        }
        endShape();
      }
    }
  }
  
  void createChunkShape(){
    for(int x=0;x<chunkCoords.length;x++) for(int y=0;y<chunkCoords[0].length;y++){
      int ind=chunkCoords[x][y];
      chunk cc=chunk[ind];
      chunkShapes[ind]=createShape(GROUP);
      chunkShapes[ind].disableStyle();
      for(int blockId=0;blockId<blocks.length;blockId++) for(int faceId=0;faceId<boxCoords.length;faceId++){
        PShape cchunk=createShape();
        cchunk.setTexture(blocks[blockId].tex[faceId]);
        cchunk.beginShape(QUADS);
        cc.render(px<<4,py<<4,blockId,faceId,cchunk);
        cchunk.endShape();
        chunkShapes[ind].addChild(cchunk);
      }
    }
    
    /*chunkShape=createShape(GROUP);
    chunkShape.disableStyle();
    
    for(int blockId=0;blockId<blocks.length;blockId++){
      for(int faceId=0;faceId<boxCoords.length;faceId++){
        PShape cchunk=createShape();
        cchunk.setTexture(blocks[blockId].tex[faceId]);
        cchunk.beginShape(QUADS);
        for(int x=0;x<chunkCoords.length;x++) for(int y=0;y<chunkCoords[0].length;y++){
          chunk cc=chunk[chunkCoords[x][y]];
          cc.render(px<<4,py<<4,blockId,faceId,cchunk);
        }
        cchunk.endShape();
        chunkShape.addChild(cchunk);
      }
    }*/
  }
  
  void renderShape(){
    translate(px<<4,0,py<<4);
    for(int i=0;i<chunkShapes.length;i++) if(isInView(chunk[i])) shape(chunkShapes[i]);
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
    float ang=HALF_PI+atan2((c.py+8-p.y),-(c.px+8-p.x))%PI;
    
    if(angDif(ang,p.lr)<p.fov/2) return true;
    return false;
    //return true;
    //return (ang>angMin&&ang<angMax);
  }
}

boolean isIn(int val,int min,int max){
  return val>=min&&val<max;
}

float angDif(float ang1,float ang2){
  float diff=abs(ang1-ang2);
  if(diff > PI) diff = TWO_PI-diff;
  return diff;
}
