const int TxPin = 6;
const int upLed = 3;
const int downLed = 9;
String inputString = ""; // a string to hold incoming data
int satelliteElevation = 0; 
boolean stringComplete = false;
boolean azimuthComplete = false;
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
  if (azimuthComplete)
  {
    mySerial.println("Az: " + inputString );
  }
  // Read current rotor elevation
  sensorValue = analogRead(A0); 
  currentElevation = map(sensorValue, 2, 962, 0, 18000); // Convert to degrees * 100
  mySerial.println( "El: " + currentElevation ); // print current elevation to LCD screen
  differenceInElevation = satelliteElevation - currentElevation;
  if (differenceInElevation < -400) // -4 degrees
  {  // send currentElevation down
    digitalWrite(upLed, LOW);
    digitalWrite(downLed, HIGH);
  }
  else if (differenceInElevation > 400) // 4 degrees
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
  int inChar = Serial.read();
  switch (inChar)
  {
  case 'e': // if first character is 'e'
    while (Serial.available())
    {
      if (isDigit(inChar)) 
      {
        // convert the incoming byte to a char 
        // and add it to the string:
        inputString += (char)inChar; 
      }
      // if you get a newline, print the string,
      // then the string's value:
      if (inChar == '\n') 
      {
        stringComplete = true;
      }
    }
    break;
  case 'a': // if first character is 'a'
    while (Serial.available())
    {
      if (isDigit(inChar)) 
      {
        // convert the incoming byte to a char 
        // and add it to the string:
        inputString += (char)inChar; 
      }
      // if you get a newline, print the string,
      // then the string's value:
      if (inChar == '\n') 
      {
        azimuthComplete = true;
      }
    }
    break;
  case 'r': // if first character is 'r', do below code only and return to loop
    Serial.println(currentElevation); // sends Matlab current elevation
    while (Serial.available())
    {	
      Serial.read(); // reads '\n'
    }
    break;
	case 'u':
    digitalWrite(downLed, LOW);
    digitalWrite(upLed, HIGH);
    while (Serial.available())
    {	
      Serial.read(); // reads '\n'
    }
		break;
		case 'd':
    digitalWrite(upLed, LOW);
    digitalWrite(downLed, HIGH);
    while (Serial.available())
    {	
      Serial.read(); // reads '\n'
    }
		break;
		case 's':
    digitalWrite(downLed, LOW);
    digitalWrite(upLed, LOW);
    while (Serial.available())
    {	
      Serial.read(); // reads '\n'
    }
		break;
  }
}






