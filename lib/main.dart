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
      home: const WebViewHome(),
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
  bool _isLoading = true;
  String _errorMessage = '';

  final List<String> _urls = [
    'https://koran-pariwisata.com/',
    'https://www.cnnindonesia.com/tag/pariwisata',
    'https://www.metrotvnews.com/tag/808/pariwisata-indonesia',
  ];

  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _errorMessage = '';
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _errorMessage = 'Error: ${error.description}';
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_urls[_selectedIndex]));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isLoading = true;
      _errorMessage = '';
      if (index < _urls.length) {
        _controller.loadRequest(Uri.parse(_urls[_selectedIndex]));
      }
    });
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
              _controller.reload();
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
                      _controller.reload();
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          else
            WebViewWidget(controller: _controller),
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
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.email, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: SelectableText(
                            'info.beritapariwisata@smkbaknus666.sch.id',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        SelectableText(
                          '+62-21-1234-5666',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.school, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'SMK Baknus 666, Jakarta',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
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
        label: const Text('CONTACT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        centerTitle: true,
      ),
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
                        Icon(Icons.contact_phone, color: Colors.green, size: 28),
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
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
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
              
              const Text(
                'Aplikasi ini dirancang khusus untuk memberikan akses mudah ke berita dan informasi '
                'terkini seputar pariwisata Indonesia. Koran Pariwisata menjadi sumber utama yang '
                'menyajikan berita terpercaya tentang industri pariwisata.\n\n'
                'Untuk melengkapi perspektif berita pariwisata, aplikasi ini juga menyediakan akses ke '
                'portal berita nasional lainnya yang membahas topik pariwisata, seperti CNN Indonesia '
                'dan MetroTV News.\n\n'
                'Disclaimer: Kami bukan pemilik resmi dari konten yang ditampilkan. Semua hak cipta '
                'dan merek dagang tetap menjadi milik masing-masing pemilik situs. Aplikasi ini '
                'bertujuan sebagai agregator untuk kemudahan akses informasi pariwisata.',
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
                      'Kontak Developer:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text('Email: info.beritapariwisata@smkbaknus666.sch.id'),
                    const Text('Telepon: +62-21-1234-5666'),
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
                              fontWeight: i == 0 ? FontWeight.bold : FontWeight.normal,
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
