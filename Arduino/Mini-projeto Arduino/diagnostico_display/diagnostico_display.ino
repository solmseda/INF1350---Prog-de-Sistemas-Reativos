#include <DIYables_MultiFuncShield.h>

const unsigned long TEST_INTERVAL = 1000;

unsigned long lastChange = 0;
int currentNumber = 0;

void showCurrentNumber() {
  MFS.display.clear();
  MFS.display.setNumber(4, currentNumber);
  MFS.display.show();
}

void setup() {
  MFS.begin();

  // Inicia o teste no digito mais à direita mostrando o numero zero.
  showCurrentNumber();
}

void loop() {
  // Mantem a multiplexacao: somente o ultimo digito possui segmentos ativos.
  MFS.loop();

  unsigned long now = millis();
  if (now - lastChange >= TEST_INTERVAL) {
    lastChange = now;
    currentNumber = (currentNumber + 1) % 10;
    showCurrentNumber();
  }
}
