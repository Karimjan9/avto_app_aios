import 'dart:convert';

import 'package:avto_market/main.dart';
import 'package:avto_market/marketplace_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response catalog() => http.Response(
  jsonEncode({
    'data': {
      'sections': [
        {'code': 'cars', 'name': 'Avtomobillar'},
      ],
    },
  }),
  200,
);

http.Response listings({bool empty = false}) => http.Response(
  jsonEncode({
    'data': empty
        ? []
        : [
            {
              'id': 1,
              'title': 'Chevrolet Cobalt',
              'price': '15000.00',
              'currency': 'USD',
              'city': 'Buxoro',
              'images': [],
            },
          ],
    'links': {},
    'meta': {},
  }),
  200,
);

void main() {
  test('configured API paths, filters, and string prices work together', () async {
    final requests = <Uri>[];
    final api = MarketplaceApi(
      baseUrl: 'https://example.test/api/v1',
      client: MockClient((request) async {
        requests.add(request.url);
        return request.url.path.endsWith('/catalog') ? catalog() : listings();
      }),
    );
    final result = await api.load(section: 'cars');
    expect(requests.map((uri) => uri.path), containsAll(['/api/v1/catalog', '/api/v1/listings']));
    expect(requests.last.queryParameters['section'], 'cars');
    expect(result.sections.single.code, 'cars');
    expect(result.listings.single.formattedPrice, '15 000 USD');
    api.close();
  });

  test('server failure is surfaced instead of producing sample listings', () async {
    final api = MarketplaceApi(client: MockClient((_) async => http.Response('{}', 503)));
    await expectLater(api.load(), throwsA(isA<MarketplaceException>()));
    api.close();
  });

  testWidgets('marketplace displays the fetched listing', (tester) async {
    final api = MarketplaceApi(
      client: MockClient(
        (request) async => request.url.path.endsWith('/catalog') ? catalog() : listings(),
      ),
    );
    await tester.pumpWidget(AvtoApp(api: api));
    await tester.pumpAndSettle();
    expect(find.text('Chevrolet Cobalt'), findsOneWidget);
    expect(find.text('15 000 USD'), findsOneWidget);
    expect(find.text('Avtomobillar'), findsOneWidget);
  });

  testWidgets('an empty catalog displays an honest empty state', (tester) async {
    final api = MarketplaceApi(
      client: MockClient(
        (request) async =>
            request.url.path.endsWith('/catalog') ? catalog() : listings(empty: true),
      ),
    );
    await tester.pumpWidget(AvtoApp(api: api));
    await tester.pumpAndSettle();
    expect(find.text('Hozircha e’lonlar yo‘q'), findsOneWidget);
    expect(find.text('Chevrolet Cobalt'), findsNothing);
  });
}
