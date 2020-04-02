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
    createRenderShape();
  }
  
  void createRenderShape(){
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
