#define LED1       10
#define LED2       11
#define LED3       12
#define LED4       13
#define BUZZ        3
#define KEY1       A1
#define KEY2       A2
#define KEY3       A3
#define POT        A0

int lastButton1 = 0; // não apertado
int lastButton2 = 0; // não apertado
int lastButton3 = 0; // não apertado

unsigned long previousMillis = 0;
unsigned long previousBlinkMillis = 0;
unsigned long interval = 200; // 200 ms 

unsigned long previonsBlink = 0;
unsigned long intervalBlinking = 200;

bool canBlink = true;

void setup() {
 pinMode(LED1, OUTPUT);
 pinMode (KEY1, INPUT_PULLUP);
 pinMode (KEY2, INPUT_PULLUP);
 pinMode (KEY3, INPUT_PULLUP);
 digitalWrite(LED1, HIGH);
}

void loop() {
  unsigned long currentMillis = millis();

  if( digitalRead(KEY1) == HIGH){
    lastButton1 = 0;
  }
  if( digitalRead(KEY2) == HIGH){
    lastButton2 = 0;
  }
  if( digitalRead(KEY3) == HIGH){
    lastButton3 = 0;
  }

  // piscando o led
  if(canBlink){
    if(currentMillis - previousBlinkMillis >= intervalBlinking){
      if(digitalRead(LED1) == HIGH){
        previousBlinkMillis = currentMillis;
        digitalWrite(LED1, LOW);
      }
      else{
        previousBlinkMillis = currentMillis;
        digitalWrite(LED1, HIGH);
      }
    }
  }

  // Se um botão foi pressionado
  if (currentMillis - previousMillis >= interval) {
    // Botão 1 deixa o blink mais rapido
    if (digitalRead(KEY1) == LOW && intervalBlinking > 25 && lastButton1 == 0) {
      lastButton1 = 1;
      previousMillis = currentMillis; 
      intervalBlinking = intervalBlinking / 2;
    }

    // Botão 2 deixa o blink mais lento
    else if (digitalRead(KEY2) == LOW && intervalBlinking < 10000 && lastButton2 == 0){
      lastButton2 = 1;
      previousMillis = currentMillis; 
      intervalBlinking = intervalBlinking * 2;
    }
    
    // Botão 3 para o blink
    if (digitalRead(KEY3) == LOW && lastButton3 == 0){
      lastButton3 = 1; // botão foi apertado
      previousMillis = currentMillis; 
      canBlink = !canBlink;
      digitalWrite(LED1, HIGH);
    }
  }  
}
