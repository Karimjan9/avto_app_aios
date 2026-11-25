import 'package:material_ui/material_ui.dart';

import 'marketplace_api.dart';

void main() => runApp(AvtoApp(api: MarketplaceApi()));

class AvtoApp extends StatelessWidget {
  const AvtoApp({super.key, required this.api});
  final MarketplaceApi api;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Avto market',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFAF182D)),
      scaffoldBackgroundColor: const Color(0xFFF6F7F9),
      useMaterial3: true,
    ),
    home: MarketplaceHome(api: api),
  );
}

class MarketplaceHome extends StatefulWidget {
  const MarketplaceHome({super.key, required this.api});
  final MarketplaceApi api;

  @override
  State<MarketplaceHome> createState() => _MarketplaceHomeState();
}

class _MarketplaceHomeState extends State<MarketplaceHome> {
  late Future<MarketplaceSnapshot> _snapshot;
  List<MarketplaceSection> _sections = [];
  String? _selectedSection;

  @override
  void initState() {
    super.initState();
    _snapshot = _load();
  }

  Future<MarketplaceSnapshot> _load() async {
    final snapshot = await widget.api.load(section: _selectedSection);
    _sections = snapshot.sections;
    return snapshot;
  }

  void _refresh({String? section}) {
    setState(() {
      _selectedSection = section;
      _snapshot = _load();
    });
  }

  @override
  void dispose() {
    widget.api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Row(
        children: [
          Icon(Icons.directions_car_filled_rounded),
          SizedBox(width: 10),
          Text('Avto market'),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Yangilash',
          onPressed: () => _refresh(section: _selectedSection),
          icon: const Icon(Icons.refresh_rounded),
        ),
        const SizedBox(width: 8),
      ],
    ),
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: FutureBuilder<MarketplaceSnapshot>(
            future: _snapshot,
            builder: (context, state) {
              if (state.hasError) {
                return _MessageState(
                  icon: Icons.wifi_off_rounded,
                  title: 'Ma’lumotlar yuklanmadi',
                  message: 'Internet ulanishini tekshiring va qayta urinib ko‘ring.',
                  action: FilledButton.icon(
                    onPressed: () => _refresh(section: _selectedSection),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Qayta urinish'),
                  ),
                );
              }
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'O‘zingizga mosini toping',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          const Text('Avtomobillar, ehtiyot qismlar va moto'),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('Barchasi'),
                                selected: _selectedSection == null,
                                onSelected: (_) => _refresh(),
                              ),
                              for (final section in _sections)
                                ChoiceChip(
                                  label: Text(section.name),
                                  selected: _selectedSection == section.code,
                                  onSelected: (_) => _refresh(section: section.code),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'So‘nggi e’lonlar',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (state.connectionState != ConnectionState.done)
                    const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                  else if (state.data!.listings.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _MessageState(
                        icon: Icons.search_rounded,
                        title: 'Hozircha e’lonlar yo‘q',
                        message: 'Yangi e’lonlar shu yerda ko‘rinadi.',
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      sliver: SliverLayoutBuilder(
                        builder: (context, constraints) => SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: constraints.crossAxisExtent < 600
                                ? 1
                                : constraints.crossAxisExtent < 900
                                ? 2
                                : 3,
                            mainAxisExtent: 290,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _ListingCard(listing: state.data!.listings[index]),
                            childCount: state.data!.listings.length,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    margin: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 172,
          child: listing.imageUrl == null
              ? const _ImagePlaceholder()
              : Image.network(
                  listing.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, error, stack) => const _ImagePlaceholder(),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                listing.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                listing.formattedPrice,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (listing.city.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  listing.city,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: Icon(
      Icons.directions_car_rounded,
      size: 52,
      color: Theme.of(context).colorScheme.outline,
    ),
  );
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    ),
  );
}
