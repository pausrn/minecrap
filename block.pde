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
