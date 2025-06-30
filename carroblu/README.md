# Flutter BLE Car Control App

## Visão Geral

Este é um aplicativo Flutter para controlar um carrinho via Bluetooth Low Energy (BLE). Ele faz busca de dispositivos BLE, permite selecionar um dispositivo e envia comandos para controlar o carrinho (frente, ré, esquerda, direita).

---

## Estrutura do Código

### 1. Importações

```dart
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
```
- **flutter/material.dart**: Widgets e temas do Flutter.
- **flutter_reactive_ble**: Biblioteca para comunicação BLE.
- **permission_handler**: Gerenciamento de permissões do sistema.

---

### 2. Constantes

```dart
const serviceUuid = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
const characteristicUuid = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E";
```
- **serviceUuid**: UUID do serviço BLE do carrinho.
- **characteristicUuid**: UUID da característica para envio de comandos.

---

### 3. MyApp

```dart
class MyApp extends StatelessWidget { ... }
```
- Widget principal do app.
- Define tema, título e tela inicial (`DeviceScanPage`).

---

### 4. DeviceScanPage

```dart
class DeviceScanPage extends StatefulWidget { ... }
```
- Tela inicial para busca e seleção de dispositivos BLE.

#### Estado

```dart
final flutterReactiveBle = FlutterReactiveBle();
final List<DiscoveredDevice> devices = [];
bool scanning = false;
```
- **flutterReactiveBle**: Instância do BLE.
- **devices**: Lista de dispositivos encontrados.
- **scanning**: Indica se está buscando dispositivos.

#### Permissões

```dart
Future<void> requestPermissions() async { ... }
```
- Solicita permissões necessárias para BLE e localização.

#### Busca de Dispositivos

```dart
void startScan() { ... }
```
- Limpa lista de dispositivos.
- Inicia busca por dispositivos BLE com o serviço especificado.
- Adiciona dispositivos encontrados à lista, evitando duplicatas.

#### Interface

```dart
Widget build(BuildContext context) { ... }
```
- Botão para iniciar busca.
- Lista de dispositivos encontrados.
- Ao tocar em um dispositivo, navega para a tela de controle (`ControlPage`).

---

### 5. ControlPage

```dart
class ControlPage extends StatefulWidget { ... }
```
- Tela para controlar o carrinho selecionado.

#### Estado

```dart
final ble = FlutterReactiveBle();
late QualifiedCharacteristic characteristic;
bool connected = false;
```
- **ble**: Instância do BLE.
- **characteristic**: Característica BLE para envio de comandos.
- **connected**: Indica se está conectado ao dispositivo.

#### Conexão

```dart
@override
void initState() { ... }
```
- Inicializa a característica.
- Conecta ao dispositivo selecionado.
- Atualiza o estado de conexão e retorna à tela anterior se desconectar.

#### Envio de Comandos

```dart
void sendCommand(String cmd) async { ... }
```
- Envia comando (um caractere) para o carrinho via BLE.

#### Botão de Controle

```dart
Widget controlButton(String iconLabel, IconData icon, String command) { ... }
```
- Cria botão customizado para cada direção.
- Envia comando ao pressionar e comando de "stop" ao soltar/cancelar.

#### Interface

```dart
Widget build(BuildContext context) { ... }
```
- Mostra botões para frente, ré, esquerda e direita.
- Indica status de conexão pelo AppBar.

---

## Fluxo do Usuário

1. **Permissões**: Ao abrir, solicita permissões necessárias.
2. **Busca**: Usuário clica em "Buscar dispositivos" para encontrar o carrinho.
3. **Seleção**: Usuário seleciona o dispositivo desejado.
4. **Controle**: Usuário controla o carrinho usando os botões direcionais.

---

## Resumo das Funcionalidades

- Busca e exibe dispositivos BLE próximos.
- Permite selecionar um dispositivo para conectar.
- Envia comandos BLE para controlar o carrinho.
- Interface simples e responsiva.
