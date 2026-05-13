import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_page.dart'; // Tu pantalla de lista de estaciones
import 'services/auth_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMAT Monitoreo',
      debugShowCheckedModeBanner: false,
      // Usamos FutureBuilder para decidir la pantalla de inicio
      home: FutureBuilder<String?>(
        future: AuthService().getToken(), // Lógica de Inicio: busca el token
        builder: (context, snapshot) {
          // Mientras verifica, muestra un círculo de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          
          // Redirección Automática: Si hay token va al Home, si no al Login
          if (snapshot.hasData && snapshot.data != null) {
            return HomePage(); 
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}