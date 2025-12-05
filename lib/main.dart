import 'package:flutter/material.dart';
import 'package:momospos_mobile/providers/variable_global_provider.dart';
import 'package:provider/provider.dart';
import 'providers/providers.dart';
import 'routes/routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RoleProvider()),
        ChangeNotifierProvider(create: (_) => ModuleProvider()),
        ChangeNotifierProvider(create: (_) => SaleProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ClienteProvider()),
        ChangeNotifierProvider(create: (_) => ProveedorProvider()),
        ChangeNotifierProvider(create: (_) => CajaProvider()),
        ChangeNotifierProvider(create: (_) => CompraProvider()),
        ChangeNotifierProvider(create: (_) => VariableGlobalProvider()),
        ChangeNotifierProvider(create: (_) => CategoriaProvider()),
      ],
      child: MaterialApp(
        title: "MOMO'S POS",
        theme: ThemeData(
          primaryColor: Color(0xFF07598C),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: MaterialColor(0xFF07598C, {
              50: Color(0xFFE3F2FD),
              100: Color(0xFFBBDEFB),
              200: Color(0xFF90CAF9),
              300: Color(0xFF64B5F6),
              400: Color(0xFF42A5F5),
              500: Color(0xFF07598C),
              600: Color(0xFF03658C),
              700: Color(0xFF1976D2),
              800: Color(0xFF1565C0),
              900: Color(0xFF0D47A1),
            }),
          ).copyWith(
            secondary: Color(0xFF568FA6),
          ),
          scaffoldBackgroundColor: Color(0xFFF2F2F2),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF07598C),
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF03658C),
          ),
        ),
        initialRoute: Routes.login,
        routes: Routes.getRoutes(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}