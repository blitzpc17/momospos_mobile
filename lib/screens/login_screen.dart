import 'package:flutter/material.dart';
import '../routes/routes.dart';

class LoginScreen extends StatelessWidget {
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 500 : 400,
                minWidth: 300,
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(_getResponsivePadding(screenWidth)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo y título
                    _buildHeader(context, theme, isTablet, isLandscape),
                    
                    SizedBox(height: _getResponsiveSpacing(screenHeight)),
                    
                    // Formulario de login
                    _buildLoginForm(context, theme, screenWidth),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isTablet, bool isLandscape) {
    return Container(
      margin: EdgeInsets.only(bottom: _getResponsiveMargin(isTablet)),
      child: Column(
        children: [
          Icon(
            Icons.point_of_sale,
            size: _getIconSize(isTablet, isLandscape),
            color: theme.primaryColor,
          ),
          SizedBox(height: _getTitleSpacing(isTablet)),
          Text(
            "MOMO'S POS",
            style: TextStyle(
              fontSize: _getTitleFontSize(isTablet),
              fontWeight: FontWeight.bold,
              color: Color(0xFF585859),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            "Sistema de Punto de Venta",
            style: TextStyle(
              fontSize: _getSubtitleFontSize(isTablet),
              color: theme.colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, ThemeData theme, double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(_getFormPadding(screenWidth)),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: "Usuario",
              prefixIcon: Icon(Icons.person, color: theme.colorScheme.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: _getFieldPadding(screenWidth),
              ),
            ),
          ),
          SizedBox(height: _getFieldSpacing(screenWidth)),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Contraseña",
              prefixIcon: Icon(Icons.lock, color: theme.colorScheme.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: _getFieldPadding(screenWidth),
              ),
            ),
          ),
          SizedBox(height: _getButtonSpacing(screenWidth)),
          Container(
            width: double.infinity,
            height: _getButtonHeight(screenWidth),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 3,
                shadowColor: Colors.black26,
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, Routes.dashboard);
              },
              child: Text(
                "INICIAR SESIÓN",
                style: TextStyle(
                  fontSize: _getButtonFontSize(screenWidth),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Métodos para calcular valores responsivos
  double _getResponsivePadding(double screenWidth) {
    if (screenWidth < 400) return 20;
    if (screenWidth < 600) return 30;
    return 40;
  }

  double _getResponsiveSpacing(double screenHeight) {
    if (screenHeight < 600) return 20;
    return 40;
  }

  double _getResponsiveMargin(bool isTablet) {
    return isTablet ? 50 : 40;
  }

  double _getIconSize(bool isTablet, bool isLandscape) {
    if (isTablet) return isLandscape ? 90 : 100;
    return isLandscape ? 70 : 80;
  }

  double _getTitleSpacing(bool isTablet) {
    return isTablet ? 25 : 20;
  }

  double _getTitleFontSize(bool isTablet) {
    return isTablet ? 36 : 32;
  }

  double _getSubtitleFontSize(bool isTablet) {
    return isTablet ? 18 : 16;
  }

  double _getFormPadding(double screenWidth) {
    if (screenWidth < 400) return 20;
    if (screenWidth < 600) return 25;
    return 30;
  }

  double _getFieldPadding(double screenWidth) {
    if (screenWidth < 400) return 12;
    return 16;
  }

  double _getFieldSpacing(double screenWidth) {
    if (screenWidth < 400) return 15;
    return 20;
  }

  double _getButtonSpacing(double screenWidth) {
    if (screenWidth < 400) return 20;
    return 30;
  }

  double _getButtonHeight(double screenWidth) {
    if (screenWidth < 400) return 45;
    return 50;
  }

  double _getButtonFontSize(double screenWidth) {
    if (screenWidth < 400) return 14;
    return 16;
  }
}