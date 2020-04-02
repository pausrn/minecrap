class chunkManager{
  chunk[] chunk;
  block[] blocks;
  player p;
  int[][] chunkCoords;
  int renderDist=3;
  int px,py;
  PShape chunkShape;
  
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
    chunkShape=createShape(GROUP);
    chunkShape.disableStyle();
    
    for(int blockId=0;blockId<blocks.length;blockId++){
      PShape cBlock=createShape(GROUP);
      for(int faceId=0;faceId<boxCoords.length;faceId++){
        PShape cFace=createShape(GROUP);
        for(int x=0;x<chunkCoords.length;x++) for(int y=0;y<chunkCoords[0].length;y++){
          PShape cChunk=createShape();
          //cChunk.disableStyle();
          cChunk.beginShape(QUADS);
          chunk cc=chunk[chunkCoords[x][y]];
          /*if(isInView(cc))*/ cc.render(px<<4,py<<4,blockId,faceId,cChunk);
          cChunk.endShape();
          cFace.addChild(cChunk);
        }
        cFace.setTexture(blocks[blockId].tex[faceId]);
        cBlock.addChild(cFace);
      }
      chunkShape.addChild(cBlock);
    }
  }
  
  void renderShape(){
    translate(px<<4,0,py<<4);
    shape(chunkShape);
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
