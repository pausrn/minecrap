int[][] order={
  new int[]{0,0,-1},
  new int[]{-1,0,0},
  new int[]{0,0,1},
  new int[]{1,0,0},
  new int[]{0,-1,0},
  new int[]{0,1,0}
};

import java.util.concurrent.atomic.AtomicBoolean;

class chunk {
  int[][][] blocksData=new int[16][256][16];
  int[][][][] renderBlocks;
  block[] blocks;
  chunkLoader cLoad;
  Thread loadThread;
  int px,py,chunkX,chunkY;
  PShape renderShape;
  chunkManager cm;
  AtomicBoolean isLoaded=new AtomicBoolean(false),isRendering=new AtomicBoolean(false),isRendered=new AtomicBoolean(false);

  chunk(chunkManager cm,block[] blocks,int chunkX,int chunkY) {
    this.cm=cm;
    this.blocks=blocks;
    this.renderBlocks=new int[blocks.length][boxCoords.length][0][3];
    this.chunkX=chunkX;
    this.chunkY=chunkY;
    this.px=chunkX*16;
    this.py=chunkY*16;

    cLoad=new chunkLoader(this);
  }
  
  void createRenderShape(int apx,int apy){
    renderShape=createShape(GROUP);
    for(int blockId=0;blockId<blocks.length;blockId++) for(int faceId=0;faceId<boxCoords.length;faceId++){
      PShape cchunk=createShape();
      //cchunk.disableStyle();
      cchunk.setTexture(blocks[blockId].tex[faceId]);
      cchunk.beginShape(QUADS);
      for(int j=0;j<renderBlocks[blockId][faceId].length;j++){
        int[] pos=renderBlocks[blockId][faceId][j];
        blocks[blockId].draw(pos[0]+px+apx,pos[1],pos[2]+py+apy,faceId,cchunk);
      }
      cchunk.endShape();
      //println(renderShape.getChildCount());
      //println("a",px,py);
      renderShape.addChild(cchunk);
      //if(renderShape.getChildren()[renderShape.getChildCount()-1]==null) println("ptn");
      //println("b",px,py);
    }
    renderShape.disableStyle();
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

    return facesToRender;
  }

  void startThread(){
    loadThread=new Thread(cLoad);
    loadThread.setPriority(1);
    loadThread.start();
  }

  void generate(){
    for(int x=0; x<blocksData.length; x++) for (int z=0; z<blocksData[0][0].length; z++){
      float noise=(float)ImprovedNoise.noise((px+x)/20.0,(py+z)/20.0,0.0)+1;
      //println(noise);
      int hgt=floor(noise*(blocksData[0].length/10));
      for(int y=0;y<hgt;y++) blocksData[x][blocksData[0].length-y-1][z]=1;//(int)random(0,3);
    }
    isLoaded.set(true);
  }

  void renderShape(){
    isRendering.set(true);
    for(int x=0; x<blocksData.length; x++) for (int y=0; y<blocksData[0].length; y++) for (int z=0; z<blocksData[0][0].length; z++) if(blocksData[x][y][z]!=0){
      int[] faces=shouldRender(x,y,z);
      for(int i=0;i<faces.length;i++) renderBlocks[blocksData[x][y][z]-1][faces[i]]=(int[][])append(renderBlocks[blocksData[x][y][z]-1][faces[i]],new int[]{x,y,z});
    }
    createRenderShape(0,0);
    isRendered.set(true);
  }
}

class chunkLoader implements Runnable{
  chunk c;

  chunkLoader(chunk c){
    this.c=c;
  }

  void run(){
    c.generate();
    c.cm.chunkLoadingFinished(c);
  }
}
