import processing.video.*;
import jp.nyatla.nyar4psg.*;
import java.lang.Object;
import oscP5.*;
import netP5.*;

Capture cam;
MultiMarker nya;
OscP5 oscP5; 

BufferedReader reader; 
String line; 
int pNumber = 216;
PVector[][] cordinate = new PVector[12][18];
//String receive;
int mAccount;
PVector marker[];

int markerSize;

NetAddress myBroadcastLocation;

int count_layer = 0;
int count_point = 0;

float w = 0;
float q = 0;

void setup() {

  size(640, 480, P3D);
  colorMode(RGB, 100);
  println(MultiMarker.VERSION); 

  cam=new Capture(this, width, height);
  nya=new MultiMarker(this, width, height, "PinkCamera.dat", NyAR4PsgConfig.CONFIG_PSG);  
  
// Open the file from the createWriter() example 
  reader = createReader("points.txt");
  
  //initialize array of coordinates
  for(int i = 0; i<12; i++){
    for(int j = 0; j < 18; j++){
      PVector temp = new PVector(0,0,0); 
      cordinate[i][j] = temp;
    }
  }  

//read txt and get coordinates of points
try { 
line = reader.readLine();
} 
catch (IOException e) { 
e.printStackTrace(); 
line = null; 
} 
if (line == null) {
// Stop reading because of an error or file is empty
  println("reading txt error"); 
} else {
  String[] splitReceive = split(line, "&");
  int pNumberNew = splitReceive.length;
  if(pNumberNew != pNumber){
    println("Number Wrong");
  }
  
  for(int i = 0; i<12; i++){
    for(int j = 0; j<18; j++){
      String[] cordinatesString = split(splitReceive[i*18+j], ",");
  
      if(cordinatesString.length != 3){
      println("Vector Number" + i + "wrong");
      continue;
      }
  
      float[] c = float(cordinatesString);
      cordinate[i][j].set(-c[0],c[1],c[2]);
      println(i+","+j);
      println(cordinate[i][j].x + "," + cordinate[i][j].y + "," + cordinate[i][j].z);
    }
  }
} 
  
    
  //set marker&size
  markerSize = 94;
  nya.addNyIdMarker(40, markerSize);//id=0
  nya.addNyIdMarker(506, 24);//id=1

  cam.start();

//set coordinate of marker1
  PVector marker1_position = new PVector(-200,200,0);

}



void draw(){
  text(frameRate, 50, 50);
  //ARToolKit
  if (cam.available() !=true) {
    return;
  }
  cam.read();
  nya.detect(cam);
  background(0);
  nya.drawBackground(cam);

  

  if (!nya.isExist(0)){
    println("marker not found");
  }

  else{
    println("found");
  //get marker2 position on the screen
  if(nya.isExist(1)){
  PVector Trans = nya.marker2ScreenCoordSystem(1,0,0,0);
  
  int a = int(Trans.x);
  int b = int(Trans.y);
  
  //project marker2 to maker1's coordinate system
  PVector relative_position = nya.screen2ObjectCoordSystem(0,a,b);
  float w = (int)relative_position.x - 200;
  float q = (int)relative_position.y + 200;
  }
  
  
  
  if(keyPressed &&(key == CODED)){
    if((keyCode == UP)&&(count_layer<11)){count_layer++;}
    if((keyCode == DOWN)&&(count_layer>0)){count_layer--;}
    if((keyCode == LEFT)&&(count_point>0)){count_point--;}
    if((keyCode == RIGHT)&&(count_layer<17)){count_point++;}
  }
  
  nya.beginTransform(0);
  
  stroke(255,0,0);
  fill(255,0,0,50);
  box(markerSize,markerSize, 1);
  //change coordinate
  translate(200, -200, 0);
  //if(nya.isExist(1)){
  //  PVector hand_position = new PVector(w - 200,q+200, 0);
  //}
  
  noFill();
  ellipse(0,0,400,400);
  for(int k = 0; k<count_layer+1; k++){
    stroke(255,0,0);
    noFill();
    strokeWeight(2);
    if(k == count_layer){
      strokeWeight(9);
      for(int l = 0; l<18; l++){
        stroke(255,255,0);
        if(l == count_point){
        float x1 = cordinate[k][l].x - w;
        float y1 = cordinate[k][l].y - q;
        float z1 = cordinate[k][l].z;
        stroke(255,0,0);
        line(w,q,0, w+0.3*x1, q,0);
        stroke(0,255,0);
        line(w,q,0, w, q+0.3*y1,0);
        stroke(0,0,255);
        line(w,q,0, w, q,0.3*z1);        
        stroke(0,255,0);
        }
        point(cordinate[k][l].x,cordinate[k][l].y,cordinate[k][l].z);
      }
      stroke(255,255,0);
      strokeWeight(2);
    }
    beginShape();
    for(int l = 0; l<18; l++){
      vertex(cordinate[k][l].x,cordinate[k][l].y,cordinate[k][l].z);
    }
      //curveVertex(cordinate[k][0].x,cordinate[k][0].y,cordinate[k][0].z);
    endShape(CLOSE);
    strokeWeight(6);

    
  }
  
  translate(-200, 200,0);

  nya.setARPerspective();
  nya.endTransform();
    
  }
    
}