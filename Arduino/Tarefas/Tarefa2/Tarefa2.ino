/*
Tarefa 2 mini "Genius"
Nome: Sol Castilho Araújo de Moraes Sêda
Matricula: 2511704
*/ 

#include "pindefs.h"

int sequencia[5];
int posicaoUsuario = 0;

int lastButton1 = 0;
int lastButton2 = 0;
int lastButton3 = 0;

unsigned long previousMillis = 0;
unsigned long interval = 200;

bool esperandoUsuario = false;
bool jogoFinalizado = false;

void setup() {
  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
  pinMode(LED3, OUTPUT);

  pinMode(KEY1, INPUT_PULLUP);
  pinMode(KEY2, INPUT_PULLUP);
  pinMode(KEY3, INPUT_PULLUP);

  apagarLeds();

  randomSeed(analogRead(A0));

  iniciarJogo();
}

void loop() {
  unsigned long currentMillis = millis();

  // Resetando os botões para estado solto
  if (digitalRead(KEY1) == HIGH) {
    lastButton1 = 0;
  }

  if (digitalRead(KEY2) == HIGH) {
    lastButton2 = 0;
  }

  if (digitalRead(KEY3) == HIGH) {
    lastButton3 = 0;
  }

  // Depois que o jogo terminou, botão 1 reinicia o programa
  if (jogoFinalizado) {
    if (digitalRead(KEY1) == LOW && lastButton1 == 0) {
      lastButton1 = 1;
      iniciarJogo();
    }

    return;
  }

  // Esperando o usuário repetir a sequência
  if (esperandoUsuario) {

    // Botão 1
    if (digitalRead(KEY1) == LOW && lastButton1 == 0) {
      lastButton1 = 1;

      verificarResposta(1);
    }

    // Botão 2
    else if (digitalRead(KEY2) == LOW && lastButton2 == 0) {
      lastButton2 = 1;

      verificarResposta(2);
    }

    // Botão 2
    else if (digitalRead(KEY3) == LOW && lastButton3 == 0) {
      lastButton3 = 1;

      verificarResposta(3);
    }
  }
}

void apagarLeds() {
  digitalWrite(LED1, HIGH);
  digitalWrite(LED2, HIGH);
  digitalWrite(LED3, HIGH);
}

void iniciarJogo() {

  jogoFinalizado = false;
  esperandoUsuario = false;

  posicaoUsuario = 0;

  lastButton1 = 0;
  lastButton2 = 0;
  lastButton3 = 0;

  apagarLeds();

  delay(500);

  // Gerando sequência aleatória
  for (int i = 0; i < 5; i++) {
    sequencia[i] = random(1, 4);
  }

  // Mostrando sequência
  for (int i = 0; i < 5; i++) {
    piscarLed(sequencia[i]);
    delay(300);
  }

  esperandoUsuario = true;
}

void piscarLed(int numeroLed) {

  apagarLeds();

  if (numeroLed == 1) {
    digitalWrite(LED1, LOW);
  }

  else if (numeroLed == 2) {
    digitalWrite(LED2, LOW);
  }

  else if (numeroLed == 3) {
    digitalWrite(LED3, LOW);
  }

  delay(400);
  apagarLeds();
  delay(200);
}

void verificarResposta(int tecla) {

  // Se errou
  if (tecla != sequencia[posicaoUsuario]) {

    esperandoUsuario = false;
    jogoFinalizado = true;

    apagarLeds();

    // LED1 aceso indicando erro
    digitalWrite(LED1, LOW);

    return;
  }

  // Se acertou esta posição
  posicaoUsuario++;

  // Se acertou as 5 posições
  if (posicaoUsuario == 5) {

    esperandoUsuario = false;
    jogoFinalizado = true;

    // Acende todos os LEDs
    digitalWrite(LED1, LOW);
    digitalWrite(LED2, LOW);
    digitalWrite(LED3, LOW);
  }
}