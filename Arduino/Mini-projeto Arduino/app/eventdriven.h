// Servicos nao bloqueantes oferecidos pela infraestrutura para a aplicacao.
void button_listen(int pin);
void timer_set(int timer, unsigned long ms);
void led_set(int led, int on);
void buzzer_set(int on);
void display_status(int correctAnswers, int secondsRemaining);
int random_value(int limit);
