// lib/main.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const PiSensorApp());
}

class PiSensorApp extends StatefulWidget {
  const PiSensorApp({super.key});

  @override
  State<PiSensorApp> createState() => _PiSensorAppState();
}

class _PiSensorAppState extends State<PiSensorApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
    });
  }

  void toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    setState(() => _isDarkMode = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PiSensor BLE Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: WelcomePage(onThemeToggle: toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}

// ------------------- Welcome Page -------------------
class WelcomePage extends StatefulWidget {
  final Function(bool) onThemeToggle;
  final bool isDarkMode;

  const WelcomePage({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isDarkMode
                ? [const Color(0xFF1A237E), const Color(0xFF004D40)]
                : [Colors.tealAccent, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.sensors, size: 100, color: Colors.white),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'PiSensor Monitor',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Real-time Bluetooth monitoring',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 60),
                    ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                MainNavigator(
                              onThemeToggle: widget.onThemeToggle,
                              isDarkMode: widget.isDarkMode,
                            ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.teal,
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 10,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Get Started'),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------- Main Navigator with Bottom Nav -------------------
class MainNavigator extends StatefulWidget {
  final Function(bool) onThemeToggle;
  final bool isDarkMode;

  const MainNavigator({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const HistoryPage(),
      SettingsPage(
        onThemeToggle: widget.onThemeToggle,
        isDarkMode: widget.isDarkMode,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            HapticFeedback.selectionClick();
            setState(() => _currentIndex = index);
          },
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.monitor_heart_outlined),
              activeIcon: Icon(Icons.monitor_heart),
              label: 'Monitor',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------- Reading Data Model -------------------
class ReadingData {
  final String value;
  final DateTime timestamp;

  ReadingData(this.value, this.timestamp);

  Map<String, dynamic> toJson() => {
        'value': value,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ReadingData.fromJson(Map<String, dynamic> json) => ReadingData(
        json['value'],
        DateTime.parse(json['timestamp']),
      );
}

// ------------------- Home Page -------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _characteristic;
  String _latestReading = '---';
  bool _scanning = false;
  bool _connected = false;
  String _serverAddress = '';
  DateTime? _connectedSince;
  List<ReadingData> _readings = [];

  late AnimationController _pulseController;
  late AnimationController _readingController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _readingAnimation;

  @override
  void initState() {
    super.initState();
    _loadReadings();
    requestPermissions();
    _loadOrPromptServerAddress();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _readingController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _readingAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _readingController, curve: Curves.easeOut),
    );
  }

  Future<void> _loadReadings() async {
    final prefs = await SharedPreferences.getInstance();
    final readingsJson = prefs.getStringList('readings') ?? [];
    setState(() {
      _readings = readingsJson
          .map((e) => ReadingData.fromJson(jsonDecode(e)))
          .toList()
          .reversed
          .take(50)
          .toList();
    });
  }

  Future<void> _saveReading(ReadingData reading) async {
    _readings.insert(0, reading);
    if (_readings.length > 50) _readings = _readings.take(50).toList();

    final prefs = await SharedPreferences.getInstance();
    final readingsJson = _readings.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('readings', readingsJson);
  }

  Future<void> _loadOrPromptServerAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAddress = prefs.getString('server_address');

    if (savedAddress != null && savedAddress.isNotEmpty) {
      setState(() => _serverAddress = savedAddress);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showServerAddressDialog(initialAddress: savedAddress);
    });
  }

  Future<void> _showServerAddressDialog({String? initialAddress}) async {
    final controller = TextEditingController(text: initialAddress ?? '10.96.212.223:3000');

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.dns, color: Colors.teal),
            SizedBox(width: 10),
            Text('Server Configuration'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the server IP address and port:'),
            const SizedBox(height: 15),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'IP Address:Port',
                hintText: '10.96.212.223:3000',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                prefixIcon: const Icon(Icons.lan),
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid address'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              HapticFeedback.mediumImpact();
              _saveServerAddress(controller.text.trim());
              Navigator.of(context).pop();
            },
            child: const Text('Save', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveServerAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_address', address);
    setState(() => _serverAddress = address);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Server address saved: $address'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location
    ].request();

    if (statuses[Permission.bluetoothScan] != PermissionStatus.granted ||
        statuses[Permission.bluetoothConnect] != PermissionStatus.granted) {
      debugPrint('BLE permissions not granted!');
    }
  }

  void startScan() async {
    HapticFeedback.mediumImpact();
    await requestPermissions();

    setState(() => _scanning = true);
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 6));

    FlutterBluePlus.scanResults.listen((results) {
      for (var r in results) {
        final dev = r.device;
        final name = dev.platformName;

        if (name == 'PiSensor') {
          FlutterBluePlus.stopScan();
          _connectToDevice(dev);
          break;
        }
      }
    });

    Future.delayed(const Duration(seconds: 7), () {
      if (_scanning) {
        FlutterBluePlus.stopScan();
        setState(() => _scanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No device found. Please try again.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    });
  }

  Future<void> _connectToDevice(BluetoothDevice dev) async {
    setState(() {
      _device = dev;
      _scanning = false;
    });

    try {
      await dev.connect(autoConnect: false, license: License.free);
      setState(() {
        _connected = true;
        _connectedSince = DateTime.now();
      });

      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Device connected successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      final services = await dev.discoverServices();
      for (var s in services) {
        if (s.uuid.toString().toLowerCase() == '12345678-1234-5678-1234-56789abcdef0') {
          for (var c in s.characteristics) {
            if (c.uuid.toString().toLowerCase() == '87654321-4321-6789-4321-fedcba987654') {
              _characteristic = c;

              try {
                final initial = await c.read();
                if (initial.isNotEmpty) _updateReading(initial);
              } catch (_) {}

              await c.setNotifyValue(true);
              c.lastValueStream.listen((value) {
                if (value.isNotEmpty) _updateReading(value);
              });

              return;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Connect error: $e');
      _disconnect();
    }
  }

  void _updateReading(List<int> bytes) {
    final text = utf8.decode(bytes);
    setState(() => _latestReading = text);

    _readingController.forward().then((_) => _readingController.reverse());

    final reading = ReadingData(text, DateTime.now());
    _saveReading(reading);
    _sendToBackend(text);
  }

  Future<void> _sendToBackend(String reading) async {
    if (_serverAddress.isEmpty) {
      debugPrint('Server address not configured');
      return;
    }

    try {
      final payload = {
        'device': 'pi4b',
        'reading': reading,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final resp = await http.post(
        Uri.parse('http://$_serverAddress/readings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      debugPrint('Backend status: ${resp.statusCode}');
    } catch (e) {
      debugPrint('Send error: $e');
    }
  }

  Future<void> _disconnect() async {
    try {
      if (_characteristic != null) await _characteristic!.setNotifyValue(false);
      if (_device != null) await _device!.disconnect();
    } catch (_) {}

    HapticFeedback.mediumImpact();
    setState(() {
      _device = null;
      _characteristic = null;
      _connected = false;
      _connectedSince = null;
      _latestReading = '---';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Device disconnected'),
        backgroundColor: Colors.grey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _getConnectionDuration() {
    if (_connectedSince == null) return 'Not connected';
    final duration = DateTime.now().difference(_connectedSince!);
    if (duration.inHours > 0) return '${duration.inHours}h ${duration.inMinutes % 60}m ago';
    if (duration.inMinutes > 0) return '${duration.inMinutes}m ago';
    return '${duration.inSeconds}s ago';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final devName = _device?.platformName ?? 'Not connected';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          if (!_connected && !_scanning) {
            startScan();
            await Future.delayed(const Duration(seconds: 1));
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1A237E), const Color(0xFF004D40)]
                  : [Colors.teal.shade50, Colors.blue.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // Status Card with Glassmorphism
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.05),
                                ]
                              : [
                                  Colors.white.withOpacity(0.7),
                                  Colors.white.withOpacity(0.5),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Device',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        devName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ScaleTransition(
                                  scale: _connected ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: _connected
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.grey.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _connected
                                          ? Icons.bluetooth_connected
                                          : Icons.bluetooth_disabled,
                                      size: 40,
                                      color: _connected ? Colors.green : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _connected ? Colors.green : Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _connected ? 'Connected' : 'Disconnected',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _connected ? Colors.green : Colors.red,
                                  ),
                                ),
                                if (_connected) ...[
                                  const Spacer(),
                                  Text(
                                    _getConnectionDuration(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Main Reading Display
                    ScaleTransition(
                      scale: _readingAnimation,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                            colors: isDark
                                ? [Colors.teal.shade900, Colors.teal.shade700]
                                : [Colors.teal.shade400, Colors.teal.shade300],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
                          child: Column(
                            children: [
                              const Text(
                                'Latest Reading',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _latestReading,
                                style: const TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Mini Chart
                    if (_readings.isNotEmpty)
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    Colors.white.withOpacity(0.1),
                                    Colors.white.withOpacity(0.05),
                                  ]
                                : [
                                    Colors.white.withOpacity(0.7),
                                    Colors.white.withOpacity(0.5),
                                  ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: false),
                              titlesData: FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _readings
                                      .take(20)
                                      .toList()
                                      .reversed
                                      .toList()
                                      .asMap()
                                      .entries
                                      .map((e) {
                                    final val = double.tryParse(e.value.value) ?? 0;
                                    return FlSpot(e.key.toDouble(), val);
                                  }).toList(),
                                  isCurved: true,
                                  color: Colors.teal,
                                  barWidth: 3,
                                  dotData: FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.teal.withOpacity(0.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 30),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _scanning ? null : startScan,
                            icon: _scanning
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.search),
                            label: Text(_scanning ? 'Scanning...' : 'Scan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _connected ? _disconnect : null,
                            icon: const Icon(Icons.power_settings_new),
                            label: const Text('Disconnect'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        _showServerAddressDialog(initialAddress: _serverAddress);
                      },
                      icon: const Icon(Icons.settings),
                      label: const Text('Change Server Address'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _disconnect();
    _pulseController.dispose();
    _readingController.dispose();
    super.dispose();
  }
}

// ------------------- History Page -------------------
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<ReadingData> _readings = [];

  @override
  void initState() {
    super.initState();
    _loadReadings();
  }

  Future<void> _loadReadings() async {
    final prefs = await SharedPreferences.getInstance();
    final readingsJson = prefs.getStringList('readings') ?? [];
    setState(() {
      _readings = readingsJson.map((e) => ReadingData.fromJson(jsonDecode(e))).toList();
    });
  }

  Future<void> _exportData() async {
    try {
      HapticFeedback.mediumImpact();
      final csv = 'Timestamp,Reading\n' +
          _readings.map((r) => '${r.timestamp.toIso8601String()},${r.value}').join('\n');

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/readings_export.csv');
      await file.writeAsString(csv);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported to: ${file.path}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _clearHistory() async {
    HapticFeedback.heavyImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('readings');
    setState(() => _readings = []);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('History cleared'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1A237E), const Color(0xFF004D40)]
                : [Colors.teal.shade50, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    const Text(
                      'Reading History',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _readings.isEmpty ? null : _exportData,
                      icon: const Icon(Icons.download),
                      tooltip: 'Export CSV',
                    ),
                    IconButton(
                      onPressed: _readings.isEmpty ? null : _clearHistory,
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Clear History',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _readings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 20),
                            Text(
                              'No readings yet',
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadReadings,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _readings.length,
                          itemBuilder: (context, index) {
                            final reading = _readings[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [
                                          Colors.white.withOpacity(0.1),
                                          Colors.white.withOpacity(0.05),
                                        ]
                                      : [
                                          Colors.white.withOpacity(0.7),
                                          Colors.white.withOpacity(0.5),
                                        ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(15),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.sensors, color: Colors.teal),
                                ),
                                title: Text(
                                  reading.value,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${reading.timestamp.hour.toString().padLeft(2, '0')}:${reading.timestamp.minute.toString().padLeft(2, '0')}:${reading.timestamp.second.toString().padLeft(2, '0')}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                trailing: Text(
                                  '${reading.timestamp.day}/${reading.timestamp.month}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------- Settings Page -------------------
class SettingsPage extends StatelessWidget {
  final Function(bool) onThemeToggle;
  final bool isDarkMode;

  const SettingsPage({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1A237E), const Color(0xFF004D40)]
                : [Colors.teal.shade50, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Settings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                          ]
                        : [
                            Colors.white.withOpacity(0.7),
                            Colors.white.withOpacity(0.5),
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Dark Mode'),
                      subtitle: const Text('Enable dark theme'),
                      value: isDarkMode,
                      onChanged: (value) {
                        HapticFeedback.selectionClick();
                        onThemeToggle(value);
                      },
                      secondary: Icon(
                        isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: Colors.teal,
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: Colors.teal),
                      title: const Text('About'),
                      subtitle: const Text('PiSensor Monitor v1.0'),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        showAboutDialog(
                          context: context,
                          applicationName: 'PiSensor Monitor',
                          applicationVersion: '1.0.0',
                          applicationIcon: const Icon(Icons.sensors, size: 50, color: Colors.teal),
                          children: [
                            const Text('A modern Bluetooth sensor monitoring application.'),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}