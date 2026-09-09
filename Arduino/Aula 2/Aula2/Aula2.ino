#define LED1       10
#define LED2       11
#define LED3       12
#define LED4       13
#define BUZZ        3
#define KEY1       A1
#define KEY2       A2
#define KEY3       A3
#define POT        A0

int ledOn = 0;

unsigned long previousMillis = 0;
unsigned long interval = 200; // 200 ms 

void setup() {
 pinMode(LED1, OUTPUT);
 pinMode (KEY1, INPUT_PULLUP);
 digitalWrite(LED1, HIGH);
}

void loop() {
  unsigned long currentMillis = millis();
  // if time enough has elapsed, check if the pushbutton is pressed.
  // if it is, the buttonState is LOW:
  if (currentMillis - previousMillis >= interval) {
    if (digitalRead(KEY1) == LOW) {
      previousMillis = currentMillis; // save the last time you read LOW
      ledOn = !ledOn;
      digitalWrite(LED1, ledOn);
    }
  }
}
