import 'package:flutter/material.dart';

class ProductosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      appBar: AppBar(
        title: Text("Gestión de Productos"),
        backgroundColor: Color(0xFF07598C),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: () {}),
          IconButton(icon: Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Buscar productos...",
                prefixIcon: Icon(Icons.search, color: Color(0xFF03658C)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          
          // Filtros por categoría
          Container(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryFilter("Todos", true),
                _buildCategoryFilter("Abarrotes", false),
                _buildCategoryFilter("Bebidas", false),
                _buildCategoryFilter("Lácteos", false),
                _buildCategoryFilter("Limpieza", false),
              ],
            ),
          ),
          
          // Lista de productos
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildProductCard("Aceite Vegetal 1L", "Abarrotes", "\$35.00", "45 en stock", Icons.shopping_basket),
                _buildProductCard("Coca-Cola 600ml", "Bebidas", "\$18.00", "120 en stock", Icons.local_drink),
                _buildProductCard("Leche Entera 1L", "Lácteos", "\$22.00", "32 en stock", Icons.local_cafe),
                _buildProductCard("Jabón Líquido", "Limpieza", "\$45.00", "18 en stock", Icons.clean_hands),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryFilter(String category, bool active) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: active ? Color(0xFF07598C) : Colors.white,
          foregroundColor: active ? Colors.white : Color(0xFF585859),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {},
        child: Text(category),
      ),
    );
  }
  
  Widget _buildProductCard(String name, String category, String price, String stock, IconData icon) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Color(0xFF568FA6).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Color(0xFF568FA6)),
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category, style: TextStyle(color: Color(0xFF03658C))),
            SizedBox(height: 4),
            Text(stock, style: TextStyle(color: Color(0xFF585859), fontSize: 12)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(price, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF07598C))),
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, size: 18, color: Color(0xFF03658C)),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.delete, size: 18, color: Color(0xFF585859)),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}