import java.util.concurrent.ConcurrentLinkedQueue;

class chunkManager{
  chunk[] chunk;
  block[] blocks;
  player p;
  int[][] chunkCoords;
  int renderDist=3;
  int px,py;
  chunkLoader load;
  Thread loadThread;
  
  chunkManager(block[] blocks,player p,int rd){
    this.blocks=blocks;
    this.p=p;
    px=0;
    py=0;
    
    load=new chunkLoader(this);

    renderDist=rd;
    int area=0;
    for(int x=-renderDist;x<renderDist;x++) for(int y=-renderDist;y<renderDist;y++) if(abs(x+0.5)<=sqrt(1-sq((float)(y+0.5)/renderDist))*renderDist) area++;
    println(area);
    chunk=new chunk[area];
    chunkCoords=new int[2*rd][2*rd];
    int ind=0;
    for(int x=-renderDist;x<renderDist;x++) for(int y=-renderDist;y<renderDist;y++) if(abs(x+0.5)<sqrt(1-sq((float)(y+0.5)/renderDist))*renderDist){
      chunkCoords[x+rd][y+rd]=ind;
      load.addToQueue(ind);
      chunk[ind]=new chunk(this,blocks,x,y);
      ind++;
    }
    else chunkCoords[x+rd][y+rd]=-1;
    
    startChunkRender();
  }

  void renderShape(){
    for(int i=0;i<chunk.length;i++){
      if(chunk[i]!=null&&chunk[i].isRendered) shape(chunk[i].renderShape);
    }
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
        load.addToQueue(ind);
      }
      startChunkRender();
    }
  }
  
  void startChunkRender(){
    if(loadThread==null||!loadThread.isAlive()){
      loadThread=new Thread(load);
      loadThread.start();
    }
  }
  
  void generateAndRender(){
    while(!load.chunksToRender.isEmpty()){
      int ind=load.chunksToRender.poll();
      chunk[ind].generate();
      chunkLoadingFinished(chunk[ind]);
    }
  }

  void chunkLoadingFinished(chunk c){
    int ind=getChunkIndex(c.chunkX,c.chunkY);
    tryToRender(c.chunkX,c.chunkY);
    for(int i=0;i<chunkAround.length;i++){
      int ax=chunkAround[i][0]+c.chunkX;
      int ay=chunkAround[i][1]+c.chunkY;

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
    if(chunk[chunkIndex]==null||!chunk[chunkIndex].isLoaded||chunk[chunkIndex].isRendered) return;
    for(int i=0;i<chunkAround.length;i++){
      int cInd=getChunkIndex(chunkAround[i][0]+cx,chunkAround[i][1]+cy);
      if(cInd!=-1&&chunk[cInd]!=null&&!chunk[cInd].isLoaded){
        adjChunkLoaded=false;
        break;
      }
    }
    if(adjChunkLoaded){
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
  }
}

class chunkLoader implements Runnable{
  chunkManager cm;
  ConcurrentLinkedQueue<Integer> chunksToRender=new ConcurrentLinkedQueue<Integer>();
  
  chunkLoader(chunkManager cm){
    this.cm=cm;
  }
  
  void setQueue(int[] chunks){
    chunksToRender=new ConcurrentLinkedQueue<Integer>();
    for(int i=0;i<chunks.length;i++) chunksToRender.add(chunks[i]);
  }
  
  void addToQueue(int[] chunks){
    for(int i=0;i<chunks.length;i++) chunksToRender.add(chunks[i]);
  }
  
  void addToQueue(int chunk){
    chunksToRender.add(chunk);
  }
  
  void run(){
    cm.generateAndRender();
  }
}
