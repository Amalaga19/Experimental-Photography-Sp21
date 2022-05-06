import processing.serial.*;
import processing.video.*;
Capture ourVideo;
int photoNumber = 0;
int shutter;
int redRead;
int blueRead;
int greenRead;
int newRed;
int newGreen;
int newBlue;
int NUM_OF_VALUES_FROM_ARDUINO = 4;   /** YOU MUST CHANGE THIS ACCORDING TO YOUR PROJECT **/
int sensorValues[];      /** this array stores values from Arduino **/
String myString = null;
Serial myPort;

void setup() {
  size(1280, 720);
  setupSerial();
  String[] cameras = Capture.list();
  ourVideo = new Capture(this, width,height);
  ourVideo.start();
}
void draw() {
  getSerialData();
  printArray(sensorValues);
  if (ourVideo.available())  ourVideo.read();
  background (0);
  shutter = sensorValues[3];
  ourVideo.loadPixels();
  loadPixels();
 


  redRead = sensorValues[0];
  greenRead=sensorValues[1];
  blueRead=sensorValues[2];
  for (int x = 0; x<width; x++) {
    for (int y = 0; y<height; y++) {
      int index = (x + y * ourVideo.width);
      if (index<width*height) {
        PxPGetPixel(x, y, ourVideo.pixels, width);
        newRed = R+redRead;
        if (newRed>255) {
          newRed=255;
        } else if (redRead<0) {
          if (newRed<0) {
            newRed = (-1*redRead)+(-1*R);
          } else {
            newRed = R-redRead;
          }
        }
        newGreen=G+greenRead;
        if (newGreen>255) {
          newGreen=255;
        } else if (greenRead<0) {
          if (newGreen<0) {
            newGreen=(-1*greenRead)+(-1*B);
          } else {
            newGreen = G-greenRead;
          }
        }
        newBlue=B+blueRead;
        if (newBlue>255) {
          newBlue=255;
        } else if (blueRead<0) {
          if (newBlue<0) {
            newBlue=(-1*blueRead)+(-1*B);
          } else {
            newBlue = B-blueRead;
          }
        }
        PxPSetPixel(x, y, newRed, newGreen, newBlue, 255, pixels, width);
      }
    }
  }
  updatePixels();
  if (shutter == 1) {
    save(photoNumber+".png");
    photoNumber++;
  }
}

void setupSerial() {
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[0], 9600);
  // WARNING!
  // You will definitely get an error here.
  // Change the PORT_INDEX to 0 and try running it again.
  // And then, check the list of the ports,
  // find the port "/dev/cu.usbmodem----" or "/dev/tty.usbmodem----"
  // and replace PORT_INDEX above with the index number of the port.

  myPort.clear();
  // Throw out the first reading,
  // in case we started reading in the middle of a string from the sender.
  myString = myPort.readStringUntil( 10 );  // 10 = '\n'  Linefeed in ASCII
  myString = null;

  sensorValues = new int[NUM_OF_VALUES_FROM_ARDUINO];
}

void getSerialData() {
  while (myPort.available() > 0) {
    myString = myPort.readStringUntil( 10 ); // 10 = '\n'  Linefeed in ASCII
    if (myString != null) {
      String[] serialInArray = split(trim(myString), ",");
      if (serialInArray.length == NUM_OF_VALUES_FROM_ARDUINO) {
        for (int i=0; i<serialInArray.length; i++) {
          sensorValues[i] = int(serialInArray[i]);
        }
      }
    }
  }
}

//our function for setting color components RGB into the pixels[] , we need to efine the XY of where
// to set the pixel, the RGB values we want and the pixels[] array we want to use and it's width
int R, G, B, A;          // you must have these global varables to use the PxPGetPixel()
void PxPGetPixel(int x, int y, int[] pixelArray, int pixelsWidth) {
  int thisPixel=pixelArray[x+y*pixelsWidth];     // getting the colors as an int from the pixels[]
  A = (thisPixel >> 24) & 0xFF;                  // we need to shift and mask to get each component alone
  R = (thisPixel >> 16) & 0xFF;                  // this is faster than calling red(), green() , blue()
  G = (thisPixel >> 8) & 0xFF;
  B = thisPixel & 0xFF;
}


void PxPSetPixel(int x, int y, int r, int g, int b, int a, int[] pixelArray, int pixelsWidth) {
  a =(a << 24);
  r = r << 16;                       // We are packing all 4 composents into one int
  g = g << 8;                        // so we need to shift them to their places
  //b = b << 0;
  color argb = a | r | g | b;        // binary "or" operation adds them all into one int
  pixelArray[x+y*pixelsWidth]= argb;    // finaly we set the int with te colors into the pixels[]
}
