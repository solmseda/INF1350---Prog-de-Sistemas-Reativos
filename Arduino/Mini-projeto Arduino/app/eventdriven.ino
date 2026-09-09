#include "MultiFuncShield.h"
#include "eventdriven.h"
#include "app.h"
#include "pindefs.h"

const int button_count = 3;
const int timer_count = 5;
const unsigned long debounce_time = 30; //tempo permitido em ms entre pressionar cada botão

/*
Guarda as leituras necessarias para filtrar o ruido mecanico de cada botao.
*/
struct Button {
  int pin;
  int stableValue;
  int lastValue;
  unsigned long lastChange;
  int active;
};

/*
Temporizador nao bloqueante: registra o instante em que o evento deve ocorrer
*/
struct Timer {
  unsigned long expiresAt;
  int active;
};

static Button buttons[button_count];
static Timer timers[timer_count];

/*
Os botoes usam INPUT_PULLUP: pressionado produz LOW (1)
*/
static int button_level(int level) {
  return level == LOW;
}

static int led_value(int on) {
  return on ? LOW : HIGH;
}

/*
Cadastra um pino para monitoramento, ignorando cadastros duplicados
*/
void button_listen(int pin) {
  for (int i = 0; i < button_count; i++) {
    if (buttons[i].active && buttons[i].pin == pin) {
      return;
    }
  }

  for (int i = 0; i < button_count; i++) {
    if (!buttons[i].active) {
      pinMode(pin, INPUT_PULLUP);

      // Comeca com todas as leituras sincronizadas para não gerar um evento falso
      int value = button_level(digitalRead(pin));
      buttons[i].pin = pin;
      buttons[i].stableValue = value;
      buttons[i].lastValue = value;
      buttons[i].lastChange = millis();
      buttons[i].active = 1;
      return;
    }
  }
}

/*
Agenda ou substitui um temporizador
*/ 
void timer_set(int timer, unsigned long ms) {
  if (timer < 0 || timer >= timer_count) {
    return;
  }

  timers[timer].expiresAt = millis() + ms;
  timers[timer].active = 1;
}

void led_set(int led, int on) {
  pinMode(led, OUTPUT);
  digitalWrite(led, led_value(on));
}

void buzzer_set(int on) {
  pinMode(BUZZ, OUTPUT);
  digitalWrite(BUZZ, on ? LOW : HIGH);
}

/*
Monta o display onde o primeiro digito é a quantidade de acertos seguido por "-" 
e o tempo restante
*/ 
void display_status(int correctAnswers, int secondsRemaining) {
  correctAnswers = constrain(correctAnswers, 0, 9);
  secondsRemaining = constrain(secondsRemaining, 0, 99);

  char status[5];
  status[0] = '0' + correctAnswers;
  status[1] = '-';
  status[2] = '0' + (secondsRemaining / 10);
  status[3] = '0' + (secondsRemaining % 10);
  status[4] = '\0';

  MFS.write(status);
}

// Oferece aleatoriedade sem expor diretamente a API do Arduino para a aplicacao.
int random_value(int limit) {
  if (limit <= 0) {
    return 0;
  }
  return random(limit);
}

void setup() {
  // Usando a biblioteca MultiFuncShield apenas para facilitar a escrita no display
  MFS.initialize();
  appinit();
}

void loop() {
  unsigned long now = millis();
  // Mantem a multiplexacao do display feita pela biblioteca.
  MFS.manualDisplayRefresh();

  // Le os botoes por polling. Uma mudanca so e aceita se permanecer estavel
  // durante o debounce; o loop nunca fica bloqueado esperando esse intervalo.
  for (int i = 0; i < button_count; i++) {
    if (!buttons[i].active) {
      continue;
    }

    int value = button_level(digitalRead(buttons[i].pin));
    if (value != buttons[i].lastValue) {
      buttons[i].lastValue = value;
      buttons[i].lastChange = now;
    }

    if (value != buttons[i].stableValue &&
        now - buttons[i].lastChange >= debounce_time) {
      buttons[i].stableValue = value;
      button_changed(buttons[i].pin, value);
    }
  }

  // Dispara temporizadores vencidos
  for (int timer = 0; timer < timer_count; timer++) {
    if (timers[timer].active &&
        (long)(now - timers[timer].expiresAt) >= 0) {
      timers[timer].active = 0;
      timer_expired(timer);
    }
  }
}
