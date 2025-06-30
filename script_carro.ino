// Inclusão das bibliotecas necessárias para a comunicação Bluetooth Low Energy (BLE) no ESP32.
#include <BLEDevice.h> // Biblioteca principal para funcionalidades BLE.
#include <BLEUtils.h>  // Utilitários para BLE.
#include <BLEServer.h> // Funcionalidades para criar um servidor BLE.

// Definição dos pinos do ESP32 conectados ao driver de motor L298N.
#define ENA 25 // Pino de habilitação (PWM para velocidade) do Motor A.
#define IN1 26 // Pino de entrada 1 do Motor A (direção).
#define IN2 27 // Pino de entrada 2 do Motor A (direção).
#define ENB 33 // Pino de habilitação (PWM para velocidade) do Motor B.
#define IN3 32 // Pino de entrada 1 do Motor B (direção).
#define IN4 13 // Pino de entrada 2 do Motor B (direção).

// Variável global para armazenar a velocidade dos motores (valor PWM de 0 a 255).
int velocidade = 200;

// Ponteiros globais para o servidor e a característica BLE.
BLEServer* pServer = nullptr;
BLECharacteristic* pCharacteristic = nullptr;

// UUIDs (Identificadores Únicos Universais) para o serviço e a característica BLE.
// Estes UUIDs são padronizados para serviços de UART sobre BLE.
#define SERVICE_UUID        "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHARACTERISTIC_UUID "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"

// Classe para gerenciar os eventos do servidor BLE (conexão e desconexão).
class MyServerCallbacks : public BLEServerCallbacks {
  // Método chamado quando um cliente BLE se conecta.
  void onConnect(BLEServer* pServer) override {
    Serial.println("Cliente conectado");
  }

  // Método chamado quando um cliente BLE se desconecta.
  void onDisconnect(BLEServer* pServer) override {
    Serial.println("Cliente desconectado");
    // Reinicia o "advertising" para que o ESP32 fique visível para novas conexões.
    pServer->getAdvertising()->start();
  }
};

// Protótipos (declarações) das funções de controle do motor.
void moverFrente();
void moverTras();
void curvaEsquerda();
void curvaDireita();
void parar();

// Classe para gerenciar os eventos da característica BLE (neste caso, escrita de dados).
class MyCallbacks : public BLECharacteristicCallbacks {
  // Método chamado quando um cliente escreve um valor na característica.
  void onWrite(BLECharacteristic* pCharacteristic) override {
    std::string value = pCharacteristic->getValue(); // Obtém o valor escrito.
    if (value.length() > 0) {
      char cmd = value[0]; // Pega o primeiro caractere do valor como comando.
      Serial.print("Recebido comando BLE: ");
      Serial.println(cmd);

      // Executa a função correspondente ao comando recebido.
      switch (cmd) {
        case 'f': moverFrente(); break;
        case 'b': moverTras(); break;
        case 'l': curvaEsquerda(); break;
        case 'r': curvaDireita(); break;
        case 's': parar(); break;
      }
    }
  }
};

// Função de configuração, executada uma vez quando o ESP32 é ligado ou resetado.
void setup() {
  // Inicia a comunicação serial para depuração.
  Serial.begin(115200);

  // Configura os pinos de controle de direção dos motores como saída.
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);

  // Configura os canais de PWM (LEDC) para controlar a velocidade dos motores.
  ledcSetup(0, 1000, 8); // Canal 0, frequência de 1000 Hz, resolução de 8 bits.
  ledcAttachPin(ENA, 0); // Associa o pino ENA ao canal PWM 0.
  ledcSetup(1, 1000, 8); // Canal 1, frequência de 1000 Hz, resolução de 8 bits.
  ledcAttachPin(ENB, 1); // Associa o pino ENB ao canal PWM 1.

  // Inicia o dispositivo BLE com o nome "CarroESP32_BLE".
  BLEDevice::init("CarroESP32_BLE");
  // Cria o servidor BLE.
  pServer = BLEDevice::createServer();
  // Define os callbacks para eventos do servidor (conexão/desconexão).
  pServer->setCallbacks(new MyServerCallbacks());

  // Cria o serviço BLE usando o UUID definido.
  BLEService* pService = pServer->createService(SERVICE_UUID);
  // Cria a característica BLE dentro do serviço.
  pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_WRITE // Define que esta característica pode ser escrita.
  );

  // Define os callbacks para a característica (para o evento de escrita).
  pCharacteristic->setCallbacks(new MyCallbacks());
  // Inicia o serviço BLE.
  pService->start();

  // Configura e inicia o "advertising" (anúncio) do serviço BLE.
  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->start();

  Serial.println("BLE iniciado, aguardando conexão...");
}

// Função de loop principal. Fica vazia pois o controle é feito por interrupções (callbacks) do BLE.
void loop() {
  // O controle do carro é baseado em eventos (callbacks BLE), então o loop principal não precisa fazer nada.
}

// --- Funções de controle dos motores ---

// Move o carro para frente.
void moverFrente() {
  // Configura a direção de ambos os motores para frente.
  digitalWrite(IN1, HIGH); digitalWrite(IN2, LOW);
  digitalWrite(IN3, HIGH); digitalWrite(IN4, LOW);
  // Define a velocidade de ambos os motores.
  ledcWrite(0, velocidade);
  ledcWrite(1, velocidade);
}

// Move o carro para trás.
void moverTras() {
  // Configura a direção de ambos os motores para trás.
  digitalWrite(IN1, LOW); digitalWrite(IN2, HIGH);
  digitalWrite(IN3, LOW); digitalWrite(IN4, HIGH);
  // Define a velocidade de ambos os motores.
  ledcWrite(0, velocidade);
  ledcWrite(1, velocidade);
}

// Faz o carro virar para a esquerda (motor esquerdo parado, motor direito para frente).
void curvaEsquerda() {
  // Para o motor esquerdo (A).
  digitalWrite(IN1, LOW); digitalWrite(IN2, LOW);
  // Move o motor direito (B) para frente.
  digitalWrite(IN3, HIGH); digitalWrite(IN4, LOW);
  // Define a velocidade do motor esquerdo como 0 e do direito como 'velocidade'.
  ledcWrite(0, 0);
  ledcWrite(1, velocidade);
}

// Faz o carro virar para a direita (motor direito parado, motor esquerdo para frente).
void curvaDireita() {
  // Move o motor esquerdo (A) para frente.
  digitalWrite(IN1, HIGH); digitalWrite(IN2, LOW);
  // Para o motor direito (B).
  digitalWrite(IN3, LOW); digitalWrite(IN4, LOW);
  // Define a velocidade do motor esquerdo como 'velocidade' e do direito como 0.
  ledcWrite(0, velocidade);
  ledcWrite(1, 0);
}

// Para o carro.
void parar() {
  // Define a velocidade de ambos os motores como 0.
  ledcWrite(0, 0);
  ledcWrite(1, 0);
}
