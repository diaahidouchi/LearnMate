import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class QuotesPage extends StatefulWidget {
  @override
  _QuotesPageState createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> with SingleTickerProviderStateMixin {
  String? _quote;
  bool _loading = true;
  String? _error;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    fetchQuote();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchQuote() async {
    try {
      final response = await http.get(Uri.parse('https://zenquotes.io/api/random'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _quote = '${data[0]["q"]} — ${data[0]["a"]}';
          _loading = false;
        });
        _controller.forward(from: 0.0);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load quote: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Quotes',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 32),
            Expanded(
              child: Center(
                child: _loading
                    ? SpinKitFadingCircle(
                        color: Theme.of(context).colorScheme.primary,
                        size: 50.0,
                      )
                    : _error != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Theme.of(context).colorScheme.error,
                                size: 48,
                              ),
                              SizedBox(height: 16),
                              Text(
                                _error!,
                                style: GoogleFonts.poppins(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : FadeTransition(
                            opacity: _fadeAnimation,
                            child: Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.format_quote_rounded,
                                      size: 48,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      _quote ?? 'No quote found',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontStyle: FontStyle.italic,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 24),
                                    ElevatedButton.icon(
                                      onPressed: fetchQuote,
                                      icon: Icon(Icons.refresh_rounded),
                                      label: Text('New Quote'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
