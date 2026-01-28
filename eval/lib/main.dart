import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/category_provider.dart';
import 'providers/product_provider.dart';
import 'providers/search_provider.dart';
import 'providers/scanned_products_provider.dart';
import 'pages/main_navigation_page.dart';
import 'pages/search_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => ScannedProductsProvider()),
      ],
      child: MaterialApp(
        title: 'OpenFoodFacts',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MainNavigationPage(),
        routes: {
          '/search': (context) => const SearchPage(),
        },
      ),
    );
  }
}
