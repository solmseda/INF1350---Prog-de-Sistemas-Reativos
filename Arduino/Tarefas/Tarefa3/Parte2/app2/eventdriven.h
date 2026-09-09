/* aplicação quer ser notificada de alterações em 'pin' */
void button_listen (int pin);
/* liga timer 't' (0, 1 ou 2) para 'ms' milisegundos. timer só dispara uma vez */
void timer_set (int t, int ms);
/* acende (on = 1) ou apaga (on = 0) o led */
void led_set (int led, int on);