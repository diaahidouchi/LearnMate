import 'package:flutter/material.dart';
import 'package:learn/countries.dart';
import 'package:learn/dictionary.dart';
import 'package:learn/quotes.dart';
import 'package:learn/quiz.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learn & Inspire',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: Color(0xFF6200EE),
          secondary: Color(0xFF03DAC6),
          surface: Colors.white,
          background: Colors.white,
          error: Color(0xFFB00020),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF6200EE),
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6200EE),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF6200EE),
          unselectedItemColor: Colors.grey.shade600,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: Color(0xFFBB86FC),
          secondary: Color(0xFF03DAC6),
          surface: Color(0xFF121212),
          background: Color(0xFF121212),
          error: Color(0xFFCF6679),
        ),
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFFBB86FC),
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFFBB86FC),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF121212),
          selectedItemColor: Color(0xFFBB86FC),
          unselectedItemColor: Colors.grey.shade400,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    QuotesPage(),
    DictionaryPage(),
    CountriesPage(),
    QuizPage(),
  ];

  final List<String> _titles = ['Quotes', 'Dictionary', 'Countries', 'Quiz'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.background.withOpacity(0.8),
            ],
          ),
        ),
        child: PageTransitionSwitcher(
          transitionBuilder: (
            Widget child,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
          child: _pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.format_quote_rounded),
                activeIcon: Icon(Icons.format_quote_rounded, size: 28),
                label: 'Quotes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book_outlined),
                activeIcon: Icon(Icons.book_rounded, size: 28),
                label: 'Dictionary',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.public_outlined),
                activeIcon: Icon(Icons.public_rounded, size: 28),
                label: 'Countries',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.quiz_outlined),
                activeIcon: Icon(Icons.quiz_rounded, size: 28),
                label: 'Quiz',
              ),
            ],
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}

class FadeThroughTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const FadeThroughTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 0.25),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
    );
  }
}
