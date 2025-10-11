import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:football_venue_booking_app/config/env.dart';
import 'package:football_venue_booking_app/config/navigation_config.dart';
import 'package:football_venue_booking_app/config/user_role.dart';
import 'package:football_venue_booking_app/providers/field_provider.dart';
import 'package:football_venue_booking_app/providers/venue_provider.dart';
import 'package:football_venue_booking_app/services/venue_service.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/master_provider.dart';
import 'providers/booking_provider.dart';

import 'widgets/appbar.dart';

import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // firebase init
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: Env.firebaseApiKey,
      appId: Env.firebaseAppId,
      messagingSenderId: Env.firebaseSenderId,
      projectId: Env.firebaseProjectId,
    ),
  );

  // supabase init
  await Supabase.initialize(
    url: Env.supabaseURL,
    anonKey: Env.supabaseAnonKey
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProxyProvider<AuthProvider, VenueProvider>(
          create: (context) => VenueProvider(
            authProvider: context.read<AuthProvider>(),
            service: VenueService(),
          ),
          update: (_, auth, __) =>
              VenueProvider(authProvider: auth, service: VenueService()),
        ),
        ChangeNotifierProvider(create: (_) => FieldProvider()),
        ChangeNotifierProvider(create: (_) => MasterProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider())
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: Color(0xFFF8F9FA),
        appBarTheme: AppBarTheme(backgroundColor: Color(0xFFF8F9FA)),
      ),
      initialRoute: AppRoutes.splashscreen,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

class MainScreen extends StatefulWidget {
  final UserRole role;

  const MainScreen({super.key, required this.role});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _changeTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = getPages(widget.role);
    final navItems = getBottomNavItems(widget.role);
    final titles = getTitles(widget.role);

    return Scaffold(
      appBar: CustomAppBar(title: titles[_currentIndex]),
      // drawer: AppDrawer(
      //   onItemTap: _changeTab,
      // ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFF8F9FA),
        currentIndex: _currentIndex,
        selectedItemColor: const Color.fromARGB(255, 71, 70, 70),
        unselectedItemColor: const Color.fromARGB(255, 197, 195, 195),
        onTap: _changeTab,
        items: navItems,
      ),
    );
  }
}
