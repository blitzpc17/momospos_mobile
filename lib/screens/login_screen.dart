import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../routes/routes.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    // Usar addPostFrameCallback para evitar el error durante el build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Inicializar la base de datos después de que el build haya terminado
    await authProvider.initializeDatabase();
    
    if (mounted) {
      setState(() {
        _isFirstTime = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isTablet = screenWidth > 600;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final authProvider = Provider.of<AuthProvider>(context);

    // Mostrar pantalla de carga mientras se inicializa
    if (_isFirstTime || authProvider.isInitializing) {
      return _buildLoadingScreen(theme);
    }

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
                    
                    // Información de primera instalación
                    _buildFirstTimeInfo(context),
                    
                    // Formulario de login
                    _buildLoginForm(context, theme, screenWidth, authProvider),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(ThemeData theme) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.point_of_sale,
              size: 80,
              color: theme.primaryColor,
            ),
            SizedBox(height: 20),
            Text(
              "MOMO'S POS",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            ),
            SizedBox(height: 20),
            Text(
              'Inicializando sistema...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF585859),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Creando base de datos por primera vez',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF568FA6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstTimeInfo(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.info, color: Colors.blue, size: 24),
          SizedBox(height: 8),
          Text(
            'Primera configuración',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Usa estas credenciales para iniciar:\n'
            'Usuario: admin / Contraseña: admin123\n'
            'Usuario: cajero / Contraseña: cajero123',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blue[700],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, ThemeData theme, double screenWidth, AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Container(
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
            if (authProvider.errorMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        authProvider.errorMessage,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 16),
                      onPressed: () => authProvider.clearError(),
                    ),
                  ],
                ),
              ),
            
            TextFormField(
              controller: _usernameController,
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu usuario';
                }
                return null;
              },
            ),
            SizedBox(height: _getFieldSpacing(screenWidth)),
            TextFormField(
              controller: _passwordController,
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu contraseña';
                }
                return null;
              },
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
                onPressed: authProvider.isLoading ? null : _login,
                child: authProvider.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
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
      ),
    );
  }  

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final success = await Provider.of<AuthProvider>(context, listen: false).login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );
      
      if (success && mounted) {
        Navigator.pushReplacementNamed(context, Routes.dashboard);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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

