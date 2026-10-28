# Wi-Fi Monitor

Monitor reativo em Lua para NodeMCU ESP8266. Varre os canais 1–13, guarda até cinco redes com sinal mais forte e agenda outra rodada 30 segundos após o término. Canais sem callback são registrados como sem resposta: isso não significa que estejam vazios.

## Instalação

Envie todos os arquivos de `nodemcu/` para a raiz do sistema de arquivos da placa, incluindo **index.html**, **http_connection.lua**, **http_status.lua**, **http_networks.lua** e **http_quote.lua**. Não envie a pasta `tests/`. Preserve suas credenciais em `config.lua` e reinicie com `node.restart()`.

Antes de iniciar o Wi-Fi, `init.lua` usa `node.compile()` para gerar `http_connection.lc`, `http_status.lc`, `http_networks.lc` e `http_quote.lc` na propria placa. Isso evita o pico de RAM do compilador durante requisicoes. Os arquivos sao regenerados em cada boot a partir dos fontes enviados. Aguarde as quatro linhas `[INIT] Compilando`. Se a compilacao falhar, a inicializacao para e informa o erro. Nao use o `luac` do computador para gerar esses arquivos: o formato precisa ser compativel com o firmware.

Abra `http://IP-DA-PLACA/` em um navegador na mesma rede. Use o IP mostrado no terminal; ele pode mudar. A página não utiliza serviços externos. A consulta automática ocorre a cada dez segundos e não dispara scans.

## Rotas

| Rota | Resposta |
|---|---|
| `GET /` | Dashboard com estado, heap e tabela das redes |
| `GET /api/status` | JSON com IP, uptime, estado, heap, último resultado e contadores de canais |
| `GET /api/networks` | Array JSON de até cinco redes com SSID, RSSI, autenticação, canal e BSSID |

`last_result` vale `not_started`, `complete`, `partial` ou `error`. `received`, `missing` e `unattempted` descrevem a última rodada encerrada. `scanning` e `channel` descrevem a atividade atual. Os tempos são segundos desde o boot, sem data de calendário.

A lista é reconstruída durante o scan: enquanto `scanning=true`, as redes são provisórias. `last_update` indica o término da última rodada que recebeu algum resultado; não certifica que todos os canais responderam. As duas rotas são consultadas separadamente e podem refletir instantes diferentes.

## Memória e HTTP

O HTML fica em arquivo e é transmitido em blocos de 512 bytes, após a confirmação de envio anterior. O código da conexão e da API é carregado sob demanda e liberado após a desconexão. As redes são serializadas individualmente a partir de uma cópia das referências das strings, mantendo o array consistente durante o envio.

Uma conexão é atendida por vez; acessos simultâneos ou heap abaixo de 10.000 bytes recebem HTTP 503. O navegador tenta novamente após dez segundos. Durante toda a varredura, requisicoes recebem 503 antes de carregar os handlers HTTP. Durante uma resposta HTTP, o scanner nao inicia outra rodada. A pagina preserva a lista anterior e tenta consultar novamente quando a placa estiver disponivel. Isso evita sobrepor as duas cargas em RAM. As respostas JSON nao utilizam o encoder nativo sjson. O limite preventivo do scanner permanece em 12.000 bytes. Essas proteções não substituem a medição do consumo real na placa.

## Testes no computador

Da raiz do repositório, com Lua instalado:

```sh
lua "NodeMCU/Mini-projeto NodeMCU/Monitoramento Wifi/tests/http_test.lua"
lua "NodeMCU/Mini-projeto NodeMCU/Monitoramento Wifi/tests/scanner_test.lua"
```

Os testes simulam APIs do firmware e verificam protocolo HTTP, streaming, snapshots, callbacks, timeouts e agendamento. Não reproduzem a RAM nem o rádio do ESP8266.

## Validação na placa

1. Confirmar o carregamento de `/`, `/api/status` e `/api/networks`.
2. Manter o dashboard aberto por pelo menos três rodadas completas e comparar o heap ao término de cada uma com o teste anterior sem navegador (~14 KB).
3. Confirmar atualização da tabela e indicação de varredura parcial.
4. Fechar e reabrir a página durante uma transferência e verificar se novas requisições continuam funcionando.
5. Abrir uma segunda aba e verificar recuperação após eventual HTTP 503.

A estabilidade da versão anterior foi observada em duas rodadas na placa. Esta versão com API e dashboard ainda precisa dessa validação integrada.
