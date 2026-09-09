#include "eventdriven.h"
#include "app.h"

struct Button {
  int pin;
  int stableValue;
  int lastValue;
  unsigned long lastChange;
  int active;
};

struct Timer {
  unsigned long expiresAt;
  int active;
};

static Button buttons[3];
static Timer timers[3];

static int button_level(int level) {
  return level == LOW;
}

static int led_value(int on) {
  return on ? LOW : HIGH;
}

void button_listen(int pin) {
  for (int i = 0; i < 3; i++) {
    if (buttons[i].active && buttons[i].pin == pin) {
      return;
    }
  }

  for (int i = 0; i < 3; i++) {
    if (!buttons[i].active) {
      pinMode(pin, INPUT_PULLUP);

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

void timer_set(int t, int ms) {
  if (t < 0 || t >= 3) {
    return;
  }

  timers[t].expiresAt = millis() + (unsigned long)ms;
  timers[t].active = 1;
}

void led_set(int led, int on) {
  pinMode(led, OUTPUT);
  digitalWrite(led, led_value(on));
}

void setup() {
  appinit();
}

void loop() {
  unsigned long currentMillis = millis();

  for (int i = 0; i < 3; i++) {
    if (!buttons[i].active) {
      continue;
    }

    int value = button_level(digitalRead(buttons[i].pin));
    if (value != buttons[i].lastValue) {
      buttons[i].lastValue = value;
      buttons[i].lastChange = currentMillis;
    }

    if (value != buttons[i].stableValue &&
        currentMillis - buttons[i].lastChange >= 30) {
      buttons[i].stableValue = value;
      button_changed(buttons[i].pin, value);
    }
  }

  for (int t = 0; t < 3; t++) {
    if (timers[t].active && (long)(currentMillis - timers[t].expiresAt) >= 0) {
      timers[t].active = 0;
      timer_expired(t);
    }
  }
}
