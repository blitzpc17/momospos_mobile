import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../routes/routes.dart'; // ✅ Importar routes

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      appBar: AppBar(
        title: Text("MOMO'S POS - Dashboard"),
        backgroundColor: Color(0xFF07598C),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {},
            tooltip: "Actualizar",
          ),
          IconButton(
            icon: Icon(Icons.notifications_none),
            onPressed: () {},
            tooltip: "Notificaciones",
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Tarjeta de Resumen del Día
            _buildDaySummaryCard(),
            SizedBox(height: 20),
            
            // Métricas Rápidas
            Row(
              children: [
                Expanded(child: _buildMetricCard("Ventas Hoy", "\$8,450", Icons.trending_up, Color(0xFF03658C))),
                SizedBox(width: 12),
                Expanded(child: _buildMetricCard("Productos Vendidos", "156", Icons.shopping_basket, Color(0xFF568FA6))),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildMetricCard("Clientes Atendidos", "45", Icons.people, Color(0xFF07598C))),
                SizedBox(width: 12),
                Expanded(child: _buildMetricCard("Ticket Promedio", "\$187.78", Icons.receipt, Color(0xFF585859))),
              ],
            ),
            
            SizedBox(height: 20),
            
            // Estado de Caja
            _buildCajaStatusCard(context),
            
            SizedBox(height: 20),
            
            // Ventas por Categoría
            _buildSalesByCategoryCard(),
            
            SizedBox(height: 20),
            
            // Productos Más Vendidos
            _buildTopProductsCard(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.ventas); // ✅ Usar constante
        },
        backgroundColor: Color(0xFF03658C),
        child: Icon(Icons.add_shopping_cart, color: Colors.white),
        tooltip: "Nueva Venta",
      ),
    );
  }
  
  Widget _buildDaySummaryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Resumen del Día",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF585859),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF07598C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Hoy",
                    style: TextStyle(
                      color: Color(0xFF07598C),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem("Ventas Totales", "\$12,450", Color(0xFF03658C)),
                _buildSummaryItem("Efectivo", "\$8,230", Color(0xFF568FA6)),
                _buildSummaryItem("Tarjeta", "\$4,220", Color(0xFF585859)),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF585859),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Icon(Icons.more_vert, color: Color(0xFF568FA6), size: 18),
              ],
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF585859),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCajaStatusCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Estado de Caja",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF585859),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, color: Colors.green, size: 8),
                      SizedBox(width: 6),
                      Text(
                        "Abierta",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCajaItem("Fondo Inicial", "\$2,000.00"),
                _buildCajaItem("Ventas Efectivo", "\$8,230.00"),
                _buildCajaItem("Saldo Actual", "\$10,230.00"),
              ],
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.account_balance_wallet, size: 18),
                label: Text("VER MOVIMIENTOS DE CAJA"),
                onPressed: () {
                  Navigator.pushNamed(context, Routes.caja); // ✅ Usar constante
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF07598C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCajaItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF03658C),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Color(0xFF585859),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildSalesByCategoryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ventas por Categoría",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF585859),
              ),
            ),
            SizedBox(height: 16),
            _buildCategoryItem("Abarrotes", 42, "\$4,250", Color(0xFF07598C)),
            _buildCategoryItem("Bebidas", 35, "\$3,120", Color(0xFF03658C)),
            _buildCategoryItem("Lácteos", 18, "\$1,850", Color(0xFF568FA6)),
            _buildCategoryItem("Limpieza", 12, "\$980", Color(0xFF585859)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategoryItem(String category, int percent, String amount, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                category,
                style: TextStyle(
                  color: Color(0xFF585859),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: LinearProgressIndicator(
                value: percent / 100,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                amount,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
      ],
    );
  }
  
  Widget _buildTopProductsCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Productos Más Vendidos",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF585859),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward, color: Color(0xFF03658C)),
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.productos); // ✅ Usar constante
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildProductRankItem("Aceite Vegetal 1L", "45 unidades", 1),
            _buildProductRankItem("Coca-Cola 600ml", "38 unidades", 2),
            _buildProductRankItem("Leche Entera 1L", "32 unidades", 3),
            _buildProductRankItem("Arroz 1kg", "28 unidades", 4),
            _buildProductRankItem("Jabón Líquido", "25 unidades", 5),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProductRankItem(String product, String sales, int rank) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Color(0xFF07598C),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF585859),
                  ),
                ),
                Text(
                  sales,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF568FA6),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Color(0xFF03658C)),
        ],
      ),
    );
  }
}