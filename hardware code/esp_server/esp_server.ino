#include <WiFi.h>
#include <HTTPClient.h>
#include <NTPClient.h>
#include <WiFiUdp.h>
#include <arduino.h>

#include <ESP32Servo.h>

// Define servo pin
const int servoPin = 18; // Replace with the GPIO pin you're using

// Create a Servo object
Servo myServo;


#define RXp2 16
#define TXp2 17

WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org", 0, 60000); // GMT Offset, Update Interval


const char* ssid = "shubham";
const char* password = "KOLiya@259";
const char* apiKey = "AIzaSyAoMLi78A8DL5a1Z-8SmtGVYKibROZOrKk";  // Web API Key from Firebase
const char* projectID = "newp-ca748";      // Project ID from Firebase Console

String documentPath = "info/1234";  // Path to your document
String collectionPath = "1234";  // Firestore collection path


void setup() {

  myServo.attach(servoPin);
  myServo.write(90);
  pinMode(2,OUTPUT);
  // put your setup code here, to run once:
  Serial.begin(115200);
  Serial2.begin(9600, SERIAL_8N1, RXp2, TXp2);
    WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");

  timeClient.begin();
  timeClient.update();
}
void loop() {
    String rec=Serial2.readString();
    rec.trim(); 
    Serial.println(rec);
    if(rec=="1"){
      addDocumentToFirestore(true);
    }
    else if(rec=="0"){
      addDocumentToFirestore(false);
    }
    if(rec[0]=='s'){
      String pass = readFromFirestore();
      String reci = rec.substring(1, 5);
      if(pass==reci){
        Serial.println("correct passkey");
        addDocumentToFirestore(true);
      }
      else{
        Serial.println("incoorect passkey");
        addDocumentToFirestore(false);
      }
    }
}



String formatTimestamp(const long long int epochTime) {
    // Convert epoch time to time structure
    struct tm * timeinfo;
    timeinfo = localtime(&epochTime);

    // Format the time into ISO 8601 format
    char buffer[30];
    strftime(buffer, sizeof(buffer), "%Y-%m-%dT%H:%M:%SZ", timeinfo); // Format: YYYY-MM-DDTHH:MM:SSZ

    return String(buffer);
}

void addDocumentToFirestore(bool authStatus) {
  if(authStatus==true){
    digitalWrite(2,1);
    myServo.write(0);
  }
  else{
    digitalWrite(2,0);
    myServo.write(90);
  }

  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    String url = "https://firestore.googleapis.com/v1/projects/" + String(projectID) + "/databases/(default)/documents/" + collectionPath;

    http.begin(url.c_str());
    http.addHeader("Content-Type", "application/json");
    timeClient.update();
    unsigned long currentEpoch = timeClient.getEpochTime(); // Get current time in seconds since epoch
    // Format the current timestamp in ISO 8601 format
    String timestamp = formatTimestamp(currentEpoch);
    // Convert the boolean to a string ("true" or "false") for the JSON payload
    String authStatusString = authStatus ? "true" : "false";
    
    // Define the document fields and values with dynamic authStatus and placeholder for createdAt
   String payload = R"(
            {
              "fields": {
                "succAuth": { "booleanValue": )" + authStatusString + R"( },
                "timestamp": { "stringValue": ")" + timestamp + R"(" }
              }
            }
        )";

    int httpResponseCode = http.POST(payload);

    if (httpResponseCode > 0) {
      String response = http.getString();
      Serial.println("Document added successfully:");
      Serial.println(response);
    } else {
      Serial.print("Error code: ");
      Serial.println(httpResponseCode);
    }
    http.end();
  } else {
    Serial.println("WiFi not connected");
  }
  if(authStatus==true){
  delay(2000);
  digitalWrite(2,0);
  myServo.write(90);
  }
}

void writeToFirestore() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    String url = "https://firestore.googleapis.com/v1/projects/" + String(projectID) + "/databases/(default)/documents/" + documentPath;

    http.begin(url.c_str());
    http.addHeader("Content-Type", "application/json");

    // Update only the passstatus field, keeping other fields intact
    String payload = R"(
      {
        "fields": {
          "passkey": { "stringValue": "-1" }
        }
      }
    )";

    int httpResponseCode = http.PATCH(payload);

    if (httpResponseCode > 0) {
      String response = http.getString();
      Serial.println("Update Response:");
      Serial.println(response);
    } else {
      Serial.print("Error code: ");
      Serial.println(httpResponseCode);
    }
    http.end();
  } else {
    Serial.println("WiFi not connected");
  }
}

String readFromFirestore() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    String url = "https://firestore.googleapis.com/v1/projects/" + String(projectID) + "/databases/(default)/documents/" + documentPath;

    http.begin(url.c_str());
    int httpResponseCode = http.GET();

    if (httpResponseCode > 0) {
      String response = http.getString();
      Serial.println("Firestore Response:");
      Serial.println(response);
      
      // Extracting the passkey from the response
      String passkey = extractPasskey(response);
      if(passkey!="-1"){
        writeToFirestore();
      }
      Serial.print("Passkey: ");
      Serial.println(passkey);
      return passkey;
    } else {
      Serial.print("Error code: ");
      Serial.println(httpResponseCode);
    }
    http.end();
  } else {
    Serial.println("WiFi not connected");
  }
  return "-1";
}

String extractPasskey(const String& jsonResponse) {
  // A basic way to extract the passkey value from the JSON response
  int passkeyIndex = jsonResponse.indexOf("\"passkey\":");
  if (passkeyIndex == -1) return ""; // If "passkey" not found
  
  int startIndex = jsonResponse.indexOf("\"stringValue\":", passkeyIndex) + 15; // 15 is the length of "\"stringValue\":"
  // int endIndex = jsonResponse.indexOf("\"", startIndex);
  
  return jsonResponse.substring(startIndex+1, startIndex+5);
}



