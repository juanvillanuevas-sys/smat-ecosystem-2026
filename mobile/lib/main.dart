import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'models/estacion.dart';
import 'screens/add_estacion.dart';

void main() async {
  // 1. Lógica de Inicio: Verificar token antes de arrancar
  WidgetsFlutterBinding.ensureInitialized();
  final String? token = await AuthService().getToken();
  
  // 2. Redirección Automática: Pasamos el estado de sesión
  runApp(SMATApp(isLoggedIn: token != null));
}

class SMATApp extends StatelessWidget {
  final bool isLoggedIn;
  // Agregamos isLoggedIn al constructor para que main lo pueda usar
  const SMATApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SMAT UNMSM',
      // Si hay token va al Home, si no, se queda en una pantalla de espera/login
      home: isLoggedIn 
          ? const HomePage() 
          : const Scaffold(body: Center(child: Text("Pantalla de Login"))),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Estacion>> futureEstaciones;
  
  @override
  void initState() {
    super.initState();
    futureEstaciones = ApiService().fetchEstaciones();
  }

  void _refresh() {
    setState(() {
      futureEstaciones = ApiService().fetchEstaciones();
    });
  }

  // 3. Botón de Logout (Punto 3 del reto)
  void _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    // Volvemos a arrancar la app en estado "no logueado"
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SMATApp(isLoggedIn: false)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMAT - Monitoreo Móvil'),
        actions: [
          // Botón de cerrar sesión en la barra
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<List<Estacion>>(
        future: futureEstaciones,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('❌ Error de conexión'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final est = snapshot.data![index];
                return ListTile(
                  leading: const Icon(Icons.satellite_alt),
                  title: Text(est.nombre),
                  subtitle: Text(est.ubicacion),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navega a la pantalla de agregar y espera el resultado
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEstacionScreen()),
          );
          // Si se agregó con éxito, refresca la lista
          if (result == true) _refresh();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}