import 'dart:convert';

import 'package:http/http.dart' as http;

class MarketplaceException implements Exception {
  const MarketplaceException(this.message);
  final String message;
}

class MarketplaceSection {
  const MarketplaceSection({required this.code, required this.name});

  factory MarketplaceSection.fromJson(Map<String, dynamic> json) =>
      MarketplaceSection(code: json['code'] as String, name: json['name'] as String);

  final String code;
  final String name;
}

class Listing {
  const Listing({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    required this.city,
    this.imageUrl,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List<dynamic>? ?? [];
    final image = images.isEmpty ? null : images.first as Map<String, dynamic>;
    return Listing(
      id: json['id'] as int,
      title: json['title'] as String,
      price: json['price'].toString(),
      currency: json['currency'] as String,
      city: json['city'] as String? ?? '',
      imageUrl: (image?['thumbnail_url'] ?? image?['display_url'] ?? image?['url']) as String?,
    );
  }

  final int id;
  final String title;
  final String price;
  final String currency;
  final String city;
  final String? imageUrl;

  String get formattedPrice {
    final parts = price.split('.');
    final whole = parts.first.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');
    final fraction = parts.length > 1 && parts[1] != '00' ? '.${parts[1]}' : '';
    return '$whole$fraction ${currency == 'UZS' ? "so‘m" : currency}';
  }
}

class MarketplaceSnapshot {
  const MarketplaceSnapshot({required this.sections, required this.listings});
  final List<MarketplaceSection> sections;
  final List<Listing> listings;
}

class MarketplaceApi {
  MarketplaceApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      baseUri = Uri.parse(
        '${(baseUrl ?? const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://platform.buxoroavto.uz/api/v1')).replaceAll(RegExp(r'/+$'), '')}/',
      );

  final http.Client _client;
  final Uri baseUri;

  Future<Map<String, dynamic>> _get(String path, {Map<String, String>? query}) async {
    final response = await _client
        .get(
          baseUri.resolve(path).replace(queryParameters: query),
          headers: {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw const MarketplaceException('Ma’lumotlarni yuklab bo‘lmadi. Qayta urinib ko‘ring.');
    }
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  Future<MarketplaceSnapshot> load({String? section}) async {
    final responses = await Future.wait([
      _get('catalog'),
      _get('listings', query: {'per_page': '12', 'section': ?section}),
    ]);
    final catalog = responses[0]['data'] as Map<String, dynamic>;
    return MarketplaceSnapshot(
      sections: (catalog['sections'] as List<dynamic>)
          .map((item) => MarketplaceSection.fromJson(item as Map<String, dynamic>))
          .toList(),
      listings: (responses[1]['data'] as List<dynamic>)
          .map((item) => Listing.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  void close() => _client.close();
}
