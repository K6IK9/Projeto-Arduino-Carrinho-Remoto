# 🚗 Projeto Arduino Carrinho Remoto

Um projeto completo de carrinho robótico controlado via Bluetooth Low Energy (BLE), desenvolvido com ESP32 e aplicativo Flutter para controle remoto.

## 📋 Visão Geral

Este projeto consiste em:
- **Hardware**: Carrinho robótico baseado em ESP32 com driver de motor L298N
- **Software**: Aplicativo Flutter multiplataforma para controle via BLE
- **Comunicação**: Bluetooth Low Energy (BLE) para comunicação wireless

## 🛠️ Componentes Utilizados

### Hardware
- **ESP32**: Microcontrolador principal com capacidades BLE
- **Driver L298N**: Controle de dois motores DC
- **Motores DC**: Para movimentação do carrinho
- **Chassi**: Estrutura do carrinho robótico
- **Fonte de alimentação**: Para ESP32 e motores

### Software
- **Arduino IDE**: Para programação do ESP32
- **Flutter**: Framework para desenvolvimento do aplicativo
- **Dart**: Linguagem de programação do aplicativo

## 📁 Estrutura do Projeto

```
Projeto Arduino Carrinho Remoto/
├── script_carro.ino           # Código do ESP32 (Arduino)
└── carroblu/                  # Aplicativo Flutter
    ├── lib/
    │   └── main.dart         # Código principal do app
    ├── pubspec.yaml          # Dependências do Flutter
    └── [outras pastas Flutter]
```

## 🔧 Configuração do Hardware

### Conexões ESP32 ↔ L298N

| ESP32 | L298N | Função |
|-------|-------|--------|
| GPIO 25 | ENA | PWM Motor A (Velocidade) |
| GPIO 26 | IN1 | Direção Motor A |
| GPIO 27 | IN2 | Direção Motor A |
| GPIO 33 | ENB | PWM Motor B (Velocidade) |
| GPIO 32 | IN3 | Direção Motor B |
| GPIO 13 | IN4 | Direção Motor B |

### Esquema de Montagem
1. Conecte os motores DC às saídas do L298N
2. Ligue a alimentação dos motores ao L298N
3. Conecte os pinos de controle conforme tabela acima
4. Alimente o ESP32 (via USB ou fonte externa)

## 📱 Funcionalidades do Aplicativo

- **Busca automática** de dispositivos BLE
- **Interface intuitiva** com botões direcionais
- **Controle em tempo real** do carrinho
- **Feedback visual** do status de conexão
- **Suporte multiplataforma** (Android, iOS)

### Comandos de Controle

| Comando | Ação |
|---------|------|
| `f` | Mover para frente |
| `b` | Mover para trás |
| `l` | Virar à direita |
| `r` | Virar à esquerda |
| `s` | Parar |

## 🚀 Como Usar

### 1. Preparação do ESP32

1. Abra o arquivo `script_carro.ino` no Arduino IDE
2. Instale as bibliotecas necessárias:
   - ESP32 BLE Arduino
3. Conecte o ESP32 via USB
4. Selecione a placa ESP32 e a porta correta
5. Faça o upload do código

### 2. Configuração do App Flutter

1. Navegue até a pasta `carroblu/`
2. Execute os comandos:
   ```bash
   flutter pub get
   flutter run
   ```

### 3. Operação

1. Ligue o ESP32 (o LED azul deve piscar indicando modo BLE)
2. Abra o aplicativo no smartphone
3. Toque em "Buscar dispositivos"
4. Selecione "CarroESP32_BLE" da lista
5. Use os botões direcionais para controlar o carrinho

## 🔍 Detalhes Técnicos

### ESP32 (Arduino)
- **Nome BLE**: `CarroESP32_BLE`
- **Service UUID**: `6E400001-B5A3-F393-E0A9-E50E24DCCA9E`
- **Characteristic UUID**: `6E400002-B5A3-F393-E0A9-E50E24DCCA9E`
- **Velocidade padrão**: 200 (PWM de 0-255)
- **Frequência PWM**: 1000 Hz

### Aplicativo Flutter
- **Dependências principais**:
  - `flutter_reactive_ble`: Comunicação BLE
  - `permission_handler`: Gerenciamento de permissões
- **Permissões necessárias**:
  - Bluetooth Scan
  - Bluetooth Connect
  - Location (em alguns dispositivos)

## 🎯 Funcionalidades Implementadas

### ESP32
- [x] Servidor BLE configurado
- [x] Controle PWM para velocidade
- [x] Funções de movimento (frente, trás, curvas)
- [x] Auto-reconexão BLE
- [x] Feedback via Serial Monitor

### Aplicativo
- [x] Scanner de dispositivos BLE
- [x] Interface de controle intuitiva
- [x] Gerenciamento de conexão
- [x] Controle por toque (press/release)
- [x] Feedback visual de status

## 🔧 Possíveis Melhorias

- [ ] Controle de velocidade variável
- [ ] Sensor de distância para evitar obstáculos
- [ ] Modo autônomo
- [ ] Feedback de bateria
- [ ] Gravação e reprodução de movimentos

## 🐛 Solução de Problemas

### ESP32 não aparece na busca
- Verifique se o código foi carregado corretamente
- Confirme se o ESP32 está ligado
- Reinicie o ESP32

### App não conecta ao ESP32
- Verifique se as permissões foram concedidas
- Certifique-se de que o Bluetooth está ativado
- Tente reiniciar o aplicativo

### Carrinho não responde aos comandos
- Verifique as conexões do L298N
- Confirme a alimentação dos motores
- Teste via Serial Monitor do Arduino IDE

## 📄 Licença

Este projeto é open source e está disponível sob a licença MIT.

## 👨‍💻 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para:
- Reportar bugs
- Sugerir melhorias
- Enviar pull requests

## 📧 Contato

Para dúvidas ou sugestões, abra uma issue no repositório.

---

**Desenvolvido por Kaike Matos com ❤️ usando ESP32 e Flutter**
