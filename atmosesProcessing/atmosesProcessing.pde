import processing.serial.*;

//selecteer hier de seriele poort:
int keuze_seriele_poort = 0;

Serial myPort;
int val;

void setup()
{
  size(500, 800);
  //from exercises
  val = Serial.list().length;
  if (val == 0) {
    println("Error: Geen seriële poorten gevonden!");
    exit();
    return;
  } else if (keuze_seriele_poort >= val) {
    println("Error: keuze_seriele_poort is verkeerd ingesteld!");
    exit();
    return;
  } else if (val > 1) {
    println("Waarschuwing! Meer dan 1 seriële poort gevonden:");
    for (int i = 0; i < val; i++) {
      print(": ");
      println(Serial.list()[i]);
    }
  }
  print("Seriële poort ");
  print(keuze_seriele_poort);
  print(" geselecteerd: ");
  println(Serial.list()[keuze_seriele_poort]);
  //Poort openen op Baud rate van 9600
  myPort = new Serial(this, Serial.list()[keuze_seriele_poort], 9600);
  noLoop(); //only redraw when needed
}

int[] co2 = {400, 400, 400, 400, 400, 400, 400, 400, 400, 400};
int[] o2 = {2500, 2500, 2500, 2500, 2500, 2500, 2500, 2500, 2500, 2500};

int maxO2 = 2500, minO2 = 1500, dangerO2 = 1950;
int maxCO2 = 1400, minCO2 = 400, dangerCO2 = 1000;

void draw()
{
  background(200);
  graph("CO2 ppm", 100, 350, 400, 1400, co2); //co2
  graph("O2 /10000", 100, 700, 1500, 2500, o2); //o2
}

//x => 0 horz corner top left, start coord
//y => 0 vert corner top left, start coord

void graph(String title, int x, int y, int startValue, int endValue, int[] values) {
  /*horizontal (x) is alway time*/
  int sizeY = 250, sizeX = 250, stepSizeX = 25, 
    stepSizeY = 25, paddingY =30, paddingH= 17;
  int lineVal = startValue;

  text(title, x, y-sizeY- 10);
  text("time s", x+sizeX, y+30);
  
  //warning lines
  switch(title){
    case "CO2 ppm":
      int warnLineYCO = y - ((sizeY*(dangerCO2 - startValue))/(endValue - startValue));
      stroke(255, 0 ,0);
      line(x, warnLineYCO, x+ sizeX, warnLineYCO);
      break;
    case "O2 /10000":
      int warnLineYO = y - ((sizeY*(dangerO2 - startValue))/(endValue - startValue));
      stroke(255, 0 ,0);
      line(x, warnLineYO, x+ sizeX, warnLineYO);
      break;
  }
  //graph lines axis
  stroke(0);
  line(x, y, x+sizeX, y);
  line(x, y, x, y-sizeY);
  
  //data lines
  stroke(0,0,255);
  int t = (sizeX/stepSizeX); //time index
  float ratioMTG = (float) sizeX /(endValue-startValue);//MTG messurement to graph

  for (int i = 0; i<t-1; i++) {
    int x1 =x + (i*stepSizeX) +stepSizeX, 
      x2 = x + (((i+1)*stepSizeX)+stepSizeX), 
      y1 = floor(y - (ratioMTG*(values[i] - startValue))), 
      y2 = floor(y -(ratioMTG* (values[i+1] - startValue)));
    line(x1, y1, x2, y2);
  }
  t *= -1;

  //axis info
  stroke(0);
  for (int i = x+stepSizeX; i <= x+sizeX; i+= stepSizeX)
  {
    line(i, y-1, i, y+1);
    text(t++, i- (paddingH>>2), y+paddingH);
  }
  int stepY = (endValue-startValue)/((sizeY/stepSizeY));
  for (int i = y; i >= y-sizeY; i-= stepSizeY)
  {
    line(x-1, i, x+1, i);
    text(lineVal, x-paddingY, i);
    lineVal += stepY;
  }
}

//recive data
void serialEvent(Serial p) {
  String beep = trim(p.readStringUntil('c'));
  if (beep != null) {
    //read carbon dioxide + put in array
    beep = beep.replace('c', ' ');
    beep = beep.trim();
    for (int i = 0; i < co2.length; i++) {
      if (i < co2.length-1) {
        co2[i] = co2[i+1];
      } else {
        int newVal = parseInt(beep);
        if(newVal > maxCO2){
        co2[i] = maxCO2;
        } else if(newVal < minCO2){
          co2[i] = minCO2;
        } else{
          co2[i] = newVal;
        } 
      } 
    }
  }
  //read oxygen
  String boop = trim(p.readStringUntil('o'));
  if (boop != null) {
    boop = boop.replace('o', ' ');
    boop = boop.trim();
    for (int i = 0; i < co2.length; i++) {
      if (i < o2.length-1) {
        o2[i] = o2[i+1];
      } else {
        int newVal = parseInt(float(boop)*100);
        if(newVal > maxO2){
        o2[i] = maxO2;
        } else if(newVal < minO2){
          o2[i] = minO2;
        } else{
          o2[i] = newVal;
        }

      }
    }
    redraw();
  }
} 
