import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'models/motorcycle.dart';
import 'providers/motorcycle_provider.dart';
import 'services/api_service.dart';
import 'services/database_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => MotorcycleProvider(
        database: DatabaseService(),
        api: ApiService(),
      )..initialize(),
      child: const ZonariderApp(),
    ),
  );
}

class ZonariderApp extends StatelessWidget {
  const ZonariderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZONARIDER',
      debugShowCheckedModeBanner: false,
      theme: buildZonariderTheme(),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int index = 0;

  void goTo(int value) => setState(() => index = value);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onExplore: () => goTo(1)),
      const ExploreScreen(),
      const CompareScreen(),
      FavoritesScreen(onExplore: () => goTo(1)),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: index, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: goTo,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Jelajahi',
          ),
          NavigationDestination(
            icon: Icon(Icons.compare_arrows_rounded),
            label: 'Bandingkan',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Favorit',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onExplore});
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MotorcycleProvider>();
    final popular = provider.motorcycles.take(6).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        const BrandHeader(),
        const SizedBox(height: 28),
        const Eyebrow('KATALOG MOTOR INDONESIA'),
        const SizedBox(height: 12),
        Text(
          'Temukan motor\nuntuk perjalananmu.',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.04,
                letterSpacing: -1.2,
              ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Jelajahi motor populer dari berbagai merek. Kenali spesifikasinya dan temukan pilihan yang sesuai dengan kebutuhanmu.',
          style: TextStyle(color: AppColors.muted, height: 1.55, fontSize: 13),
        ),
        const SizedBox(height: 20),
        _SearchField(
          onChanged: provider.setQuery,
          onTap: onExplore,
        ),
        const SizedBox(height: 28),
        const SectionHeading(
          title: 'Jelajahi berdasarkan merek',
          subtitle: '4 merek pilihan',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Honda', 'Yamaha', 'Suzuki', 'Kawasaki']
              .map(
                (brand) => OutlinedButton(
                  onPressed: () {
                    provider.setBrand(brand);
                    onExplore();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.text,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(brand),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 28),
        SectionHeading(
          title: 'Motor pilihan',
          subtitle: '${provider.motorcycles.length} model dalam katalog',
          actionLabel: 'Lihat semua',
          onAction: onExplore,
        ),
        const SizedBox(height: 12),
        if (provider.isLoading)
          const LoadingState()
        else if (provider.loadError != null)
          ErrorState(message: provider.loadError!)
        else
          ...popular.map(
            (motor) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: MotorcycleListTile(motorcycle: motor),
            ),
          ),
        const SizedBox(height: 8),
        _InfoNote(
          text:
              'Harga dan spesifikasi hanya ditampilkan jika sudah tersedia dan dapat dicocokkan dengan varian motor yang tepat.',
        ),
      ],
    );
  }
}

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MotorcycleProvider>();
    final motors = provider.filteredMotorcycles;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BrandHeader(),
              const SizedBox(height: 22),
              Text(
                'Jelajahi motor',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              _SearchField(onChanged: provider.setQuery),
              const SizedBox(height: 14),
              const Eyebrow('PILIH MEREK'),
              const SizedBox(height: 7),
              _ChoiceScroller(
                values: const ['Semua', 'Honda', 'Yamaha', 'Suzuki', 'Kawasaki'],
                selected: provider.selectedBrand,
                onSelected: provider.setBrand,
              ),
              const SizedBox(height: 12),
              const Eyebrow('PILIH KATEGORI'),
              const SizedBox(height: 7),
              _ChoiceScroller(
                values: const [
                  'Semua',
                  'Matic',
                  'Bebek',
                  'Sport',
                  'Trail',
                  'Adventure',
                  'Retro',
                ],
                selected: provider.selectedCategory,
                onSelected: provider.setCategory,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${motors.length} motor ditemukan',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: provider.resetFilters,
                    icon: const Icon(Icons.restart_alt, size: 17),
                    label: const Text('Atur ulang'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: provider.isLoading
              ? const LoadingState()
              : provider.loadError != null
                  ? ErrorState(message: provider.loadError!)
                  : motors.isEmpty
                      ? const EmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'Motor tidak ditemukan',
                          message:
                              'Coba ubah kata pencarian, merek, atau kategori.',
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                          itemCount: motors.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: .73,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemBuilder: (context, index) =>
                              MotorcycleCard(motorcycle: motors[index]),
                        ),
        ),
      ],
    );
  }
}

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.motorcycle});
  final Motorcycle motorcycle;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool loadingApi = false;
  String? apiError;
  List<Map<String, dynamic>> apiResults = [];

  @override
  Widget build(BuildContext context) {
    final motor = widget.motorcycle;
    final provider = context.watch<MotorcycleProvider>();
    final favorite = provider.favoriteIds.contains(motor.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail motor'),
        actions: [
          IconButton(
            tooltip: favorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
            onPressed: () => _toggleFavorite(),
            icon: Icon(
              favorite ? Icons.favorite : Icons.favorite_border,
              color: favorite ? AppColors.orange : AppColors.text,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          MotorcycleArtwork(motorcycle: motor, height: 225, large: true),
          const SizedBox(height: 20),
          Eyebrow(motor.brand.toUpperCase()),
          const SizedBox(height: 6),
          Text(
            motor.name,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '${motor.category} • ${motor.modelYear ?? 'Tahun model belum diverifikasi'}',
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    favorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  label: Text(favorite ? 'Tersimpan' : 'Simpan favorit'),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CompareSelectionScreen(firstMotor: motor),
                  ),
                ),
                icon: const Icon(Icons.compare_arrows),
                label: const Text('Bandingkan'),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const SectionHeading(
            title: 'Spesifikasi motor',
            subtitle: 'Data yang tersedia',
          ),
          const SizedBox(height: 8),
         
_SpecRow('Merek', motor.brand),
_SpecRow('Kategori', motor.category),

if (motor.modelYear != null)
  _SpecRow('Tahun model', motor.modelYear.toString()),

if (motor.displacement != null)
  _SpecRow(
    'Kapasitas mesin',
    '${_number(motor.displacement!)} cc',
  ),

if (motor.engine?.isNotEmpty == true)
  _SpecRow('Tipe mesin', motor.engine),

if (motor.cooling?.isNotEmpty == true)
  _SpecRow('Sistem pendingin', motor.cooling),

if (motor.transmission?.isNotEmpty == true)
  _SpecRow('Transmisi', motor.transmission),

if (motor.power?.isNotEmpty == true)
  _SpecRow('Tenaga maksimum', motor.power),

if (motor.torque?.isNotEmpty == true)
  _SpecRow('Torsi maksimum', motor.torque),

if (motor.weight != null)
  _SpecRow('Berat', '${_number(motor.weight!)} kg'),

if (motor.seatHeight != null)
  _SpecRow('Tinggi jok', '${_number(motor.seatHeight!)} mm'),

if (motor.price != null)
  _SpecRow('Harga referensi', _rupiah(motor.price!)),

if (motor.modelYear == null &&
    motor.displacement == null &&
    motor.engine?.isNotEmpty != true &&
    motor.cooling?.isNotEmpty != true &&
    motor.transmission?.isNotEmpty != true &&
    motor.power?.isNotEmpty != true &&
    motor.torque?.isNotEmpty != true &&
    motor.weight == null &&
    motor.seatHeight == null &&
    motor.price == null)
  const Padding(
    padding: EdgeInsets.only(top: 12),
    child: _InfoNote(
      text: 'Informasi teknis motor ini belum tersedia dalam katalog.',
    ),
  ),

          const SizedBox(height: 22),
          const SectionHeading(
            title: 'Periksa data tambahan',
            subtitle: 'Melalui layanan API',
          ),
          const SizedBox(height: 8),
          const Text(
            'Cari data pembanding dari API. Hasil API ditampilkan terpisah agar varian yang berbeda tidak langsung dianggap sebagai spesifikasi motor ini.',
            style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: loadingApi ? null : _fetchApi,
            icon: loadingApi
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_download_outlined),
            label: Text(
              loadingApi ? 'Mengambil data...' : 'Ambil data dari API',
            ),
          ),
          if (apiError != null) ...[
            const SizedBox(height: 10),
            _InfoNote(text: apiError!, warning: true),
          ],
          if (apiResults.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              '${apiResults.length} hasil ditemukan dari API',
              style: const TextStyle(
                color: AppColors.orange,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ...apiResults.map((result) => _ApiResultCard(data: result)),
          ],
          const SizedBox(height: 14),
          const _InfoNote(
            text:
                'Data kosong berarti belum ada data yang diverifikasi untuk model dan varian tersebut. Jangan menganggap hasil pencarian API sebagai spesifikasi resmi tanpa mencocokkan tahun dan variannya.',
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    await context.read<MotorcycleProvider>().toggleFavorite(widget.motorcycle);
    if (!mounted) return;
    final isSaved = context
        .read<MotorcycleProvider>()
        .favoriteIds
        .contains(widget.motorcycle.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSaved
              ? 'Motor ditambahkan ke daftar favorit.'
              : 'Motor dihapus dari daftar favorit.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _fetchApi() async {
    setState(() {
      loadingApi = true;
      apiError = null;
      apiResults = [];
    });
    try {
      final result =
          await context.read<MotorcycleProvider>().fetchApi(widget.motorcycle);
      if (!mounted) return;
      setState(() => apiResults = result);
      if (result.isEmpty) {
        setState(() => apiError =
            'API tidak menemukan data. Katalog lokal tetap bisa digunakan.');
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => apiError =
          error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loadingApi = false);
    }
  }
}

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}


class _CompareScreenState extends State<CompareScreen> {
  Motorcycle? first;
  Motorcycle? second;

  @override
  Widget build(BuildContext context) {
    final motors = context.watch<MotorcycleProvider>().motorcycles;

    final ready = first != null &&
        second != null &&
        first!.id != second!.id;

    final hasTechnicalData = first != null &&
        second != null &&
        (first!.modelYear != null ||
            second!.modelYear != null ||
            first!.displacement != null ||
            second!.displacement != null ||
            first!.engine?.isNotEmpty == true ||
            second!.engine?.isNotEmpty == true ||
            first!.transmission?.isNotEmpty == true ||
            second!.transmission?.isNotEmpty == true ||
            first!.power?.isNotEmpty == true ||
            second!.power?.isNotEmpty == true ||
            first!.torque?.isNotEmpty == true ||
            second!.torque?.isNotEmpty == true ||
            first!.weight != null ||
            second!.weight != null ||
            first!.price != null ||
            second!.price != null);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        const BrandHeader(),
        const SizedBox(height: 24),
        Text(
          'Bandingkan motor',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),
        const Text(
          'Pilih dua motor untuk melihat perbedaan spesifikasinya.',
          style: TextStyle(color: AppColors.muted, height: 1.5),
        ),
        const SizedBox(height: 20),
        _MotorDropdown(
          label: 'Motor pertama',
          value: first,
          motors: motors,
          onChanged: (value) => setState(() => first = value),
        ),
        const SizedBox(height: 12),
        _MotorDropdown(
          label: 'Motor kedua',
          value: second,
          motors: motors,
          onChanged: (value) => setState(() => second = value),
        ),
        const SizedBox(height: 22),

        if (first != null && second != null && first!.id == second!.id)
          const _InfoNote(
            text: 'Pilih dua motor yang berbeda untuk membandingkan.',
            warning: true,
          )
        else if (ready) ...[
          _CompareHeader(first: first!, second: second!),
          const SizedBox(height: 12),

          _CompareRow(
            'Kategori',
            first!.category,
            second!.category,
          ),

          if (first!.modelYear != null || second!.modelYear != null)
            _CompareRow(
              'Tahun model',
              _orUnavailable(first!.modelYear?.toString()),
              _orUnavailable(second!.modelYear?.toString()),
            ),

          if (first!.displacement != null ||
              second!.displacement != null)
            _CompareRow(
              'Kapasitas mesin',
              _orUnavailable(
                first!.displacement == null
                    ? null
                    : '${_number(first!.displacement!)} cc',
              ),
              _orUnavailable(
                second!.displacement == null
                    ? null
                    : '${_number(second!.displacement!)} cc',
              ),
            ),

          if (first!.engine?.isNotEmpty == true ||
              second!.engine?.isNotEmpty == true)
            _CompareRow(
              'Tipe mesin',
              _orUnavailable(first!.engine),
              _orUnavailable(second!.engine),
            ),

          if (first!.transmission?.isNotEmpty == true ||
              second!.transmission?.isNotEmpty == true)
            _CompareRow(
              'Transmisi',
              _orUnavailable(first!.transmission),
              _orUnavailable(second!.transmission),
            ),

          if (first!.power?.isNotEmpty == true ||
              second!.power?.isNotEmpty == true)
            _CompareRow(
              'Tenaga',
              _orUnavailable(first!.power),
              _orUnavailable(second!.power),
            ),

          if (first!.torque?.isNotEmpty == true ||
              second!.torque?.isNotEmpty == true)
            _CompareRow(
              'Torsi',
              _orUnavailable(first!.torque),
              _orUnavailable(second!.torque),
            ),

          if (first!.weight != null || second!.weight != null)
            _CompareRow(
              'Berat',
              first!.weight == null
                  ? 'Belum tersedia'
                  : '${_number(first!.weight!)} kg',
              second!.weight == null
                  ? 'Belum tersedia'
                  : '${_number(second!.weight!)} kg',
            ),

          if (first!.price != null || second!.price != null)
            _CompareRow(
              'Harga referensi',
              first!.price == null
                  ? 'Belum tersedia'
                  : _rupiah(first!.price!),
              second!.price == null
                  ? 'Belum tersedia'
                  : _rupiah(second!.price!),
            ),

          if (!hasTechnicalData) ...[
            const SizedBox(height: 10),
            const _InfoNote(
              text: 'Data teknis kedua motor belum tersedia dalam katalog. '
                  'Perbandingan belum dapat dilakukan secara lengkap.',
            ),
          ],
        ] else
          const EmptyState(
            icon: Icons.compare_arrows_rounded,
            title: 'Siap membandingkan?',
            message:
                'Pilih dua motor berbeda pada pilihan di atas. '
                'Hasil perbandingan akan muncul di sini.',
          ),
      ],
    );
  }
}


class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.onExplore});
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MotorcycleProvider>();
    final favorites = provider.favorites;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        const BrandHeader(),
        const SizedBox(height: 24),
        Text(
          'Motor favorit',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Kumpulan motor yang kamu simpan untuk dilihat kembali.',
          style: TextStyle(color: AppColors.muted, height: 1.5),
        ),
        const SizedBox(height: 18),
        if (favorites.isEmpty)
          EmptyState(
            icon: Icons.favorite_border_rounded,
            title: 'Belum ada motor favorit',
            message:
                'Simpan motor melalui ikon hati pada kartu atau halaman detail. Daftarnya akan tersimpan di perangkat ini.',
            actionLabel: 'Jelajahi katalog',
            onAction: onExplore,
          )
        else
          ...favorites.map(
            (motor) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: MotorcycleListTile(motorcycle: motor),
            ),
          ),
      ],
    );
  }
}

class CompareSelectionScreen extends StatelessWidget {
  const CompareSelectionScreen({super.key, required this.firstMotor});
  final Motorcycle firstMotor;

  @override
  Widget build(BuildContext context) {
    final motors = context
        .watch<MotorcycleProvider>()
        .motorcycles
        .where((motor) => motor.id != firstMotor.id)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Pilih motor kedua')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: motors.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final motor = motors[index];
          return MotorcycleListTile(
            motorcycle: motor,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CompareResultScreen(
                  first: firstMotor,
                  second: motor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CompareResultScreen extends StatelessWidget {
  const CompareResultScreen({
    super.key,
    required this.first,
    required this.second,
  });
  final Motorcycle first;
  final Motorcycle second;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Hasil perbandingan')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _CompareHeader(first: first, second: second),
            const SizedBox(height: 12),
            _CompareRow('Kategori', first.category, second.category),
            _CompareRow(
              'Kapasitas mesin',
              _orUnavailable(first.displacement == null
                  ? null
                  : '${_number(first.displacement!)} cc'),
              _orUnavailable(second.displacement == null
                  ? null
                  : '${_number(second.displacement!)} cc'),
            ),
            _CompareRow(
              'Tenaga',
              _orUnavailable(first.power),
              _orUnavailable(second.power),
            ),
            _CompareRow(
              'Torsi',
              _orUnavailable(first.torque),
              _orUnavailable(second.torque),
            ),
            _CompareRow(
              'Transmisi',
              _orUnavailable(first.transmission),
              _orUnavailable(second.transmission),
            ),
            _CompareRow(
              'Harga referensi',
              first.price == null ? 'Belum tersedia' : _rupiah(first.price!),
              second.price == null ? 'Belum tersedia' : _rupiah(second.price!),
            ),
          ],
        ),
      );
}

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.orange,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.two_wheeler_rounded,
              color: AppColors.background,
              size: 25,
            ),
          ),
          const SizedBox(width: 11),
          const Text(
            'ZONA',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
              fontSize: 17,
            ),
          ),
          const Text(
            'RIDER',
            style: TextStyle(
              color: AppColors.orange,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
              fontSize: 17,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'ZONARIDER',
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'ZONARIDER',
              applicationVersion: '1.1.0',
              children: const [
                Text(
                  'Katalog motor Indonesia untuk menjelajahi, menyimpan, dan membandingkan pilihan motor.',
                ),
              ],
            ),
            icon: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.muted,
            ),
          ),
        ],
      );
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: AppColors.orange,
          letterSpacing: 1.6,
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  color: AppColors.orange,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      );
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged, this.onTap});
  final ValueChanged<String> onChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => TextField(
        onTap: onTap,
        readOnly: onTap != null,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          hintText: 'Cari nama motor atau merek...',
          prefixIcon: Icon(Icons.search_rounded, size: 25),
          suffixIcon: Icon(Icons.tune_rounded),
        ),
      );
}

class _ChoiceScroller extends StatelessWidget {
  const _ChoiceScroller({
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  final List<String> values;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: values
              .map(
                (value) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(value),
                    selected: selected == value,
                    onSelected: (_) => onSelected(value),
                    showCheckmark: true,
                  ),
                ),
              )
              .toList(),
        ),
      );
}

class MotorcycleCard extends StatelessWidget {
  const MotorcycleCard({super.key, required this.motorcycle});
  final Motorcycle motorcycle;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MotorcycleProvider>();
    final saved = provider.favoriteIds.contains(motorcycle.id);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _openDetail(context),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: MotorcycleArtwork(
                        motorcycle: motorcycle,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Material(
                        color: AppColors.background.withValues(alpha: .78),
                        shape: const CircleBorder(),
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: saved
                              ? 'Hapus dari favorit'
                              : 'Simpan ke favorit',
                          onPressed: () =>
                              provider.toggleFavorite(motorcycle),
                          icon: Icon(
                            saved
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: saved ? AppColors.orange : AppColors.text,
                            size: 19,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Eyebrow(motorcycle.brand.toUpperCase()),
              const SizedBox(height: 4),
              Text(
                motorcycle.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                motorcycle.category,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(motorcycle: motorcycle),
      ),
    );
  }
}

class MotorcycleListTile extends StatelessWidget {
  const MotorcycleListTile({
    super.key,
    required this.motorcycle,
    this.onTap,
  });

  final Motorcycle motorcycle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: onTap ??
              () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DetailScreen(motorcycle: motorcycle),
                    ),
                  ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  height: 70,
                  child: MotorcycleArtwork(
                    motorcycle: motorcycle,
                    height: 70,
                    compact: true,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        motorcycle.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        motorcycle.category,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.text,
                ),
              ],
            ),
          ),
        ),
      );
}

class MotorcycleArtwork extends StatelessWidget {
  const MotorcycleArtwork({
    super.key,
    required this.motorcycle,
    required this.height,
    this.large = false,
    this.compact = false,
  });

  final Motorcycle motorcycle;
  final double height;
  final bool large;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF343D47), Color(0xFF20262D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          if (!compact)
            Positioned(
              right: 9,
              top: 8,
              child: Icon(
                Icons.two_wheeler_rounded,
                color: AppColors.orange.withValues(alpha: .9),
                size: 17,
              ),
            ),
          if (motorcycle.imageAsset != null)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: ColoredBox(
                  color: Colors.white,
                  child: Image.asset(
                    motorcycle.imageAsset!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        _iconFor(motorcycle.category),
                        size: large ? 104 : compact ? 35 : 58,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            Center(
              child: Icon(
                _iconFor(motorcycle.category),
                size: large ? 104 : compact ? 35 : 58,
                color: Colors.white.withValues(alpha: .82),
              ),
            ),
          if (large)
            Positioned(
              left: 15,
              bottom: 13,
              child: Text(
                motorcycle.brand.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _iconFor(String category) {
    switch (category) {
      case 'Sport':
        return Icons.speed_rounded;
      case 'Trail':
      case 'Adventure':
        return Icons.terrain_rounded;
      case 'Retro':
        return Icons.two_wheeler_rounded;
      default:
        return Icons.two_wheeler_rounded;
    }
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow(this.label, this.value);
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value == null || value!.isEmpty
                    ? 'Belum tersedia'
                    : value!,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
}

class _MotorDropdown extends StatelessWidget {
  const _MotorDropdown({
    required this.label,
    required this.value,
    required this.motors,
    required this.onChanged,
  });

  final String label;
  final Motorcycle? value;
  final List<Motorcycle> motors;
  final ValueChanged<Motorcycle?> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<Motorcycle>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: motors
            .map(
              (motor) => DropdownMenuItem(
                value: motor,
                child: Text(
                  motor.fullName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      );
}

class _CompareHeader extends StatelessWidget {
  const _CompareHeader({required this.first, required this.second});
  final Motorcycle first;
  final Motorcycle second;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Eyebrow('PERBANDINGAN MOTOR'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      first.fullName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'VS',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      second.fullName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

class _CompareRow extends StatelessWidget {
  const _CompareRow(this.label, this.first, this.second);
  final String label;
  final String first;
  final String second;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 9),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
          child: Column(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      first,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'VS',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      second,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

class _ApiResultCard extends StatelessWidget {
  const _ApiResultCard({required this.data});

  final Map<String, dynamic> data;

  static const Map<String, String> labels = {
    'make': 'Merek',
    'model': 'Model',
    'year': 'Tahun produksi',
    'type': 'Jenis motor',
    'displacement': 'Kapasitas mesin',
    'engine': 'Tipe mesin',
    'power': 'Tenaga',
    'torque': 'Torsi',
    'fuel': 'Bahan bakar',
    'transmission': 'Transmisi',
    'cooling': 'Sistem pendingin',
    'weight': 'Berat',
    'seat_height': 'Tinggi jok',
    'fuel_capacity': 'Kapasitas tangki',
    'front_brakes': 'Rem depan',
    'rear_brakes': 'Rem belakang',
    'front_suspension': 'Suspensi depan',
    'rear_suspension': 'Suspensi belakang',
  };

  @override
  Widget build(BuildContext context) {
    final make = data['make']?.toString() ?? '';
    final model = data['model']?.toString() ?? '';
    final year = data['year']?.toString();
    final title = '$make $model'.trim();

    final details = labels.entries.where((entry) {
      final value = data[entry.key];
      return value != null && value.toString().trim().isNotEmpty;
    }).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 5,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
        leading: const Icon(
          Icons.two_wheeler_rounded,
          color: AppColors.orange,
        ),
        title: Text(
          title.isEmpty ? 'Data motor' : title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          year == null
              ? 'Tahun belum tersedia'
              : 'Tahun produksi $year',
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 11,
          ),
        ),
        children: [
          const Divider(color: AppColors.border),
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(bottom: 8, top: 5),
              child: Text(
                'Rincian spesifikasi API',
                style: TextStyle(
                  color: AppColors.orange,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          if (details.isEmpty)
            const Text(
              'Belum ada rincian spesifikasi pada hasil ini.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 12,
              ),
            )
          else
            ...details.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        data[entry.key].toString(),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          const _InfoNote(
            text: 'Hasil ini berasal dari pencarian API. Cocokkan model, '
                'tahun, dan variannya sebelum menjadikannya acuan.',
            warning: true,
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 38),
        child: Column(
          children: [
            Icon(icon, size: 45, color: AppColors.muted),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted,
                height: 1.5,
                fontSize: 12,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      );
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: CircularProgressIndicator(),
        ),
      );
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          message,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
}

class _InfoNote extends StatelessWidget {
  const _InfoNote({required this.text, this.warning = false});
  final String text;
  final bool warning;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: warning
              ? Colors.deepOrange.withValues(alpha: .09)
              : AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: warning
                ? Colors.deepOrange.withValues(alpha: .28)
                : AppColors.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              warning ? Icons.info_outline : Icons.verified_outlined,
              color: warning ? Colors.deepOrangeAccent : AppColors.orange,
              size: 17,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
}

String _orUnavailable(String? value) =>
    value == null || value.isEmpty ? 'Belum tersedia' : value;

String _number(double value) =>
    value == value.roundToDouble() ? value.toInt().toString() : value.toString();

String _rupiah(int value) =>
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
