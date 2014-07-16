const int TxPin = 6;
const int upLed = 3;
const int downLed = 9;
String inputString = ""; // a string to hold incoming data
int satelliteElevation = 0; 
boolean stringComplete = false;
boolean stringAzimuth = false;
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
  pinMode(upLed, OUTPUT);
  pinMode(downLed, OUTPUT);
  pinMode(TxPin, OUTPUT);
  digitalWrite(upLed, LOW);
  digitalWrite(downLed, LOW);
  digitalWrite(TxPin, HIGH);
  mySerial.write(22);
  mySerial.write(12);
  // Read value from rotor
  sensorValue = analogRead(A0);
  // convert sensorValue to degrees * 100
  currentElevation = map(sensorValue, 2, 962, 0, 18000);
  satelliteElevation = currentElevation;
}
void loop() 
{
  if (stringComplete)
  {
    // Convert elevation sent by matlab to an integer
    satelliteElevation = inputString.toInt(); // 00000 to 18000
    inputString = ""; // clear the string
    stringComplete = false;
  }
  if (stringAzimuth)
  {
    mySerial.print("Az: " + inputString);
    inputString = ""; // clear the string
    stringAzimuth = false;
  }
  // Read current rotor elevation
  sensorValue = analogRead(A0); 
  delay(5);
  currentElevation = map(sensorValue, 2, 962, 0, 18000); // Convert to degrees * 100
  //  Serial.println(currentElevation);
  //  delay(5);
  //  Serial.print("Satellite Elevation:");
  //  Serial.println(satelliteElevation);
  //  mySerial.println( "El: " + currentElevation ); // print current elevation to LCD screen
  differenceInElevation = satelliteElevation - currentElevation;
  if (differenceInElevation < -100) // -4 degrees
  {  // send currentElevation down
    digitalWrite(upLed, LOW);
    digitalWrite(downLed, HIGH);
  }
  else if (differenceInElevation > 100) // 4 degrees
  {  // send currentElevation up
    digitalWrite(downLed, LOW);
    digitalWrite(upLed, HIGH);
  }
  else
  { // stay put
    digitalWrite(upLed, LOW);
    digitalWrite(downLed, LOW);
  }
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
    char inChar = (char)Serial.read();
    delay(5);
    switch (inChar) {
    case 'e': // if first character is 'e'
      while (Serial.available()){
        int inNum = Serial.read();
        delay(5);
        if (isDigit(inNum)) {
          // convert the incoming byte to a char 
          // and add it to the string:
          inputString += (char)inNum; 
        }
        // if you get a newline, print the string,
        // then the string's value:
        if (inNum == '\n') {
          stringComplete = true;
        }
      }
      break;
    case 'a': // if first character is 'e'
      while (Serial.available()){
        int inNum = Serial.read();
        delay(5);
        if (isDigit(inNum)) {
          // convert the incoming byte to a char 
          // and add it to the string:
          inputString += (char)inNum; 
        }
        // if you get a newline, print the string,
        // then the string's value:
        if (inNum == '\n') {
          stringAzimuth = true;
        }
      }
      break;
    case 'r': // if first character is 'r', do below code only and return to loop
      Serial.println(currentElevation); // sends Matlab current elevation
      delay(5);
      Serial.read(); // reads '\n'
      break;
    case 'u':
      digitalWrite(downLed, LOW);
      digitalWrite(upLed, HIGH);
      while (Serial.available()){	
        Serial.read(); // reads '\n'
        delay(5);
      }
      break;
    case 'd':
      digitalWrite(upLed, LOW);
      digitalWrite(downLed, HIGH);
      while (Serial.available()){	
        Serial.read(); // reads '\n'
        delay(5);
      }
      break;
    case 's':
      digitalWrite(downLed, LOW);
      digitalWrite(upLed, LOW);
      break;
    }
  }
}

















