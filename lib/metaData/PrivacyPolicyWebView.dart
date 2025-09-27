import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyWebView extends StatefulWidget {
  const PrivacyPolicyWebView({
    super.key,
    this.url = 'https://dealzyloop.com/privacy-policy-seller.html',
    this.title = 'Privacy Policy',
  });

  final String url;
  final String title;

  @override
  State<PrivacyPolicyWebView> createState() => _PrivacyPolicyWebViewState();
}

class _PrivacyPolicyWebViewState extends State<PrivacyPolicyWebView> {
  late final WebViewController _controller;
  double _progress = 0;
  bool _isLoading = true;
  WebResourceError? _lastError;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white) // avoid full transparency issues
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => setState(() => _progress = p / 100.0),
          onPageStarted: (_) => setState(() {
            _isLoading = true;
            _lastError = null;
          }),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (error) {
            // capture and show error
            setState(() {
              _lastError = error;
              _isLoading = false;
            });
          },
          onNavigationRequest: (req) {
            // Let everything navigate inside the webview by default
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _reload() async {
    setState(() {
      _isLoading = true;
      _lastError = null;
      _progress = 0;
    });
    await _controller.reload();
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open in browser')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final showError = _lastError != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Open in browser',
            onPressed: _openInBrowser,
            icon: const Icon(Icons.open_in_new),
          ),
          IconButton(
            tooltip: 'Reload',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          // WebView
          if (!showError) WebViewWidget(controller: _controller),

          // Top progress bar
          if (!showError && _progress < 1.0)
            const Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(minHeight: 2),
            ),

          // Centered preloader
          if (!showError && _isLoading)
            const Center(child: CircularProgressIndicator()),

          // Error state
          if (showError)
            _ErrorView(
              error: _lastError!,
              onRetry: _reload,
              onOpenInBrowser: _openInBrowser,
            ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.error,
    required this.onRetry,
    required this.onOpenInBrowser,
  });

  final WebResourceError error;
  final VoidCallback onRetry;
  final VoidCallback onOpenInBrowser;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.public_off, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text('Failed to load page', style: style.titleMedium),
            const SizedBox(height: 8),
            Text(
              '(${error.errorCode}) ${error.description}',
              style: style.bodySmall?.copyWith(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [
                FilledButton(onPressed: onRetry, child: const Text('Retry')),
                OutlinedButton(
                  onPressed: onOpenInBrowser,
                  child: const Text('Open in browser'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
