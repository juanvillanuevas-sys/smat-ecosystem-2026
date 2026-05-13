import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddEstacionScreen extends StatefulWidget {
  @override
  _AddEstacionScreenState createState() => _AddEstacionScreenState();
}

class _AddEstacionScreenState extends State<AddEstacionScreen> {
  // Controladores para capturar el texto de los inputs
  final _nombreController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Para validación de formulario

  void _guardarEstacion() async {
    if (_formKey.currentState!.validate()) {
      // Llamamos a la función de escritura que creamos en el ApiService
      bool exito = await ApiService().crearEstacion(
        _nombreController.text,
        _ubicacionController.text,
      );

      if (exito) {
        // Si se guardó correctamente, volvemos a la pantalla anterior
        Navigator.pop(context, true); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estación registrada con éxito')),
        );
      } else {
        // Si falla (ej. token inválido o error de red)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar la estación')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nueva Estación SMAT')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre de la Estación'),
                validator: (value) => value!.isEmpty ? 'Ingrese un nombre' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _ubicacionController,
                decoration: InputDecoration(labelText: 'Ubicación / Coordenadas'),
                validator: (value) => value!.isEmpty ? 'Ingrese la ubicación' : null,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _guardarEstacion,
                child: Text('Registrar Estación'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}