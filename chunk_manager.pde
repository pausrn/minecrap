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
    for(int x=-renderDist;x<renderDist;x++) for(int y=-renderDist;y<renderDist;y++) if(abs(x+0.5)<=sqrt(1-sq((float)(y+0.5)/renderDist))*renderDist) area++;
    println(area);
    chunk=new chunk[area];
    chunkCoords=new int[2*rd][2*rd];
    int ind=0;
    for(int x=-renderDist;x<renderDist;x++) for(int y=-renderDist;y<renderDist;y++) if(abs(x+0.5)<sqrt(1-sq((float)(y+0.5)/renderDist))*renderDist){
      chunkCoords[x+rd][y+rd]=ind;
      chunk[ind]=new chunk(this,blocks,x,y);
      chunk[ind].startThread();
      ind++;
    }
    else chunkCoords[x+rd][y+rd]=-1;
  }

  void renderShape(){
    for(int i=0;i<chunk.length;i++) if(chunk[i]!=null&&chunk[i].isRendered.get()) shape(chunk[i].renderShape);
  }

  void updateChunk(){
    int cx=floor(p.x/16);
    int cy=floor(p.z/16);
    if(cx!=px||cy!=py){
      //for(int i=0;i<chunk.length;i++) chunk[i].renderShape.translate((cx-px)*16,0,(cy-py)*16);
      int depX=cx-px;
      int depY=cy-py;
      
      px=cx;
      py=cy;
      
      println(depX,depY);
      
      int[] chunkRequests=new int[chunk.length];
      int[] chunkToRender=new int[0];
      for(int i=0;i<chunkRequests.length;i++) chunkRequests[i]=-1;
      for(int i=0;i<chunk.length;i++){
        int x=chunk[i].chunkX;
        int y=chunk[i].chunkY;
        
        int nx=x+depX;
        int ny=y+depY;
        
        int nChunkInd=getChunkIndex(nx,ny);
        
        if(nChunkInd==-1) chunkToRender=append(chunkToRender,i);
        else chunkRequests[nChunkInd]=i;
      }
      for(int i=0;i<chunkRequests.length;i++){
        int ind=i;
        int chainOfRequests[]=new int[0];
        while(chunkRequests[ind]!=-1){
          chainOfRequests=append(chainOfRequests,ind);
          ind=chunkRequests[ind];
          if(ind==chunkRequests[ind]){
            break;
          }
        }
        
        for(int j=chainOfRequests.length-1;j>=0;j--){
          int cInd=chunkRequests[chainOfRequests[j]];
          //chunk[cInd]=chunk[chainOfRequests[j]];
          chunk[cInd].copyFrom(chunk[chainOfRequests[j]]);
          chunkRequests[chainOfRequests[j]]=-1;
        }
      }
      for(int i=0;i<chunkToRender.length;i++){
        int ind=chunkToRender[i];
        chunk[ind]=new chunk(this,blocks,chunk[ind].chunkX,chunk[ind].chunkY,chunk[ind].px,chunk[ind].py);
        chunk[ind].moveTo(depX,depY);
        chunk[ind].startThread();
      }
      for(int i=0;i<chunk.length;i++) appendToFile(sketchPath("chunkPosTest"),chunk[i].px/16+":"+chunk[i].py/16+" : "+getChunkIndex(chunk[i].chunkX,chunk[i].chunkY));
    }
  }

  void chunkLoadingFinished(chunk c){
    int ind=getChunkIndex(c.chunkX,c.chunkY);
    for(int x=-1;x<=1;x++) for(int y=-1;y<=1;y++){
      int ax=x+c.chunkX;
      int ay=y+c.chunkY;

      if(getChunkIndex(ax,ay)!=-1) tryToRender(ax,ay);
    }
  }
  
  int[][] chunkAround={
    new int[]{-1,0},
    new int[]{1,0},
    new int[]{0,-1},
    new int[]{0,1},
  };
  void tryToRender(int cx,int cy){
    boolean adjChunkLoaded=true;
    int chunkIndex=getChunkIndex(cx,cy);
    if(chunk[chunkIndex]==null||!chunk[chunkIndex].isLoaded.get()||chunk[chunkIndex].isRendered.get()||chunk[chunkIndex].isRendering.get()) return;
    for(int i=0;i<chunkAround.length;i++){
      int cInd=getChunkIndex(chunkAround[i][0]+cx,chunkAround[i][1]+cy);
      if(cInd!=-1&&chunk[cInd]!=null&&!chunk[cInd].isLoaded.get()){
        adjChunkLoaded=false;
        break;
      }
    }
    if(adjChunkLoaded){
      //println(getChunkIndex(cx,cy));
      chunk[chunkIndex].renderShape();
    }
  }

  int getChunkIndex(int x,int y){
    int ax=x+renderDist;
    int ay=y+renderDist;
    if(!isIn(ax,0,chunkCoords.length)||!isIn(ay,0,chunkCoords[0].length)) return -1;
    return chunkCoords[ax][ay];
  }

  boolean isInView(chunk c){
    float ang=HALF_PI+atan2((c.py+8-p.y),-(c.px+8-p.x))%PI;

    if(angDif(ang,p.lr)<p.fov/2) return true;
    return false;
    //return true;
    //return (ang>angMin&&ang<angMax);
  }
}
