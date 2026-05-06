import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddEstacionScreen extends StatefulWidget {
  const AddEstacionScreen({super.key}); // Soluciona aviso de Key

  @override
  State<AddEstacionScreen> createState() => _AddEstacionScreenState();
}

class _AddEstacionScreenState extends State<AddEstacionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _ubicacionController = TextEditingController();

  void _guardar() async {
    if (_formKey.currentState!.validate()) {
      bool success = await ApiService().crearEstacion(
        _nombreController.text,
        _ubicacionController.text
      );

      // SOLUCIÓN AZUL: Verificar si el widget sigue presente tras el await
      if (!mounted) return;

      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No autorizado o Servidor caído')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Estación')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _ubicacionController,
                decoration: const InputDecoration(labelText: 'Ubicación'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardar, 
                child: const Text('Guardar Estación')
              )
            ],
          ),
        ),
      ),
    );
  }
}