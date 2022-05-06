int shutter;
const int numReadings = 10;

int readings[numReadings];      // the readings from the analog input
int readings1[numReadings];
int readings2[numReadings];
int readIndex = 0;              // the index of the current reading
int total = 0;                  // the running total
int average = 0;                // the average
int total1=0;
int total2=0;
int average1=0;
int average2=0;
void setup() 
{
  Serial.begin(9600);
  pinMode(12, INPUT_PULLUP);
  for (int thisReading = 0; thisReading < numReadings; thisReading++) {
  readings[thisReading] = 0;
  }
  for (int thisReading1 = 0; thisReading1 < numReadings; thisReading1++) {
  readings1[thisReading1] = 0;
  }
  for (int thisReading2 = 0; thisReading2 < numReadings; thisReading2++) {
  readings2[thisReading2] = 0;
  }
}
void loop()
{
  int shutterRead = digitalRead(12);
  if (shutterRead==0){
    shutter = 1;
    }
  else if (shutterRead==1){
    shutter = 0;
    }

    // subtract the last reading:
  total = total - readings[readIndex];
  total1 = total1 - readings1[readIndex];
  total2 = total2 - readings2[readIndex];


  // read from the sensor:
  readings[readIndex] = analogRead(A1);
  readings1[readIndex] = analogRead(A2);
  readings2[readIndex]=analogRead(A3);

  // add the reading to the total:
  total = total + readings[readIndex];
  total1 = total1 + readings1[readIndex];
  total2 = total2 + readings2[readIndex];

  // advance to the next position in the array:
  readIndex = readIndex + 1;

  // if we're at the end of the array...
  if (readIndex >= numReadings) {
    // ...wrap around to the beginning:
    readIndex = 0;
  }
  average = total / numReadings;
  average1 = total1 / numReadings;
  average2 = total2 / numReadings;


  int data = average;
  int data2 = average1;
  int data3 = average2;
  int red = map(data3, 0, 1023, -255, 255);
  int green = map(data2, 0, 1023, -255,255);
  int blue = map(data, 0, 1023, -255,255);
  Serial.print(red);
  Serial.print(",");
  Serial.print(green);
  Serial.print(",");
  Serial.print(blue);
  Serial.print(",");
  Serial.print(shutter);
  Serial.println();
  delay(100);
}
