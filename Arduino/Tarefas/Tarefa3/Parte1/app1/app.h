/* chama aplicação para iniciar configuração */
void appinit(void);
/* avisa que 'pin' passou a pressionado (v = 1) ou solto (v = 0) */
void button_changed (int pin, int v);
/* avisa que timer 't' expirou */
void timer_expired(int t);