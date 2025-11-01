import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const BeritaPariwisataApp());
}

class BeritaPariwisataApp extends StatelessWidget {
  const BeritaPariwisataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Koran Pariwisata Indonesia',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.amber,
          elevation: 2,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.amber,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    // Navigate to main app after splash
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const WebViewHome(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber, width: 2),
                ),
                child: const Icon(
                  Icons.newspaper,
                  size: 80,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Koran Pariwisata Indonesia',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Portal Berita Pariwisata Terdepan',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: const Text(
                  'NEWS AGGREGATOR',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WebViewHome extends StatefulWidget {
  const WebViewHome({super.key});

  @override
  State<WebViewHome> createState() => _WebViewHomeState();
}

class _WebViewHomeState extends State<WebViewHome> {
  int _selectedIndex = 0;
  bool _isLoading = false; // Start with false for faster launch
  String _errorMessage = '';
  bool _webViewInitialized = false;

  final List<String> _urls = [
    'https://koran-pariwisata.com/',
    'https://www.cnnindonesia.com/tag/pariwisata',
    'https://www.metrotvnews.com/tag/808/pariwisata-indonesia',
  ];

  WebViewController? _controller; // Make nullable for lazy init

  @override
  void initState() {
    super.initState();
    // Delay WebView initialization for faster launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWebView();
    });
  }

  void _initializeWebView() {
    if (_webViewInitialized) return;

    setState(() {
      _isLoading = true;
    });

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _errorMessage = '';
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onHttpError: (HttpResponseError error) {
            if (mounted) {
              setState(() {
                _errorMessage =
                    'Error loading page: ${error.response?.statusCode}';
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _errorMessage = 'Error: ${error.description}';
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_urls[_selectedIndex]));

    _webViewInitialized = true;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _errorMessage = '';
    });

    if (!_webViewInitialized) {
      _initializeWebView();
    } else if (_controller != null && index < _urls.length) {
      setState(() {
        _isLoading = true;
      });
      _controller!.loadRequest(Uri.parse(_urls[_selectedIndex]));
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    String currentSiteName = _selectedIndex == 0
        ? 'Koran Pariwisata'
        : _selectedIndex == 1
        ? 'CNN Indonesia'
        : 'MetroTV News';

    return Scaffold(
      appBar: AppBar(
        title: Text(currentSiteName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_controller != null) {
                _controller!.reload();
              } else {
                _initializeWebView();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutPage(urls: _urls)),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // NEWS AGGREGATOR BANNER
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'NEWS AGGREGATOR • Content dari ${_selectedIndex == 0
                          ? "Koran Pariwisata"
                          : _selectedIndex == 1
                          ? "CNN Indonesia"
                          : "MetroTV News"} • Live Updated',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    _getCurrentTime(),
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          if (_errorMessage.isNotEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_controller != null) {
                        _controller!.reload();
                      } else {
                        _initializeWebView();
                      }
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          else if (_controller != null)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: WebViewWidget(controller: _controller!),
            )
          else
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.newspaper, size: 64, color: Colors.amber),
                    SizedBox(height: 16),
                    Text(
                      'Koran Pariwisata Indonesia',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap navigasi untuk mulai membaca berita',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 28),
            label: 'Koran Pariwisata',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public, size: 24),
            label: 'CNN Indonesia',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.travel_explore, size: 24),
            label: 'MetroTV News',
            backgroundColor: Colors.black,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.contact_phone, color: Colors.green),
                    SizedBox(width: 8),
                    Text('HUBUNGI KAMI'),
                  ],
                ),
                content: const SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EDITOR ADDRESS:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Koran Pariwisata\nJl. Kembang III – No. 64\nKwitang – Tugu Tani\nJAKARTA PUSAT\nINDONESIA',
                        style: TextStyle(fontSize: 13),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.phone, color: Colors.green, size: 18),
                          SizedBox(width: 8),
                          SelectableText(
                            '+6285182828181',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.email, color: Colors.green, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: SelectableText(
                              'admin@koran-pariwisata.com',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'BUSINESS OFFICE:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'PT. EKA WIRA INDONESIA\nJl. Asia Afrika, Braga, Sumur Bandung 004/006\nBANDUNG – WEST JAVA\nINDONESIA',
                        style: TextStyle(fontSize: 13),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.email, color: Colors.green, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: SelectableText(
                              'ceo@koran-pariwisata.com',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Tutup'),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Colors.green,
        icon: const Icon(Icons.contact_phone, color: Colors.white),
        label: const Text(
          'CONTACT',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  final List<String> urls;

  const AboutPage({super.key, required this.urls});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Aplikasi'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.newspaper, size: 64, color: Colors.amber),
                    SizedBox(height: 16),
                    Text(
                      'Koran Pariwisata Indonesia',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Portal Berita Pariwisata Terdepan',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // CONTACT INFORMATION - VERY PROMINENT
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.contact_phone,
                          color: Colors.green,
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'HUBUNGI KAMI',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.email, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SelectableText(
                                  'info.beritapariwisata@smkbaknus666.sch.id',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.phone, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SelectableText(
                                  '+62-21-1234-5666',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.school, color: Colors.green),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'SMK Baknus 666, Jakarta',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // NEWS AGGREGATOR DECLARATION - PROMINENT
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange, width: 2),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: Colors.orange,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'PEMBERITAHUAN AGREGATOR BERITA',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Aplikasi ini adalah NEWS AGGREGATOR yang mengumpulkan dan menampilkan berita dari berbagai sumber terpercaya. Kami BUKAN pemilik konten dan TIDAK memproduksi berita sendiri.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const Text(
                'Aplikasi ini dirancang khusus untuk memberikan akses mudah ke berita dan informasi '
                'terkini seputar pariwisata Indonesia. Koran Pariwisata menjadi sumber utama yang '
                'menyajikan berita terpercaya tentang industri pariwisata.\n\n'
                'Untuk melengkapi perspektif berita pariwisata, aplikasi ini juga menyediakan akses ke '
                'portal berita nasional lainnya yang membahas topik pariwisata, seperti CNN Indonesia '
                'dan MetroTV News.',
                style: TextStyle(fontSize: 16, height: 1.6),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 24),
              // Content Freshness & Source Disclaimer
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Informasi Konten:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Konten berita diperbarui secara real-time dari sumber asli\n'
                      '• Semua artikel menampilkan timestamp publikasi dari penerbit\n'
                      '• Aplikasi ini hanya menampilkan konten, bukan pemilik konten\n'
                      '• Hak cipta sepenuhnya milik penerbit masing-masing',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'EDITOR ADDRESS:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Koran Pariwisata\n'
                      'Jl. Kembang III – No. 64\n'
                      'Kwitang – Tugu Tani\n'
                      'JAKARTA PUSAT, INDONESIA',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    const Text('Hotline: +6285182828181'),
                    const Text('Email: admin@koran-pariwisata.com'),
                    const SizedBox(height: 12),
                    const Text(
                      'BUSINESS OFFICE:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'PT. EKA WIRA INDONESIA\n'
                      'Jl. Asia Afrika, Braga, Sumur Bandung 004/006\n'
                      'BANDUNG – WEST JAVA, INDONESIA',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    const Text('Email: ceo@koran-pariwisata.com'),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.source, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          'Sumber Berita:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (int i = 0; i < urls.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            i == 0 ? Icons.home : Icons.link,
                            color: i == 0 ? Colors.amber : Colors.grey,
                          ),
                          title: Text(
                            urls[i],
                            style: TextStyle(
                              fontWeight: i == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: i == 0 ? Colors.amber : Colors.black87,
                            ),
                          ),
                          subtitle: i == 0
                              ? const Text(
                                  'Situs Utama',
                                  style: TextStyle(
                                    color: Colors.amber,
                                    fontStyle: FontStyle.italic,
                                  ),
                                )
                              : null,
                          onTap: () => _launchUrl(urls[i]),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
