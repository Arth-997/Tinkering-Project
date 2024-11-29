#include <Keypad.h>

long int fingertime;
long int rfidtime;
const byte ROWS = 4; /* four rows */
const byte COLS = 3; /* four columns */
/* define the symbols on the buttons of the keypads */
char hexaKeys[ROWS][COLS] = {
  {'1','2','3'},
  {'4','5','6'},
  {'7','8','9'},
  {'*','0','#'}
};
byte rowPins[ROWS] = {10, 9, 8, 7}; /* connect to the row pinouts of the keypad */
byte colPins[COLS] = {6, 5, 4}; /* connect to the column pinouts of the keypad */

/* initialize an instance of class NewKeypad */
Keypad customKeypad = Keypad( makeKeymap(hexaKeys), rowPins, colPins, ROWS, COLS); 
String input="";



#include <Adafruit_Fingerprint.h>
#if (defined(__AVR__) || defined(ESP8266)) && !defined(__AVR_ATmega2560__)
SoftwareSerial mySerial(2, 3);

#else=
#define mySerial Serial1

#endif
Adafruit_Fingerprint finger = Adafruit_Fingerprint(&mySerial);



#include <SPI.h>
#include <MFRC522.h>
 
#define SS_PIN A1
#define RST_PIN A0
MFRC522 mfrc522(SS_PIN, RST_PIN);   // Create MFRC522 instance.
 




void setup(){
  pinMode(A3,OUTPUT);
  digitalWrite(A3,1);
  rfidtime=-1;
  fingertime=-1;
  Serial.begin(9600);
  input="";
  SPI.begin();      // Initiate  SPI bus
  mfrc522.PCD_Init(); 
  while (!Serial);  // For Yun/Leo/Micro/Zero/...
  delay(100);
  Serial.println("\n\nAdafruit finger detect test");
  finger.begin(57600);
  delay(5);
  if (finger.verifyPassword()) {
    Serial.println("Found fingerprint sensor!");
  } 

}



void loop()                     // run over and over again
{
  int fing=getFingerprintID();
  if(fing==1){
    fingertime=millis();
    digitalWrite(A3,0);
    delay(500);
    digitalWrite(A3,1);
  }
  if(fing==-1&&(abs(millis()-fingertime>1000))){
    Serial.println(0);
    digitalWrite(A3,0);
    delay(500);
    digitalWrite(A3,1);
    delay(500);
    digitalWrite(A3,0);
    delay(500);
    digitalWrite(A3,1);
  }
  keypad();
  int calcrf=calcrfid();
  if(calcrf==1){
    rfidtime=millis();
    digitalWrite(A3,0);
    delay(500);
    digitalWrite(A3,1);
  }
  if(calcrf==-1){
    Serial.println(0);
    digitalWrite(A3,0);
    delay(500);
    digitalWrite(A3,1);
    delay(500);
    digitalWrite(A3,0);
    delay(500);
    digitalWrite(A3,1);
  }
  if((calcrf==1 || fing==1) && abs(rfidtime-fingertime)<10000 && fingertime!=-1 && rfidtime!=-1){
    Serial.println(1);
  }
}

void keypad(){
  char customKey = customKeypad.getKey();
  if (customKey){
    if(customKey=='*'){
      //call check
      Serial.println("s"+input);
      input="";
    }
    else if(customKey=='#'){
      input="";
    }
    else{
      input+=customKey;
    }
  }   
}
int getFingerprintID() {
  int p = finger.getImage();
  switch (p) {
    case FINGERPRINT_OK:
      break;
    case FINGERPRINT_NOFINGER:
      return 0;
    default:
      return -1;
  }

  // OK success!

  p = finger.image2Tz();
  switch (p) {
    case FINGERPRINT_OK:
      break;
    default:
      return -1;
  }

  // OK converted!
  p = finger.fingerSearch();
  if (p == FINGERPRINT_OK) {
  } else {
   return -1;
  }
  return 1;
}


int calcrfid() 
{
  // Wait for a new card to be detected
  if (!mfrc522.PICC_IsNewCardPresent()) {
    return 0;
  }
  
  // Wait for the card to be read successfully
  if (!mfrc522.PICC_ReadCardSerial()) {
    return 0;
  }
  
  // Convert card UID to a string
  String content = "";
  for (byte i = 0; i < mfrc522.uid.size; i++) {
    if (mfrc522.uid.uidByte[i] < 0x10) {
      content.concat("0"); // Add leading zero for single-digit bytes
    }
    content.concat(String(mfrc522.uid.uidByte[i], HEX));
    if (i < mfrc522.uid.size - 1) {
      content.concat(" "); // Add space between bytes
    }
  }
  content.toUpperCase(); // Convert the string to uppercase
  
  // Check if the card's UID matches the predefined UID
  if (content == "71 4A A6 08") { // Change to your desired UID
    return 1; // Access granted
  } else {
    return -1; // Access denied
  }
}
