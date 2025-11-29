import 'package:flutter/material.dart';

import '../routes/routes.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: Center(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo y título
              Container(
                margin: EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    Icon(Icons.point_of_sale, size: 80, color: Color(0xFF07598C)),
                    SizedBox(height: 20),
                    Text(
                      "MOMO'S POS",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF585859),
                      ),
                    ),
                    Text(
                      "Sistema de Punto de Venta",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF568FA6),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Formulario de login
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(30),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Usuario",
                        prefixIcon: Icon(Icons.person, color: Color(0xFF03658C)),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF03658C)),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Contraseña",
                        prefixIcon: Icon(Icons.lock, color: Color(0xFF03658C)),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF03658C)),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF07598C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, Routes.dashboard);
                        },
                        child: Text(
                          "INICIAR SESIÓN",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
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