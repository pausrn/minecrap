class player {
  float x, y, z;
  float fov=PI/3.0;
  float lr=0, ud=0;
  float speed=1.0;
  chunkManager cm;

  player() {

  }

  void move(float x, float y, float z) {
    this.x+=x;
    this.y+=y;
    this.z+=z;
  }

  void moveTo(float x, float y, float z) {
    this.x=x;
    this.y=y;
    this.z=z;
  }

  void walk(float[] moves) {
    if (moves!=null) {
      moves[0]+=lr;
      p.move(-speed*cos(moves[1])*sin(moves[0]), -speed*sin(moves[1]), -speed*cos(moves[1])*cos(moves[0]));
      //cm.updateChunk();
    }
  }
}
