import java.io.FileWriter;
import java.io.*;

void appendToFile(String path,Object txt){
  try {
    File file =new File(path);
 
    if (!file.exists()) {
      file.createNewFile();
    }
 
    FileWriter fw = new FileWriter(file, true);///true = append
    BufferedWriter bw = new BufferedWriter(fw);
    PrintWriter pw = new PrintWriter(bw);
 
    pw.println(txt);
 
    pw.close();
  }
  catch(IOException ioe) {
    System.out.println("Exception ");
    ioe.printStackTrace();
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
