import 'package:flutter/material.dart';

class VentasScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      appBar: AppBar(
        title: Text("Nueva Venta"),
        backgroundColor: Color(0xFF07598C),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Header de venta
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Cliente: Público General", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Folio: VTA-20231201-0001", style: TextStyle(color: Color(0xFF568FA6))),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text("Total", style: TextStyle(fontSize: 12)),
                    Text("\$0.00", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF07598C))),
                  ],
                ),
              ],
            ),
          ),
          
          // Lista de productos
          Expanded(
            child: ListView(
              children: [
                _buildProductItem("Aceite Vegetal 1L", "1 x \$35.00", "\$35.00"),
                _buildProductItem("Arroz 1kg", "2 x \$25.00", "\$50.00"),
                _buildProductItem("Leche 1L", "1 x \$22.00", "\$22.00"),
              ],
            ),
          ),
          
          // Botones de acción
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text("Agregar Producto"),
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFF07598C),
                      side: BorderSide(color: Color(0xFF07598C)),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.payment),
                    label: Text("Cobrar"),
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF03658C),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProductItem(String name, String details, String price) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 2),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(0xFF568FA6).withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(Icons.shopping_basket, color: Color(0xFF568FA6)),
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(details, style: TextStyle(color: Color(0xFF585859))),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(price, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF07598C))),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Color(0xFF03658C),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.remove, size: 12, color: Colors.white),
                  SizedBox(width: 8),
                  Text("1", style: TextStyle(color: Colors.white, fontSize: 12)),
                  SizedBox(width: 8),
                  Icon(Icons.add, size: 12, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}