import 'package:flutter/material.dart';
import '../routes/routes.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header del Drawer
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF07598C), Color(0xFF03658C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 25,
                  child: Icon(Icons.point_of_sale, color: Color(0xFF07598C), size: 30),
                ),
                SizedBox(height: 15),
                Text(
                  "MOMO'S POS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Sistema de Punto de Venta",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Sección Principal
          _buildSectionTitle("OPERACIONES"),
          _buildDrawerItem(
            context,
            Icons.dashboard,
            "Inicio",
            Routes.dashboard,
          ),
          _buildDrawerItem(
            context,
            Icons.shopping_cart,
            "Nueva Venta",
            Routes.ventas,
          ),
          _buildDrawerItem(
            context,
            Icons.account_balance_wallet,
            "Movimientos Caja",
            Routes.caja,
          ),
          
          // Sección Catálogos
          _buildSectionTitle("CATÁLOGOS"),
          _buildDrawerItem(
            context,
            Icons.inventory_2,
            "Productos",
            Routes.productos,
          ),
          _buildDrawerItem(
            context,
            Icons.people,
            "Clientes",
            Routes.clientes,
          ),
          _buildDrawerItem(
            context,
            Icons.local_shipping,
            "Proveedores",
            Routes.proveedores,
          ),
          
          // Sección Reportes
          _buildSectionTitle("REPORTES"),
          _buildDrawerItem(
            context,
            Icons.analytics,
            "Reportes de Ventas",
            Routes.reportes,
          ),
          _buildDrawerItem(
            context,
            Icons.shopping_basket,
            "Compras",
            Routes.compras,
          ),
          
          Divider(color: Color(0xFF568FA6)),
          
          // Configuración
          _buildDrawerItem(
            context,
            Icons.settings,
            "Configuración",
            Routes.configuracion,
          ),
          
          // Cerrar Sesión
          Container(
            margin: EdgeInsets.all(16),
            child: ElevatedButton.icon(
              icon: Icon(Icons.exit_to_app, size: 18),
              label: Text("CERRAR SESIÓN"),
              onPressed: () => _showLogoutDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF585859),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Color(0xFF03658C),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
  
  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Color(0xFF568FA6).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Color(0xFF03658C), size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Color(0xFF585859),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Color(0xFF568FA6), size: 18),
      onTap: () {
        Navigator.pop(context); // Cerrar el drawer
        
        // Si ya estamos en la pantalla, no navegar
        if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
  
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.exit_to_app, color: Color(0xFF07598C)),
              SizedBox(width: 10),
              Text("Cerrar Sesión"),
            ],
          ),
          content: Text("¿Estás seguro de que quieres cerrar sesión?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: TextStyle(color: Color(0xFF585859))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF07598C)),
              onPressed: () {
                Navigator.pop(context); // Cerrar dialog
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  Routes.login, 
                  (route) => false
                );
              },
              child: Text("Cerrar Sesión", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}