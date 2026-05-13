import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/estacion.dart';
import 'login_screen.dart';
import 'add_estacion.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();
  List<Estacion> estaciones = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarEstaciones();
  }

  Future<void> _cargarEstaciones() async {
    setState(() => _isLoading = true);
    try {
      final lista = await apiService.fetchEstaciones();
      setState(() => estaciones = lista);
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _mostrarDialogoEdicion(Estacion estacion) {
    final nombreCtrl = TextEditingController(text: estacion.nombre);
    final ubicacionCtrl = TextEditingController(text: estacion.ubicacion);
    bool _isUpdating = false; // Para el reto de indicador visual

    showDialog(
      context: context,
      barrierDismissible: false, // Evita cerrar mientras guarda
      builder: (context) => StatefulBuilder( // Permite actualizar el diálogo
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Editar Estación"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: "Nombre")),
              TextField(controller: ubicacionCtrl, decoration: const InputDecoration(labelText: "Ubicación")),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _isUpdating ? null : () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: _isUpdating ? null : () async {
                setDialogState(() => _isUpdating = true);
                bool ok = await apiService.editarEstacion(estacion.id, nombreCtrl.text, ubicacionCtrl.text);
                if (ok) {
                  await _cargarEstaciones();
                  if (context.mounted) Navigator.pop(context);
                } else {
                  setDialogState(() => _isUpdating = false);
                }
              },
              child: _isUpdating 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estaciones SMAT'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarEstaciones,
        child: _isLoading && estaciones.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: estaciones.length,
                itemBuilder: (context, index) {
                  final estacion = estaciones[index];
                  final double valorSimulado = (estacion.id % 2 == 0) ? 60.0 : 30.0;
                  final Color colorAlerta = valorSimulado > 50 ? Colors.red : Colors.green;

                  return Dismissible(
                    key: Key(estacion.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) async {
                      bool ok = await apiService.eliminarEstacion(estacion.id);
                      if (ok) {
                        setState(() => estaciones.removeAt(index));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${estacion.nombre} eliminada")),
                        );
                      }
                    },
                    child: ListTile(
                      leading: Icon(Icons.sensors, color: colorAlerta),
                      title: Text(estacion.nombre),
                      subtitle: Text(estacion.ubicacion),
                      onTap: () => _mostrarDialogoEdicion(estacion),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEstacionScreen()),
          );
          if (result == true) _cargarEstaciones();
        },
      ),
    );
  }
}