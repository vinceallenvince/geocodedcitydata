import processing.pdf.*;

PShape baseMap;
String csv[];
String myData[][];
PFont f;
int totalLabels;
IntDict countryToTotalPlaces = new IntDict();
int totalUnresolved = 0;
int totalResolved = 0;

void setup() {
  size(1800, 900);
  noLoop();
  f = createFont("Avenir-Medium", 12);
  baseMap = loadShape("WorldMap.svg");

  // source csv should be formatted as:
  // geoname_id, continent_code, country_iso_code, subdivision_1_name, city_name, postal_code, latitude, longitude, <some value>
  csv = loadStrings("source-sample.csv");
  myData = new String[csv.length][8];
  for (int i = 0; i < csv.length; i++) {
    myData[i] = csv[i].split(",");
  }

  // loop thru source and create an IntDict mapping country_iso_code to total number of geoname_ids
  for (int i = 0; i < myData.length; i++) {
    int currentPlaces = countryToTotalPlaces.get(myData[i][2]);
    int combinedPlaces = currentPlaces + 1;
    countryToTotalPlaces.set(myData[i][2], combinedPlaces);
  }

  totalLabels = 0;
}

void draw() {
  beginRecord(PDF, "geocodedcitydata.pdf");
  shape(baseMap, 0, 0, width, height);
  noStroke();

  for (int i = 0; i < myData.length; i++) {

    // Unresolved ip's use whole number lat/lng. If a country only has one set of values
    // and it's a low precision mapping (ie. whole number), we render the values. Otherwise,
    // we skip it.
    if (isWholeNumberCoordinate(myData[i][6]) && isWholeNumberCoordinate(myData[i][7])) {
      if (countryToTotalPlaces.get(myData[i][2]) > 1) {
        totalUnresolved += int(myData[i][8]);
        continue;
      }
    }

    // uncomment to include only specific continents
    // if (myData[i][1].equals("NA") == false) continue; 

    // uncomment to exclude specific continents
    // if (myData[i][1].equals("AF") == true) continue;

    // uncomment to include only specific countries
    // if (myData[i][2].equals("US") == false) continue; 

    fill(255, 0, 0, 50);
    textMode(MODEL);
    noStroke();
    float graphLat = map(float(myData[i][6]), 90, -90, 0, height);
    float graphLong = map(float(myData[i][7]), -180, 180, 0, width);
    float markerSize = 0.35*sqrt(float(myData[i][8]))/PI;
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
    
    totalResolved += int(myData[i][8]);
  }
  println("totalUnresolved: " + totalUnresolved);
  println("totalResolved: " + totalResolved);
  endRecord();
  println("PDF Saved!");
}

Boolean isWholeNumberCoordinate(String flt) {
  String[] list = split(flt, ".");
  if (list[list.length - 1].length() == 1 && list[list.length - 1].equals("0") == true) {
    return true;
  }
  return false;
}

