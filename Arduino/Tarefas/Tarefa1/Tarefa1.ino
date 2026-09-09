/*
Tarefa 1 pisca-pisca
Nome: Sol Castilho Araújo de Moraes Sêda
Matricula: 2511704
*/ 

#include "pindefs.h"

int lastButton1 = 0; // não apertado
int lastButton2 = 0; // não apertado
int lastButton3 = 0; // não apertado

unsigned long previousMillis = 0;
unsigned long previousBlinkMillis = 0;
unsigned long interval = 200; // 200 ms 

unsigned long previonsBlink = 0;
unsigned long intervalBlinking = 200;

unsigned long lastButton1Pressed = 0;
unsigned long lastButton2Pressed = 0;

bool canBlink = true;

void apagarLeds() {

  // No Multi Function Shield:
  // LOW = LED aceso
  // HIGH = LED apagado

  digitalWrite(LED1, HIGH);
  digitalWrite(LED2, HIGH);
  digitalWrite(LED3, HIGH);
}

void setup() {
 pinMode(LED1, OUTPUT);
 pinMode (KEY1, INPUT_PULLUP);
 pinMode (KEY2, INPUT_PULLUP);
 pinMode (KEY3, INPUT_PULLUP);
 apagarLeds();
}

void loop() {
  unsigned long currentMillis = millis();

  // Resetando os botões para estado solto
  if(digitalRead(KEY1) == HIGH){
    lastButton1 = 0;
  }
  if(digitalRead(KEY2) == HIGH){
    lastButton2 = 0;
  }
  if(digitalRead(KEY3) == HIGH){
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
    // Botão 1 pressionado deixa o blink mais rapido
    if (digitalRead(KEY1) == LOW && lastButton1 == 0) {
      lastButton1Pressed = currentMillis;

      if(intervalBlinking > 25){
        lastButton1 = 1;
        previousMillis = currentMillis; 
        intervalBlinking = intervalBlinking / 2;
      }
    }

    // Botão 2 pressionado deixa o blink mais lento
    else if (digitalRead(KEY2) == LOW && lastButton2 == 0){
      lastButton2Pressed = currentMillis;
      if(intervalBlinking < 10000){
        lastButton2 = 1;
        previousMillis = currentMillis; 
        intervalBlinking = intervalBlinking * 2;
      }
    }
    
    // Botão 3 pressionado para o blink
    if (digitalRead(KEY3) == LOW && lastButton3 == 0){
      lastButton3 = 1; // botão foi apertado
      previousMillis = currentMillis; 
      canBlink = !canBlink;
      digitalWrite(LED1, HIGH);
    }

    // Alteração da tarefa, ao clicar no botão 1 ou 2 salva o tempo em que foi apertado
    // caso o tempo entre eles seja menor que 500 para ou começa o pisca do LED1
    if(abs(lastButton1Pressed - lastButton2Pressed) < 500){
      canBlink = !canBlink;
    }
  }  
}
