import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../routes/routes.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isTablet = screenWidth > 600;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Center(child: Text("MOMO'S POS", style: TextStyle(color: Color(0xFFE3F2FD)),)),
        backgroundColor: theme.primaryColor,
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(_getScreenPadding(screenWidth)),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                children: [
                  // Tarjeta de Resumen del Día
                  _buildDaySummaryCard(context, screenWidth),
                  SizedBox(height: _getSpacing(screenWidth)),
                  
                  // Métricas Rápidas - Layout responsive
                  _buildMetricsSection(context, screenWidth, isTablet),
                  SizedBox(height: _getSpacing(screenWidth)),
                  
                  // Estado de Caja
                  _buildCajaStatusCard(context, screenWidth),
                  
                  SizedBox(height: _getSpacing(screenWidth)),
                  
                  // Ventas por Categoría
                  _buildSalesByCategoryCard(context, screenWidth),
                  
                  SizedBox(height: _getSpacing(screenWidth)),
                  
                  // Productos Más Vendidos
                  _buildTopProductsCard(context, screenWidth),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.ventas);
        },
        backgroundColor: theme.colorScheme.primary,
        child: Icon(Icons.add_shopping_cart, color: Colors.white),
        tooltip: "Nueva Venta",
      ),
    );
  }
  
  Widget _buildMetricsSection(BuildContext context, double screenWidth, bool isTablet) {
  final theme = Theme.of(context);
  
  if (isTablet) {
    // Layout para tablet - 2x2 grid con altura intrínseca
    return Column(
      children: [
        // Fila 1
        IntrinsicHeight( // ← Hace que ambas tarjetas tengan la misma altura
          child: Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context, "Ventas Hoy", "\$8,450", 
                  Icons.trending_up, theme.colorScheme.primary, screenWidth, isTablet
                ),
              ),
              SizedBox(width: _getSpacing(screenWidth)),
              Expanded(
                child: _buildMetricCard(
                  context, "Productos Vendidos", "156", 
                  Icons.shopping_basket, theme.colorScheme.secondary!, screenWidth, isTablet
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: _getSpacing(screenWidth)),
        // Fila 2
        IntrinsicHeight( // ← Hace que ambas tarjetas tengan la misma altura
          child: Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context, "Clientes Atendidos", "45", 
                  Icons.people, theme.primaryColor, screenWidth, isTablet
                ),
              ),
              SizedBox(width: _getSpacing(screenWidth)),
              Expanded(
                child: _buildMetricCard(
                  context, "Ticket Promedio", "\$187.78", 
                  Icons.receipt, Color(0xFF585859), screenWidth, isTablet
                ),
              ),
            ],
          ),
        ),
      ],
    );
  } else {
    // Layout para móvil - scroll horizontal con altura fija
    return SizedBox(
      height: _getMetricCardHeight(screenWidth),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Container(
            width: _getMetricCardWidth(screenWidth, isTablet), // ← Ancho fijo
            child: _buildMetricCard(
              context, "Ventas Hoy", "\$8,450", 
              Icons.trending_up, theme.colorScheme.primary, screenWidth, isTablet
            ),
          ),
          SizedBox(width: _getSpacing(screenWidth)),
          Container(
            width: _getMetricCardWidth(screenWidth, isTablet), // ← Ancho fijo
            child: _buildMetricCard(
              context, "Productos Vendidos", "156", 
              Icons.shopping_basket, theme.colorScheme.secondary!, screenWidth, isTablet
            ),
          ),
          SizedBox(width: _getSpacing(screenWidth)),
          Container(
            width: _getMetricCardWidth(screenWidth, isTablet), // ← Ancho fijo
            child: _buildMetricCard(
              context, "Clientes Atendidos", "45", 
              Icons.people, theme.primaryColor, screenWidth, isTablet
            ),
          ),
          SizedBox(width: _getSpacing(screenWidth)),
          Container(
            width: _getMetricCardWidth(screenWidth, isTablet), // ← Ancho fijo
            child: _buildMetricCard(
              context, "Ticket Promedio", "\$187.78", 
              Icons.receipt, Color(0xFF585859), screenWidth, isTablet
            ),
          ),
        ],
      ),
    );
  }
}
  Widget _buildDaySummaryCard(BuildContext context, double screenWidth) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(_getCardPadding(screenWidth)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Resumen del Día",
                  style: TextStyle(
                    fontSize: _getTitleFontSize(screenWidth),
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF585859),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Hoy",
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: _getSmallFontSize(screenWidth),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: _getInnerSpacing(screenWidth)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem("Ventas Totales", "\$12,450", theme.colorScheme.primary, screenWidth),
                _buildSummaryItem("Efectivo", "\$8,230", theme.colorScheme.secondary!, screenWidth),
                _buildSummaryItem("Tarjeta", "\$4,220", Color(0xFF585859), screenWidth),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryItem(String label, String value, Color color, double screenWidth) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: _getValueFontSize(screenWidth),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: _getLabelFontSize(screenWidth),
            color: Color(0xFF585859),
          ),
        ),
      ],
    );
  }
  
  

  Widget _buildMetricCard(BuildContext context, String title, String value, 
                        IconData icon, Color color, double screenWidth, bool isTablet) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(12), // ← Padding fijo más pequeño
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min, // ← CLAVE: evita overflow
          children: [
            // Fila de iconos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(6), // ← Padding reducido
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 16), // ← Tamaño fijo pequeño
                ),
                Icon(Icons.more_vert, color: theme.colorScheme.secondary, size: 16),
              ],
            ),
            
            // Espacio flexible
            SizedBox(height: 8),
            
            // Valor
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16, // ← Tamaño fijo
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            
            SizedBox(height: 4),
            
            // Título con altura controlada
            Text(
              title,
              style: TextStyle(
                fontSize: 12, // ← Tamaño fijo más pequeño
                color: Color(0xFF585859),
                height: 1.1, // ← Menor interlineado
              ),
              maxLines: 2, // ← REDUCIDO a 2 líneas para evitar overflow
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCajaStatusCard(BuildContext context, double screenWidth) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(_getCardPadding(screenWidth)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Estado de Caja",
                  style: TextStyle(
                    fontSize: _getTitleFontSize(screenWidth),
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
                          fontSize: _getSmallFontSize(screenWidth),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: _getInnerSpacing(screenWidth)),
            _buildCajaItems(context, screenWidth),
            SizedBox(height: _getInnerSpacing(screenWidth)),
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.account_balance_wallet, size: _getSmallIconSize(screenWidth)),
                label: Text(
                  "VER MOVIMIENTOS DE CAJA",
                  style: TextStyle(fontSize: _getButtonFontSize(screenWidth)),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, Routes.caja);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: _getButtonPadding(screenWidth)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCajaItems(BuildContext context, double screenWidth) {
    final theme = Theme.of(context);
    
    if (screenWidth > 400) {
      // Layout horizontal para pantallas más grandes
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCajaItem("Fondo Inicial", "\$2,000.00", screenWidth, theme),
          _buildCajaItem("Ventas Efectivo", "\$8,230.00", screenWidth, theme),
          _buildCajaItem("Saldo Actual", "\$10,230.00", screenWidth, theme),
        ],
      );
    } else {
      // Layout vertical para pantallas pequeñas
      return Column(
        children: [
          _buildCajaItem("Fondo Inicial", "\$2,000.00", screenWidth, theme),
          SizedBox(height: 8),
          _buildCajaItem("Ventas Efectivo", "\$8,230.00", screenWidth, theme),
          SizedBox(height: 8),
          _buildCajaItem("Saldo Actual", "\$10,230.00", screenWidth, theme),
        ],
      );
    }
  }
  
  Widget _buildCajaItem(String label, String value, double screenWidth, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: _getValueFontSize(screenWidth),
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: _getSmallFontSize(screenWidth),
            color: Color(0xFF585859),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildSalesByCategoryCard(BuildContext context, double screenWidth) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(_getCardPadding(screenWidth)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ventas por Categoría",
              style: TextStyle(
                fontSize: _getTitleFontSize(screenWidth),
                fontWeight: FontWeight.bold,
                color: Color(0xFF585859),
              ),
            ),
            SizedBox(height: _getInnerSpacing(screenWidth)),
            _buildCategoryItem("Abarrotes", 42, "\$4,250", theme.primaryColor, screenWidth),
            _buildCategoryItem("Bebidas", 35, "\$3,120", theme.colorScheme.primary, screenWidth),
            _buildCategoryItem("Lácteos", 18, "\$1,850", theme.colorScheme.secondary!, screenWidth),
            _buildCategoryItem("Limpieza", 12, "\$980", Color(0xFF585859), screenWidth),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategoryItem(String category, int percent, String amount, Color color, double screenWidth) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: screenWidth > 400 ? 2 : 3,
              child: Text(
                category,
                style: TextStyle(
                  color: Color(0xFF585859),
                  fontWeight: FontWeight.w500,
                  fontSize: _getLabelFontSize(screenWidth),
                ),
              ),
            ),
            Expanded(
              flex: screenWidth > 400 ? 3 : 4,
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
                  fontSize: _getSmallFontSize(screenWidth),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
      ],
    );
  }
  
  Widget _buildTopProductsCard(BuildContext context, double screenWidth) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(_getCardPadding(screenWidth)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Productos Más Vendidos",
                  style: TextStyle(
                    fontSize: _getTitleFontSize(screenWidth),
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF585859),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward, color: theme.colorScheme.primary, size: _getIconSize(screenWidth)),
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.productos);
                  },
                ),
              ],
            ),
            SizedBox(height: _getInnerSpacing(screenWidth)),
            _buildProductRankItem("Aceite Vegetal 1L", "45 unidades", 1, theme, screenWidth),
            _buildProductRankItem("Coca-Cola 600ml", "38 unidades", 2, theme, screenWidth),
            _buildProductRankItem("Leche Entera 1L", "32 unidades", 3, theme, screenWidth),
            _buildProductRankItem("Arroz 1kg", "28 unidades", 4, theme, screenWidth),
            _buildProductRankItem("Jabón Líquido", "25 unidades", 5, theme, screenWidth),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProductRankItem(String product, String sales, int rank, ThemeData theme, double screenWidth) {
    return Container(
      margin: EdgeInsets.only(bottom: _getInnerSpacing(screenWidth)),
      padding: EdgeInsets.all(_getInnerSpacing(screenWidth)),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: _getRankSize(screenWidth),
            height: _getRankSize(screenWidth),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _getSmallFontSize(screenWidth),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: _getInnerSpacing(screenWidth)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF585859),
                    fontSize: _getLabelFontSize(screenWidth),
                  ),
                ),
                Text(
                  sales,
                  style: TextStyle(
                    fontSize: _getSmallFontSize(screenWidth),
                    color: theme.colorScheme.secondary!,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: theme.colorScheme.primary, size: _getIconSize(screenWidth)),
        ],
      ),
    );
  }

  // Métodos responsivos
  double _getScreenPadding(double screenWidth) {
    if (screenWidth < 400) return 12;
    if (screenWidth < 600) return 16;
    return 20;
  }

  double _getCardPadding(double screenWidth) {
    if (screenWidth < 400) return 12; // ← Reducido
    if (screenWidth < 600) return 14;
    return 16;
  }

  double _getSpacing(double screenWidth) {
    if (screenWidth < 400) return 16;
    if (screenWidth < 600) return 18;
    return 20;
  }

  double _getInnerSpacing(double screenWidth) {
    if (screenWidth < 400) return 8;  // ← Reducido
    if (screenWidth < 600) return 10;
    return 12;
  }

  double _getTitleFontSize(double screenWidth) {
    if (screenWidth < 400) return 16;
    if (screenWidth < 600) return 17;
    return 18;
  }

  double _getValueFontSize(double screenWidth) {
    if (screenWidth < 400) return 14;
    if (screenWidth < 600) return 16;
    return 18;
  }

  double _getLabelFontSize(double screenWidth) {
    if (screenWidth < 400) return 11;
    if (screenWidth < 600) return 12;
    return 12;
  }

  double _getSmallFontSize(double screenWidth) {
    if (screenWidth < 400) return 10;
    return 12;
  }

  double _getButtonFontSize(double screenWidth) {
    if (screenWidth < 400) return 12;
    return 14;
  }

  double _getIconSize(double screenWidth) {
    if (screenWidth < 400) return 18;
    return 20;
  }

  double _getSmallIconSize(double screenWidth) {
    if (screenWidth < 400) return 16;
    return 18;
  }

  double _getButtonPadding(double screenWidth) {
    if (screenWidth < 400) return 12;
    return 16;
  }

  double _getMetricCardHeight(double screenWidth) {
    if (screenWidth < 400) return 120;
    if (screenWidth < 600) return 130;
    return 140;
  }

  double _getMetricCardWidth(double screenWidth, bool isTablet) {
    if (isTablet) {
      return (screenWidth - (_getSpacing(screenWidth) * 3)) / 2;
    } else {
      if (screenWidth < 400) return 150; // ← Reducido
      if (screenWidth < 600) return 160;
      return 170;
    }
  }

  double _getRankSize(double screenWidth) {
    if (screenWidth < 400) return 20;
    return 24;
  }



}