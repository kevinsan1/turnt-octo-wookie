int TxPin = 6;
int upLed = 3;
int downLed = 9;
String inputString = ""; // a string to hold incoming data
int satelliteElevation = 0; 
boolean stringComplete = false;
int sensorValue = 0;
// Convert the analog reading (which goes from 2 - 962) to an elevation ( 0 -> 180 )
int currentElevation = 0;
int differenceInElevation = 0;
#include <SoftwareSerial.h>
SoftwareSerial mySerial(5, TxPin);
void setup()
{
  Serial.begin(9600);
  inputString.reserve(200);
  mySerial.begin(9600);
  pinMode(upLed, 'OUTPUT');
  pinMode(downLed,'OUTPUT');
  pinMode(TxPin,'OUTPUT');
  digitalWrite(upLed, LOW);
  digitalWrite(downLed, LOW);
  digitalWrite(TxPin, HIGH);
  mySerial.write(22);
  mySerial.write(12);
  sensorValue = analogRead(A0);
  currentElevation = (int)round( sensorValue / 960 * 18000 ); //18000 is the integer form and will subtract from the value we give it easier than converting both to float numbers
  satelliteElevation = currentElevation; // at startup, set these equal to eachother so it doesn't automatically rotate
}
void loop() 
{
  if (stringComplete) // if something is sent, we compare it with our current elevation
  {
    satelliteElevation = inputString.toInt(); // 00000 to 18000
    Serial.println(currentElevation); // gives matlab a value between 2 and 962
    // clear the string:
    inputString = "";
    stringComplete = false;
  }
  sensorValue = analogRead(A0); // Always reading where its at
  currentElevation = (int)round( sensorValue / 960 * 18000 ); // rounds to an integer, 153.40 degrees is 15340
  mySerial.println(currentElevation); // print current elevation to LCD screen
  differenceInElevation = satelliteElevation - currentElevation;
  if (differenceInElevation < -400) // 4 degrees
  {  // go down
    digitalWrite(upLed, LOW);
    digitalWrite(downLed, HIGH);
  }
  else if (differenceInElevation > 400) // 4 degrees
  { // go up
    digitalWrite(downLed, LOW);
    digitalWrite(upLed, HIGH);
  }
  else
  { // stay put
    digitalWrite(upLed, LOW);
    digitalWrite(downLed, LOW);
  }
  end
}

/*
  SerialEvent occurs whenever a new data comes in the
 hardware serial RX.  This routine is run between each
 time loop() runs, so using delay inside loop can delay
 response.  Multiple bytes of data may be available.
 */
void serialEvent() 
{
  while (Serial.available()) {
    int inChar = Serial.read();
    if (isDigit(inChar)) {
      // convert the incoming byte to a char 
      // and add it to the string:
      inputString += (char)inChar; 
    }
    // if you get a newline, print the string,
    // then the string's value:
    if (inChar == '\n') {
      stringComplete = true;
    }
    // below code might not work
    if (inChar == 'r') // if first character is 'r'
    {
      Serial.println(currentElevation); // sends Matlab current elevation
      
      while (Serial.available())
      {	
        Serial.read(); // reads '\n'
      }
    }
  }
}































