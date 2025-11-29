import 'package:flutter/material.dart';

class CajaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      appBar: AppBar(
        title: Text("Movimientos de Caja"),
        backgroundColor: Color(0xFF07598C),
        actions: [
          IconButton(icon: Icon(Icons.add_chart), onPressed: () {}),
          IconButton(icon: Icon(Icons.print), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Resumen de caja
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCajaStat("Inicial", "\$2,000.00", Color(0xFF568FA6)),
                _buildCajaStat("Ventas", "\$8,450.00", Color(0xFF03658C)),
                _buildCajaStat("Efectivo", "\$6,230.00", Color(0xFF07598C)),
                _buildCajaStat("Diferencia", "\$0.00", Color(0xFF585859)),
              ],
            ),
          ),
          
          // Filtros
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.calendar_today),
                    label: Text("Hoy"),
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF03658C),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.filter_list),
                    label: Text("Filtrar"),
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFF07598C),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de movimientos
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildMovimiento("Venta VTA-001", "10:30 AM", "\$350.00", "entrada", Icons.shopping_cart),
                _buildMovimiento("Pago Proveedor", "11:15 AM", "-\$1,200.00", "salida", Icons.local_shipping),
                _buildMovimiento("Venta VTA-002", "12:45 PM", "\$680.00", "entrada", Icons.shopping_cart),
                _buildMovimiento("Retiro Efectivo", "02:30 PM", "-\$500.00", "salida", Icons.account_balance_wallet),
                _buildMovimiento("Venta VTA-003", "04:20 PM", "\$1,250.00", "entrada", Icons.shopping_cart),
              ],
            ),
          ),
          
          // Botón de corte
          Container(
            padding: EdgeInsets.all(16),
            child: ElevatedButton.icon(
              icon: Icon(Icons.account_balance_wallet),
              label: Text("REALIZAR CORTE DE CAJA"),
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF07598C),
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCajaStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Color(0xFF585859))),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
  
  Widget _buildMovimiento(String concepto, String hora, String monto, String tipo, IconData icon) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: tipo == "entrada" 
                ? Color(0xFF03658C).withOpacity(0.2)
                : Color(0xFF585859).withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: tipo == "entrada" ? Color(0xFF03658C) : Color(0xFF585859),
          ),
        ),
        title: Text(concepto, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(hora, style: TextStyle(color: Color(0xFF568FA6))),
        trailing: Text(
          monto,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: tipo == "entrada" ? Color(0xFF03658C) : Color(0xFF585859),
          ),
        ),
      ),
    );
  }
}