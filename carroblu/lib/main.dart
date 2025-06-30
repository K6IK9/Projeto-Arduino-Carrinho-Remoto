/// Importa os pacotes necessários para o funcionamento do aplicativo:
/// - `flutter/material.dart`: fornece widgets e temas para a interface do usuário.
/// - `flutter_reactive_ble`: permite a comunicação BLE (Bluetooth Low Energy).
/// - `permission_handler`: gerencia permissões de runtime.
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

/// Função principal que inicia o aplicativo Flutter.
void main() => runApp(const MyApp());

/// UUIDs do serviço e característica BLE utilizados para comunicação.
const serviceUuid = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
const characteristicUuid = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E";

/// Widget principal do aplicativo que configura o tema e define a página inicial.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carro BLE', // Título do aplicativo.
      debugShowCheckedModeBanner: false, // Remove a faixa de debug.
      theme: ThemeData(
        useMaterial3: true, // Habilita o Material Design 3.
        colorSchemeSeed: Colors.indigo, // Define a cor principal.
        fontFamily: 'Roboto', // Define a fonte padrão.
      ),
      home: const DeviceScanPage(), // Página inicial do aplicativo.
    );
  }
}

/// Página responsável por escanear dispositivos BLE.
class DeviceScanPage extends StatefulWidget {
  const DeviceScanPage({super.key});
  @override
  State<DeviceScanPage> createState() => _DeviceScanPageState();
}

class _DeviceScanPageState extends State<DeviceScanPage> {
  /// Instância do FlutterReactiveBle para gerenciar BLE.
  final flutterReactiveBle = FlutterReactiveBle();

  /// Lista de dispositivos encontrados durante o escaneamento.
  final List<DiscoveredDevice> devices = [];

  /// Indica se o escaneamento está em andamento.
  bool scanning = false;

  @override
  void initState() {
    super.initState();
    requestPermissions(); // Solicita permissões necessárias ao iniciar.
  }

  /// Solicita permissões de Bluetooth e localização ao usuário.
  Future<void> requestPermissions() async {
    await [
      Permission.bluetoothScan, // Permissão para escanear dispositivos BLE.
      Permission.bluetoothConnect, // Permissão para conectar a dispositivos BLE.
      Permission.location, // Permissão de localização (necessária para BLE em alguns dispositivos).
    ].request();
  }

  /// Inicia o escaneamento de dispositivos BLE com o UUID do serviço especificado.
  void startScan() {
    devices.clear(); // Limpa a lista de dispositivos encontrados.
    setState(() => scanning = true); // Atualiza o estado para indicar escaneamento.

    flutterReactiveBle
        .scanForDevices(withServices: [Uuid.parse(serviceUuid)]) // Escaneia dispositivos com o serviço especificado.
        .listen((device) {
      // Adiciona dispositivos únicos à lista.
      if (devices.indexWhere((d) => d.id == device.id) == -1) {
        setState(() => devices.add(device));
      }
    }, onError: (_) => setState(() => scanning = false)); // Para o escaneamento em caso de erro.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecionar Carro')), // Título da página.
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            /// Botão para iniciar o escaneamento de dispositivos BLE.
            ElevatedButton.icon(
              onPressed: scanning ? null : startScan, // Desabilita o botão durante o escaneamento.
              icon: const Icon(Icons.search), // Ícone do botão.
              label: Text(scanning ? 'Buscando...' : 'Buscar dispositivos'), // Texto do botão.
            ),
            const SizedBox(height: 16), // Espaçamento entre o botão e a lista.
            Expanded(
              /// Exibe uma mensagem se nenhum dispositivo for encontrado ou uma lista de dispositivos.
              child: devices.isEmpty
                  ? const Center(child: Text('Nenhum dispositivo encontrado'))
                  : ListView.builder(
                      itemCount: devices.length, // Número de dispositivos encontrados.
                      itemBuilder: (context, index) {
                        final d = devices[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.directions_car), // Ícone do dispositivo.
                            title: Text(d.name.isNotEmpty ? d.name : 'Desconhecido'), // Nome do dispositivo.
                            subtitle: Text(d.id), // ID do dispositivo.
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ControlPage(device: d), // Navega para a página de controle.
                            )),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}

/// Página de controle do carro BLE.
class ControlPage extends StatefulWidget {
  final DiscoveredDevice device; // Dispositivo selecionado.
  const ControlPage({super.key, required this.device});
  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  /// Instância do FlutterReactiveBle para comunicação BLE.
  final ble = FlutterReactiveBle();

  /// Característica qualificada para comunicação com o dispositivo.
  late QualifiedCharacteristic characteristic;

  /// Indica se o dispositivo está conectado.
  bool connected = false;

  @override
  void initState() {
    super.initState();

    /// Configura a característica com os UUIDs do serviço e característica.
    characteristic = QualifiedCharacteristic(
      serviceId: Uuid.parse(serviceUuid),
      characteristicId: Uuid.parse(characteristicUuid),
      deviceId: widget.device.id,
    );

    /// Conecta ao dispositivo e monitora o estado da conexão.
    ble.connectToDevice(id: widget.device.id).listen((event) {
      if (event.connectionState == DeviceConnectionState.connected) {
        setState(() => connected = true); // Atualiza o estado para conectado.
      } else if (event.connectionState == DeviceConnectionState.disconnected) {
        setState(() => connected = false); // Atualiza o estado para desconectado.
        if (mounted) Navigator.pop(context); // Retorna à página anterior se desconectado.
      }
    });
  }

  /// Envia um comando para o dispositivo BLE.
  void sendCommand(String cmd) async {
    if (!connected) return; // Não envia comandos se não estiver conectado.
    await ble.writeCharacteristicWithResponse(
      characteristic,
      value: [cmd.codeUnitAt(0)], // Converte o comando para bytes.
    );
  }

  /// Cria um botão de controle com ícone, rótulo e comando associado.
  Widget controlButton(String iconLabel, IconData icon, String command) {
    return GestureDetector(
      onTapDown: (_) => sendCommand(command), // Envia o comando ao pressionar.
      onTapUp: (_) => sendCommand('s'), // Envia o comando de parada ao soltar.
      onTapCancel: () => sendCommand('s'), // Envia o comando de parada ao cancelar.
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.indigo, // Cor do botão.
          borderRadius: BorderRadius.circular(16), // Bordas arredondadas.
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white), // Ícone do botão.
            const SizedBox(height: 4), // Espaçamento entre ícone e texto.
            Text(iconLabel, style: const TextStyle(color: Colors.white)), // Rótulo do botão.
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Controle do Carro'), // Título da página.
        backgroundColor: connected ? Colors.indigo : Colors.grey, // Cor do AppBar baseada na conexão.
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Botão para mover o carro para frente.
            controlButton('Frente', Icons.arrow_upward, 'f'),
            const SizedBox(height: 20), // Espaçamento entre os botões.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Botão para mover o carro para a esquerda.
                controlButton('Esquerda', Icons.arrow_back, 'r'),
                const SizedBox(width: 40), // Espaçamento entre os botões.
                /// Botão para mover o carro para a direita.
                controlButton('Direita', Icons.arrow_forward, 'l'),
              ],
            ),
            const SizedBox(height: 20), // Espaçamento entre os botões.
            /// Botão para mover o carro para trás.
            controlButton('Ré', Icons.arrow_downward, 'b'),
          ],
        ),
      ),
    );
  }
}
