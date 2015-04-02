import processing.pdf.*;

PShape baseMap;
String csv[];
String myData[][];
PFont f;
int totalLabels;

void setup() {
  size(1800, 900);
  noLoop();
  f = createFont("Avenir-Medium", 12);
  baseMap = loadShape("WorldMap.svg");
  csv = loadStrings("source.csv");
  myData = new String[csv.length][4];
  for (int i=0; i<csv.length; i++) {
    myData[i] = csv[i].split(",");
  }
  // source csv should be formatted as:
  // geoname_id, country, adminArea, city, lat, lng, <some value>
  
  totalLabels = 0;
}

void draw() {
  beginRecord(PDF, "geocodedcitydata.pdf");
  shape(baseMap, 0, 0, width, height);
  noStroke();
  
  for (int i=0; i<myData.length; i++) {
    fill(255, 0, 0, 50);
    textMode(MODEL);
    noStroke();
    float graphLat = map(float(myData[i][4]), 90, -90, 0, height);
    float graphLong = map(float(myData[i][5]), -180, 180, 0, width);
    float markerSize = 0.35*sqrt(float(myData[i][6]))/PI;
    ellipse(graphLong, graphLat, markerSize, markerSize);
    
    // labels
    if (i < totalLabels) {
      fill(0);
      textFont(f);
      text(myData[i][3], graphLong + markerSize + 5, graphLat + 4);
      noFill();
      stroke(0);
      line(graphLong+markerSize/2, graphLat, graphLong + markerSize, graphLat);
    }
    
  }
  endRecord();
  println("PDF Saved!");
}
