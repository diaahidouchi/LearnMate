import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CountriesPage extends StatefulWidget {
  @override
  _CountriesPageState createState() => _CountriesPageState();
}

class _CountriesPageState extends State<CountriesPage> with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  Map<String, dynamic>? _countryInfo;
  bool _loading = false;
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchCountryInfo() async {
    if (_searchQuery.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _countryInfo = null;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://restcountries.com/v3.1/name/$_searchQuery?fullText=true'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _countryInfo = data[0];
          _loading = false;
        });
        _controller.forward(from: 0.0);
      } else {
        setState(() {
          _error = 'No country found';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load country: $e';
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
              'Countries',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 32),
            TextField(
              decoration: InputDecoration(
                labelText: 'Search for a country',
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
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              onSubmitted: (_) => fetchCountryInfo(),
            ),
            SizedBox(height: 24),
            if (_loading)
              SpinKitFadingCircle(
                color: Theme.of(context).colorScheme.primary,
                size: 50.0,
              )
            else if (_error != null)
              Column(
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
            else if (_countryInfo != null)
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
                        CachedNetworkImage(
                          imageUrl: _countryInfo!['flags']['png'],
                          height: 120,
                          placeholder: (context, url) => SpinKitFadingCircle(
                            color: Theme.of(context).colorScheme.primary,
                            size: 50.0,
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: 48,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          _countryInfo!['name']['common'],
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildInfoRow('Capital', _countryInfo!['capital']?[0] ?? 'N/A'),
                        _buildInfoRow('Population', _countryInfo!['population']?.toString() ?? 'N/A'),
                        _buildInfoRow('Region', _countryInfo!['region'] ?? 'N/A'),
                        _buildInfoRow('Subregion', _countryInfo!['subregion'] ?? 'N/A'),
                        _buildInfoRow('Languages', _countryInfo!['languages']?.values.join(', ') ?? 'N/A'),
                        _buildInfoRow('Currency', _countryInfo!['currencies']?.values.first['name'] ?? 'N/A'),
                        _buildInfoRow('Borders', _countryInfo!['borders']?.join(', ') ?? 'No borders'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
