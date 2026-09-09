#include "eventdriven.h"
#include "app.h"
#include "pindefs.h"

int state = 0;

void appinit(){
    button_listen(KEY1);
    timer_set (1, 1000);
}
void button_changed (int pin, int v) {
    if (v) { // pressionada
        led_set(LED1, 1);
        exit(0);
    }
}
void timer_expired (int t) {
    state = !state;
    led_set(LED1, state);
    timer_set (1, 1000);
} 
