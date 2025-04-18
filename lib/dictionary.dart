import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DictionaryPage extends StatefulWidget {
  @override
  _DictionaryPageState createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> with SingleTickerProviderStateMixin {
  TextEditingController _textController = TextEditingController();
  String _definition = '';
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _searchWord(String word) async {
    if (word.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _definition = '';
    });

    final response = await http.get(Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _definition = data[0]['meanings'][0]['definitions'][0]['definition'];
        _isLoading = false;
      });
      _animationController.forward(from: 0.0);
    } else {
      setState(() {
        _definition = 'Word not found';
        _isLoading = false;
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Dictionary',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 32),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Enter a word',
                prefixIcon: Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _searchWord(_textController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Search'),
            ),
            SizedBox(height: 24),
            if (_isLoading)
              SpinKitFadingCircle(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              )
            else if (_definition.isNotEmpty)
              FadeTransition(
                opacity: _fadeAnimation,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.book_rounded,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(height: 16),
                        Text(
                          _definition,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
