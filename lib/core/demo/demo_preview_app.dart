import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/price_text.dart';
import '../widgets/screen_state.dart';

class DemoPreviewApp extends StatefulWidget {
  const DemoPreviewApp({super.key});

  @override
  State<DemoPreviewApp> createState() => _DemoPreviewAppState();
}

class _DemoPreviewAppState extends State<DemoPreviewApp> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _darkMode = preferences.getBool('settings.darkMode') ?? false;
      _notificationsEnabled =
          preferences.getBool('settings.notificationsEnabled') ?? true;
    });
  }

  Future<void> _setPreference(String key, bool value) async {
    final saved = await (await SharedPreferences.getInstance()).setBool(
      key,
      value,
    );
    if (!saved) throw StateError('Could not save this preference.');
    if (!mounted) return;
    setState(() {
      if (key == 'settings.darkMode') {
        _darkMode = value;
      } else {
        _notificationsEnabled = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookHub Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      home: DemoPreviewShell(
        darkMode: _darkMode,
        notificationsEnabled: _notificationsEnabled,
        onDarkModeChanged: (value) =>
            _setPreference('settings.darkMode', value),
        onNotificationsChanged: (value) =>
            _setPreference('settings.notificationsEnabled', value),
      ),
    );
  }
}

class DemoPreviewShell extends StatefulWidget {
  const DemoPreviewShell({
    super.key,
    required this.darkMode,
    required this.notificationsEnabled,
    required this.onDarkModeChanged,
    required this.onNotificationsChanged,
  });

  final bool darkMode;
  final bool notificationsEnabled;
  final ValueChangedWithFuture<bool> onDarkModeChanged;
  final ValueChangedWithFuture<bool> onNotificationsChanged;

  @override
  State<DemoPreviewShell> createState() => _DemoPreviewShellState();
}

typedef ValueChangedWithFuture<T> = Future<void> Function(T value);

class _DemoPreviewShellState extends State<DemoPreviewShell> {
  static const _books = <_DemoBook>[
    _DemoBook(
      id: 'atomic-habits',
      title: 'Atomic Habits',
      author: 'James Clear',
      category: 'Self-help',
      price: 420,
      stock: 8,
      featured: true,
    ),
    _DemoBook(
      id: 'silent-patient',
      title: 'The Silent Patient',
      author: 'Alex Michaelides',
      category: 'Mystery',
      price: 350,
      stock: 5,
      featured: true,
    ),
    _DemoBook(
      id: 'great-gatsby',
      title: 'The Great Gatsby',
      author: 'F. Scott Fitzgerald',
      category: 'Classics',
      price: 280,
      stock: 12,
    ),
    _DemoBook(
      id: 'educated',
      title: 'Educated',
      author: 'Tara Westover',
      category: 'Memoir',
      price: 390,
      stock: 4,
    ),
    _DemoBook(
      id: 'dune',
      title: 'Dune',
      author: 'Frank Herbert',
      category: 'Science fiction',
      price: 475,
      stock: 6,
      featured: true,
    ),
    _DemoBook(
      id: 'little-prince',
      title: 'The Little Prince',
      author: 'Antoine de Saint-Exupery',
      category: 'Classics',
      price: 240,
      stock: 10,
    ),
    _DemoBook(
      id: 'deep-work',
      title: 'Deep Work',
      author: 'Cal Newport',
      category: 'Self-help',
      price: 430,
      stock: 3,
    ),
    _DemoBook(
      id: 'midnight-library',
      title: 'The Midnight Library',
      author: 'Matt Haig',
      category: 'Fiction',
      price: 365,
      stock: 7,
    ),
  ];

  final _categories = const [
    'All',
    'Fiction',
    'Mystery',
    'Classics',
    'Self-help',
    'Memoir',
    'Science fiction',
  ];
  final _cart = <String, int>{};
  final _libraryIds = <String>{'great-gatsby', 'little-prince'};
  int _selectedTab = 0;
  bool _showSettings = false;
  String _query = '';
  String _selectedCategory = 'All';
  String _fullName = 'BookHub Demo';
  String _phone = '';

  int get _cartCount => _cart.values.fold(0, (total, count) => total + count);

  List<_DemoBook> get _filteredBooks {
    final query = _query.trim().toLowerCase();
    final result = _books.where((book) {
      final matchesQuery =
          query.isEmpty ||
          book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query);
      final matchesCategory =
          _selectedCategory == 'All' || book.category == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();
    result.sort((first, second) => first.title.compareTo(second.title));
    return result;
  }

  void _addToCart(_DemoBook book) {
    final quantity = _cart[book.id] ?? 0;
    if (quantity >= book.stock) {
      _showMessage('No more copies are available in this demo.');
      return;
    }
    setState(() => _cart[book.id] = quantity + 1);
    _showMessage('${book.title} added to your demo cart.');
  }

  void _changeQuantity(_DemoBook book, int delta) {
    final quantity = (_cart[book.id] ?? 0) + delta;
    setState(() {
      if (quantity < 1) {
        _cart.remove(book.id);
      } else if (quantity <= book.stock) {
        _cart[book.id] = quantity;
      }
    });
  }

  Future<void> _showBookDetails(_DemoBook book) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _DemoBookCover(book: book, height: 190)),
              const SizedBox(height: AppSpacing.lg),
              Text(
                book.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(book.author),
              const SizedBox(height: AppSpacing.md),
              Text(
                '${book.category} · ${book.stock} copies in demo stock',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              PriceText(price: book.price),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: book.stock == 0
                      ? null
                      : () {
                          Navigator.pop(context);
                          _addToCart(book);
                        },
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  label: const Text('Add to cart'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkout() async {
    final subtotal = _cart.entries.fold<double>(
      0,
      (total, entry) =>
          total +
          _books.firstWhere((book) => book.id == entry.key).price * entry.value,
    );
    final orderedIds = _cart.keys.toSet();
    final placed = await showDialog<bool>(
      context: context,
      builder: (context) => _DemoCheckoutDialog(subtotal: subtotal),
    );
    if (placed != true || !mounted) return;

    setState(() {
      _libraryIds.addAll(orderedIds);
      _cart.clear();
    });
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: AppColors.teal, size: 44),
        title: const Text('Demo order confirmed'),
        content: Text(
          'Your demo order total is EGP ${(subtotal + 35).toStringAsFixed(2)}. '
          'The books were added to My Library locally.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _fullName);
    final phoneController = TextEditingController(text: _phone);
    final result = await showDialog<({String name, String phone})>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit demo profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, (
              name: nameController.text.trim(),
              phone: phoneController.text.trim(),
            )),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    nameController.dispose();
    phoneController.dispose();
    if (result == null || !mounted) return;
    if (result.name.isEmpty) {
      _showMessage('Full name cannot be empty.');
      return;
    }
    setState(() {
      _fullName = result.name;
      _phone = result.phone;
    });
  }

  Future<void> _saveDemoPreference(
    ValueChangedWithFuture<bool> save,
    bool value,
  ) async {
    try {
      await save(value);
    } catch (error) {
      _showMessage('Could not save the demo setting: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildCurrentPage() {
    if (_showSettings) return _buildSettings();
    return switch (_selectedTab) {
      0 => _buildHome(),
      1 => _buildSearch(),
      2 => _buildCart(),
      3 => _buildLibrary(),
      _ => _buildProfile(),
    };
  }

  Widget _buildHome() {
    final featured = _books.where((book) => book.featured).toList();
    final arrivals = _books.take(4).toList();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find your next great read',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Browse the local sample catalog. No Firebase connection needed.',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          readOnly: true,
          onTap: () => setState(() => _selectedTab = 1),
          decoration: const InputDecoration(
            hintText: 'Search books and authors',
            prefixIcon: Icon(Icons.search_rounded),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _DemoSectionHeading(
          title: 'Categories',
          action: TextButton(
            onPressed: () => setState(() => _selectedTab = 1),
            child: const Text('See all'),
          ),
        ),
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final category = _categories[index];
              return ChoiceChip(
                label: Text(category),
                selected: _selectedCategory == category,
                onSelected: (_) {
                  setState(() {
                    _selectedCategory = category;
                    _selectedTab = 1;
                  });
                },
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const _DemoSectionHeading(title: 'Featured'),
        SizedBox(
          height: 290,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: featured.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) => _DemoBookCard(
              book: featured[index],
              onTap: () => _showBookDetails(featured[index]),
              onAdd: () => _addToCart(featured[index]),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const _DemoSectionHeading(title: 'New arrivals'),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 900
                ? 4
                : constraints.maxWidth > 600
                ? 3
                : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: arrivals.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.63,
              ),
              itemBuilder: (context, index) => _DemoBookCard(
                book: arrivals[index],
                onTap: () => _showBookDetails(arrivals[index]),
                onAdd: () => _addToCart(arrivals[index]),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearch() {
    final books = _filteredBooks;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        TextField(
          autofocus: true,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: 'Search title or author',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    onPressed: () => setState(() => _query = ''),
                    icon: const Icon(Icons.clear_rounded),
                  ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final category = _categories[index];
              return ChoiceChip(
                label: Text(category),
                selected: _selectedCategory == category,
                onSelected: (_) => setState(() => _selectedCategory = category),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (books.isEmpty)
          const SizedBox(
            height: 220,
            child: ScreenState.empty(message: 'No books match your search.'),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 900
                  ? 4
                  : constraints.maxWidth > 600
                  ? 3
                  : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: books.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.63,
                ),
                itemBuilder: (context, index) => _DemoBookCard(
                  book: books[index],
                  onTap: () => _showBookDetails(books[index]),
                  onAdd: () => _addToCart(books[index]),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildCart() {
    final items = _cart.entries.toList();
    if (items.isEmpty) {
      return const ScreenState.empty(
        message: 'Your demo cart is empty. Add a book from Home or Search.',
      );
    }
    final subtotal = items.fold<double>(
      0,
      (total, entry) =>
          total +
          _books.firstWhere((book) => book.id == entry.key).price * entry.value,
    );
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final entry = items[index];
              final book = _books.firstWhere((book) => book.id == entry.key);
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 58,
                        height: 76,
                        child: _DemoBookCover(book: book, height: 76),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: const TextStyle(
                                color: AppColors.navy,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            PriceText(price: book.price),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Decrease',
                        onPressed: () => _changeQuantity(book, -1),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('${entry.value}'),
                      IconButton(
                        tooltip: 'Increase',
                        onPressed: () => _changeQuantity(book, 1),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              _DemoAmountRow(label: 'Subtotal', amount: subtotal),
              const SizedBox(height: AppSpacing.sm),
              const _DemoAmountRow(label: 'Delivery', amount: 35),
              const Divider(height: AppSpacing.xl),
              _DemoAmountRow(
                label: 'Total',
                amount: subtotal + 35,
                isTotal: true,
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _checkout,
                  child: const Text('Proceed to demo checkout'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLibrary() {
    final books = _books.where((book) => _libraryIds.contains(book.id)).toList()
      ..sort((first, second) => first.title.compareTo(second.title));
    if (books.isEmpty) {
      return const ScreenState.empty(
        message: 'Books in your demo orders appear here.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: books.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final book = books[index];
        return Card(
          child: ListTile(
            leading: SizedBox(
              width: 46,
              child: _DemoBookCover(book: book, height: 64),
            ),
            title: Text(book.title),
            subtitle: Text('By ${book.author} · Demo purchase'),
            trailing: const Icon(Icons.menu_book_rounded),
          ),
        );
      },
    );
  }

  Widget _buildProfile() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.actionBlue,
            child: Text(
              _fullName.isEmpty ? 'D' : _fullName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          _fullName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'demo@bookhub.local',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.phone_outlined),
                title: const Text('Phone'),
                subtitle: Text(_phone.isEmpty ? 'Not provided' : _phone),
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit profile'),
                onTap: _editProfile,
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                onTap: () => setState(() => _showSettings = true),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Profile photo'),
                subtitle: const Text('Upload is disabled in offline demo mode'),
                onTap: () => _showMessage(
                  'Photo upload needs Firebase Storage. This is a local preview.',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('Sign out'),
                onTap: () => _showMessage(
                  'The demo profile is local and is not signed in to Firebase.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettings() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Card(
          child: Column(
            children: [
              SwitchListTile.adaptive(
                title: const Text('Dark mode'),
                subtitle: const Text('Saved locally on this browser'),
                value: widget.darkMode,
                onChanged: (value) =>
                    _saveDemoPreference(widget.onDarkModeChanged, value),
              ),
              SwitchListTile.adaptive(
                title: const Text('Notifications'),
                subtitle: const Text('Saved locally on this browser'),
                value: widget.notificationsEnabled,
                onChanged: (value) =>
                    _saveDemoPreference(widget.onNotificationsChanged, value),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Card(
          child: ListTile(
            leading: const Icon(
              Icons.delete_forever_outlined,
              color: AppColors.error,
            ),
            title: const Text('Delete account'),
            subtitle: const Text('Unavailable in offline demo mode'),
            onTap: () => _showMessage(
              'No Firebase account exists to delete in demo mode.',
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _showSettings
        ? 'Settings'
        : switch (_selectedTab) {
            0 => 'BookHub',
            1 => 'Search',
            2 => 'My Cart',
            3 => 'My Library',
            _ => 'Profile',
          };
    return Scaffold(
      appBar: AppBar(
        leading: _showSettings
            ? IconButton(
                onPressed: () => setState(() => _showSettings = false),
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : null,
        title: Row(
          children: [
            Flexible(child: Text(title)),
            const SizedBox(width: AppSpacing.sm),
            const _DemoBadge(),
          ],
        ),
        actions: [
          if (_selectedTab != 2)
            IconButton(
              tooltip: 'Open cart',
              onPressed: () => setState(() {
                _showSettings = false;
                _selectedTab = 2;
              }),
              icon: Badge(
                isLabelVisible: _cartCount > 0,
                label: Text('$_cartCount'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: _buildCurrentPage(),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) {
          setState(() {
            _showSettings = false;
            _selectedTab = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _DemoCheckoutDialog extends StatefulWidget {
  const _DemoCheckoutDialog({required this.subtotal});

  final double subtotal;

  @override
  State<_DemoCheckoutDialog> createState() => _DemoCheckoutDialogState();
}

class _DemoCheckoutDialogState extends State<_DemoCheckoutDialog> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Demo checkout'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.local_shipping_outlined),
                  title: Text('Cash on Delivery (Demo)'),
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (value) => value == null || value.trim().length < 8
                      ? 'Enter a complete address.'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  validator: (value) {
                    final digits = (value ?? '').replaceAll(
                      RegExp(r'[^0-9]'),
                      '',
                    );
                    return digits.length < 7
                        ? 'Enter a valid phone number.'
                        : null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                _DemoAmountRow(label: 'Subtotal', amount: widget.subtotal),
                const _DemoAmountRow(label: 'Delivery', amount: 35),
                const Divider(),
                _DemoAmountRow(
                  label: 'Total',
                  amount: widget.subtotal + 35,
                  isTotal: true,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.pop(context, true);
            }
          },
          child: const Text('Confirm demo order'),
        ),
      ],
    );
  }
}

class _DemoBook {
  const _DemoBook({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.price,
    required this.stock,
    this.featured = false,
  });

  final String id;
  final String title;
  final String author;
  final String category;
  final double price;
  final int stock;
  final bool featured;
}

class _DemoBookCard extends StatelessWidget {
  const _DemoBookCard({
    required this.book,
    required this.onTap,
    required this.onAdd,
  });

  final _DemoBook book;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  child: _DemoBookCover(book: book, height: 160),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: onTap,
                child: Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                book.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              PriceText(price: book.price),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: onAdd,
                  child: const Text('Add to cart'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoBookCover extends StatelessWidget {
  const _DemoBookCover({required this.book, required this.height});

  final _DemoBook book;
  final double height;

  static const _colors = [
    Color(0xFF2563EB),
    Color(0xFF0F766E),
    Color(0xFF7C3AED),
    Color(0xFFB45309),
    Color(0xFFBE123C),
    Color(0xFF334155),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[book.id.hashCode.abs() % _colors.length];
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.72)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.menu_book_rounded, color: Colors.white, size: 32),
        ],
      ),
    );
  }
}

class _DemoSectionHeading extends StatelessWidget {
  const _DemoSectionHeading({required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

class _DemoAmountRow extends StatelessWidget {
  const _DemoAmountRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
  });

  final String label;
  final double amount;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? AppColors.navy : AppColors.textSecondary,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.normal,
          ),
        ),
        PriceText(
          price: amount,
          color: isTotal ? AppColors.navy : AppColors.textSecondary,
          fontSize: isTotal ? 18 : 14,
        ),
      ],
    );
  }
}

class _DemoBadge extends StatelessWidget {
  const _DemoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: const Text(
        'DEMO',
        style: TextStyle(
          color: AppColors.teal,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
