import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CountryDetailPage extends StatelessWidget {
  final Map country;

  CountryDetailPage({required this.country});

  @override
  Widget build(BuildContext context) {
    final name = country['name']['common'] ?? 'Unknown';
    final capital = country['capital']?[0] ?? 'No Capital';
    final population = country['population'] ?? 0;
    final region = country['region'] ?? 'Unknown';
    final currency = country['currencies']?.entries.first.value['name'] ?? 'N/A';
    final language = country['languages']?.entries.first.value ?? 'N/A';
    final flagUrl = country['flags']['png'];

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: flagUrl,
              width: 200,
              placeholder: (context, url) => CircularProgressIndicator(),
            ),
            SizedBox(height: 20),
            InfoTile(title: 'Capital', value: capital),
            InfoTile(title: 'Region', value: region),
            InfoTile(title: 'Population', value: population.toString()),
            InfoTile(title: 'Currency', value: currency),
            InfoTile(title: 'Language', value: language),
          ],
        ),
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String title;
  final String value;

  InfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Text(value),
    );
  }
}
