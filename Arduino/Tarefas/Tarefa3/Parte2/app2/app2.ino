#include "eventdriven.h"
#include "app.h"
#include "pindefs.h"

const int BLINK_TIMER = 0;
const int KEY1_TIMER = 1;
const int KEY2_TIMER = 2;

const int MIN_PERIOD = 25;
const int MAX_PERIOD = 10000;
const int COMBINATION_INTERVAL = 500;

int ledState = 0;
int blinkEnabled = 1;
int blinkPeriod = 200;
int key1RecentlyPressed = 0;
int key2RecentlyPressed = 0;

void toggleBlink() {
  blinkEnabled = !blinkEnabled;

  if (blinkEnabled) {
    timer_set(BLINK_TIMER, blinkPeriod);
  }
}

void appinit() {
  button_listen(KEY1);
  button_listen(KEY2);
  led_set(LED1, ledState);
  timer_set(BLINK_TIMER, blinkPeriod);
}

void button_changed(int pin, int v) {
  if (!v) {
    return;
  }

  if (pin == KEY1) {
    if (blinkPeriod >= 2 * MIN_PERIOD) {
      blinkPeriod /= 2;
    } else {
      blinkPeriod = MIN_PERIOD;
    }

    if (key2RecentlyPressed) {
      key1RecentlyPressed = 0;
      key2RecentlyPressed = 0;
      toggleBlink();
    } else {
      key1RecentlyPressed = 1;
      timer_set(KEY1_TIMER, COMBINATION_INTERVAL);
    }
  } else if (pin == KEY2) {
    if (blinkPeriod <= MAX_PERIOD / 2) {
      blinkPeriod *= 2;
    } else {
      blinkPeriod = MAX_PERIOD;
    }

    if (key1RecentlyPressed) {
      key1RecentlyPressed = 0;
      key2RecentlyPressed = 0;
      toggleBlink();
    } else {
      key2RecentlyPressed = 1;
      timer_set(KEY2_TIMER, COMBINATION_INTERVAL);
    }
  }
}

void timer_expired(int t) {
  if (t == BLINK_TIMER) {
    if (blinkEnabled) {
      ledState = !ledState;
      led_set(LED1, ledState);
      timer_set(BLINK_TIMER, blinkPeriod);
    }
  } else if (t == KEY1_TIMER) {
    key1RecentlyPressed = 0;
  } else if (t == KEY2_TIMER) {
    key2RecentlyPressed = 0;
  }
}
