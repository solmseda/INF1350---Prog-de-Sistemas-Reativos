#ifndef MULTI_FUNC_SHIELD_V2127_H
#define MULTI_FUNC_SHIELD_V2127_H

#include <Arduino.h>

/*
  Driver minimo para o display do Multi-function Shield V2127 usado neste
  projeto. O mapeamento foi verificado diretamente na placa:

  - dados no pino 8, clock no pino 7 e latch no pino 4;
  - segmentos ativos em nivel alto;
  - selecao dos digitos ativa em nivel baixo;
  - posicoes numeradas da esquerda (0) para a direita (3).

  A classe conserva as operacoes da interface original usadas pelo trabalho:
  MFS.initialize(), MFS.write() e MFS.manualDisplayRefresh().
*/
class MultiFuncShieldV2127 {
 public:
  void initialize() {
    pinMode(LATCH_PIN, OUTPUT);
    pinMode(CLOCK_PIN, OUTPUT);
    pinMode(DATA_PIN, OUTPUT);

    digitalWrite(LATCH_PIN, HIGH);
    clear();
  }

  // Escreve um inteiro de 0 a 9999 alinhado à direita.
  void write(int value) {
    value = constrain(value, 0, 9999);
    clear();

    int position = 3;
    do {
      digits[position] = SEGMENTS[value % 10];
      value /= 10;
      position--;
    } while (value > 0 && position >= 0);
  }

  // Escreve ate quatro caracteres, usando a mesma operacao write da biblioteca
  // original. Este projeto necessita apenas de algarismos, '-' e espaco.
  void write(const char *text) {
    clear();
    for (byte position = 0;
         position < DIGIT_COUNT && text[position] != '\0';
         position++) {
      char character = text[position];
      if (character >= '0' && character <= '9') {
        digits[position] = SEGMENTS[character - '0'];
      } else if (character == '-') {
        digits[position] = 0x40;
      }
    }
  }

  // Atualiza um digito por chamada para realizar a multiplexacao sem delay().
  void manualDisplayRefresh() {
    digitalWrite(LATCH_PIN, LOW);

    // O primeiro byte controla os segmentos; o segundo seleciona o digito.
    shiftOut(DATA_PIN, CLOCK_PIN, MSBFIRST, digits[currentDigit]);
    shiftOut(DATA_PIN, CLOCK_PIN, MSBFIRST,
             (byte)~(1 << currentDigit));

    digitalWrite(LATCH_PIN, HIGH);
    currentDigit = (currentDigit + 1) % DIGIT_COUNT;
  }

 private:
  static const byte LATCH_PIN = 4;
  static const byte CLOCK_PIN = 7;
  static const byte DATA_PIN = 8;
  static const byte DIGIT_COUNT = 4;

  // Segmentos ativos em HIGH: bits 0..6 representam a..g; bit 7 e o ponto.
  static const byte SEGMENTS[10];

  byte digits[DIGIT_COUNT];
  byte currentDigit = 0;

  void clear() {
    for (byte i = 0; i < DIGIT_COUNT; i++) {
      digits[i] = 0x00;
    }
  }
};

const byte MultiFuncShieldV2127::SEGMENTS[10] = {
  0x3F,  // 0
  0x06,  // 1
  0x5B,  // 2
  0x4F,  // 3
  0x66,  // 4
  0x6D,  // 5
  0x7D,  // 6
  0x07,  // 7
  0x7F,  // 8
  0x6F   // 9
};

// Instancia global compatível com as chamadas MFS usadas na aplicacao.
MultiFuncShieldV2127 MFS;

#endif
