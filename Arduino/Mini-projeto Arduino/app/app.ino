/*
Mini-projeto: Genius com desarme de bomba
Nome: Sol Castilho Araujo de Moraes Seda
Matricula: 2511704
*/

#include "eventdriven.h"
#include "app.h"
#include "pindefs.h"

// Cada identificador reserva uma posicao no vetor de temporizadores da
// infraestrutura. Assim, varios eventos podem ser agendados ao mesmo tempo.
const int countdown_timer = 0;
const int game_timer = 1;
const int input_timer = 2;
const int alarm_timer = 3;

const int sequence_size = 3;

// Duracoes usadas pelo jogo
const unsigned long start_delay = 500;
const unsigned long led_on_time = 400;
const unsigned long alarm_toogle_time = 200;

/*
Maquina de estados do jogo
*/
enum GameState {
  STARTING,
  SHOWING_LED,
  BETWEEN_LEDS,
  WAITING_INPUT,
  WAITING_SEQUENCE,
  DISARMED,
  EXPLODED
};

GameState gameState;
// Sequencia sorteada e indices usados, respectivamente, para exibi-la e para
// conferir a resposta fornecida pelo jogador.
int sequence[sequence_size];
int sequencePosition;
int inputPosition;
// Conta sequencias completas respondidas corretamente. E diferente de
// inputPosition, que conta teclas dentro da sequencia atual.
int successfulRounds;
int secondsRemaining;
// Estado das teclas 1 e 2 e mascara dos botoes pressionados. A mascara permite
// reconhecer o comando simultaneo KEY1 + KEY2 mesmo com eventos separados.
int key1Down;
int key2Down;
int pendingButtons;
int alarmOn;

void turnOffGameLeds() {
  led_set(LED1, 0);
  led_set(LED2, 0);
  led_set(LED3, 0);
}

/*
Seta o valor no led correspondente
*/
void setSequenceLed(int value, int on) {
  if (value == 1) {
    led_set(LED1, on);
  } else if (value == 2) {
    led_set(LED2, on);
  } else if (value == 3) {
    led_set(LED3, on);
  }
}

/*
Monta a sequência aleatória dos leds, usando valores entre 1 e 3 
para representar cada led
*/
void generateSequence() {
  for (int i = 0; i < sequence_size; i++) {
    sequence[i] = random_value(3) + 1;
  }
}

// Acende o LED da posicao atual. O temporizador o apagara depois de LED_ON_TIME.
void showNextLed() {
  gameState = SHOWING_LED;
  setSequenceLed(sequence[sequencePosition], 1);
  timer_set(game_timer, led_on_time);
}

/*
Reinicia os leds antes de mostrar a sequência
*/
void beginSequence() {
  turnOffGameLeds();
  sequencePosition = 0;
  inputPosition = 0;
  showNextLed();
}

/*
Se o tempo esgotar inicia o buzzer
*/
void explodeBomb() {
  secondsRemaining = 0;
  display_status(successfulRounds, secondsRemaining);
  turnOffGameLeds();
  led_set(LED4, 0);
  gameState = EXPLODED;
  alarmOn = 1;
  buzzer_set(alarmOn);
  timer_set(alarm_timer, alarm_toogle_time);
}

/*
Desarma a boma após três sequências corretas
*/
void disarmBomb() {
  turnOffGameLeds();
  buzzer_set(0);
  led_set(LED4, 1);
  gameState = DISARMED;
}

/*
Inicia uma nova partida resetando todos os dados e contagem
*/
void startGame() {
  secondsRemaining = 90;
  sequencePosition = 0;
  inputPosition = 0;
  successfulRounds = 0;
  pendingButtons = 0;
  alarmOn = 0;

  turnOffGameLeds();
  led_set(LED4, 0);
  buzzer_set(0);
  display_status(successfulRounds, secondsRemaining);

  generateSequence();
  gameState = STARTING;
  timer_set(countdown_timer, 1000);
  timer_set(game_timer, start_delay);
}

/*
Uma resposta errada reduz o tempo e apresenta uma nova sequencia. Se a
penalidade esgotar o contador, a bomba explode imediatamente.
*/
void applyPenalty() {
  secondsRemaining -= 10;
  if (secondsRemaining <= 0) {
    explodeBomb();
    return;
  }

  successfulRounds = 0;
  display_status(successfulRounds, secondsRemaining);
  turnOffGameLeds();
  inputPosition = 0;
  generateSequence();
  gameState = WAITING_SEQUENCE;
  timer_set(game_timer, start_delay);
}

/* 
Compara uma tecla com o item esperado. Somente uma sequencia inteira correta
conta como uma vitoria; tres vitorias consecutivas desarmam a bomba.
*/ 
void checkAnswer(int button) {
  if (gameState != WAITING_INPUT) {
    return;
  }

  if (button != sequence[inputPosition]) {
    applyPenalty();
    return;
  }

  inputPosition++;
  if (inputPosition == sequence_size) {
    successfulRounds++;
    display_status(successfulRounds, secondsRemaining);

    if (successfulRounds == 3) {
      disarmBomb();
    } else {
      // Prepara outra rodada sem interromper a contagem regressiva.
      generateSequence();
      gameState = WAITING_SEQUENCE;
      timer_set(game_timer, start_delay);
    }
  }
}

void appinit() {
  button_listen(KEY1);
  button_listen(KEY2);
  button_listen(KEY3);
  startGame();
}

// Callback chamado somente depois que a infraestrutura elimina o ruido
// mecanico (debounce) de uma mudanca de botao.
void button_changed(int pin, int pressed) {
  if (pin == KEY1) {
    key1Down = pressed;
  } else if (pin == KEY2) {
    key2Down = pressed;
  }

  // Liberar uma tecla apenas atualiza seu estado; somente o pressionamento
  // representa uma entrada para o jogo.
  if (!pressed) {
    return;
  }

  // Cada bit identifica uma tecla recebida durante a pequena janela de acorde.
  if (pin == KEY1) {
    pendingButtons |= 1;
  } else if (pin == KEY2) {
    pendingButtons |= 2;
  } else if (pin == KEY3) {
    pendingButtons |= 4;
  }

  timer_set(input_timer, 50);
}

// Centraliza as transicoes provocadas pelos quatro temporizadores da aplicacao.
void timer_expired(int timer) {
  if (timer == countdown_timer) {
    // Mantem a contagem regressiva ativa ate um dos estados finais.
    if (gameState != DISARMED && gameState != EXPLODED) {
      secondsRemaining--;
      display_status(successfulRounds, secondsRemaining);

      if (secondsRemaining <= 0) {
        explodeBomb();
      } else {
        timer_set(countdown_timer, 1000);
      }
    }
  } else if (timer == game_timer) {
    // Alterna entre LED aceso e intervalo apagado para exibir a sequencia.
    if (gameState == STARTING || gameState == WAITING_SEQUENCE) {
      beginSequence();
    } else if (gameState == SHOWING_LED) {
      setSequenceLed(sequence[sequencePosition], 0);
      gameState = BETWEEN_LEDS;
      timer_set(game_timer, 250);
    } else if (gameState == BETWEEN_LEDS) {
      sequencePosition++;
      if (sequencePosition < sequence_size) {
        showNextLed();
      } else {
        gameState = WAITING_INPUT;
      }
    }
  } else if (timer == input_timer) {
    // Copia e limpa a mascara para que estes pressionamentos sejam processados
    // uma unica vez. KEY1 + KEY2 tem prioridade e reinicia a partida.
    int buttons = pendingButtons;
    pendingButtons = 0;

    if ((key1Down && key2Down) || (buttons & 3) == 3) {
      startGame();
    } else if (buttons & 1) {
      checkAnswer(1);
    } else if (buttons & 2) {
      checkAnswer(2);
    } else if (buttons & 4) {
      checkAnswer(3);
    }
  } else if (timer == alarm_timer && gameState == EXPLODED) {
    // Rearma o proprio temporizador para produzir um alarme continuo pulsante.
    alarmOn = !alarmOn;
    buzzer_set(alarmOn);
    timer_set(alarm_timer, alarm_toogle_time);
  }
}
