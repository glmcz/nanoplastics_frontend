import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/app_colors.dart';
import '../services/logger_service.dart';
import '../services/web_link_cache_service.dart';
import '../utils/app_theme_colors.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  int _loadingProgress = 0; // 0–100, 100 = done
  bool _hasError = false;
  bool _pageStarted = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    try {
      final normalizedUrl = _normalizeUrl(widget.url);
      LoggerService().logDebug(
          'WebViewInit', 'Loading: $normalizedUrl (original: ${widget.url})');

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFF0A0A12))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (url) {
              LoggerService()
                  .logDebug('WebViewPageStarted', 'Page started loading: $url');
              if (mounted) {
                setState(() {
                  _pageStarted = true;
                  _hasError = false;
                  _loadingProgress = 0;
                });
              }
            },
            onProgress: (p) {
              if (mounted) {
                setState(() => _loadingProgress = p);
              }
            },
            onPageFinished: (url) {
              LoggerService()
                  .logDebug('WebViewPageFinished', 'Page finished: $url');
              if (mounted) {
                setState(() => _loadingProgress = 100);
              }
              // Mark visited so the source card shows the offline indicator
              WebLinkCacheService().markVisited(widget.url);
            },
            onWebResourceError: (error) {
              // Resource errors are common (images, stylesheets, scripts failing)
              // Only log them, don't fail the entire page
              if (!error.description.contains('channel-error') &&
                  !error.description.contains('unregistered type')) {
                LoggerService().logDebug('WebViewResourceError',
                    'Resource failed: ${error.url} - ${error.description}');
              }
              // Don't set _hasError here - resources can fail while page still loads
            },
          ),
        );
      await _controller.loadRequest(Uri.parse(normalizedUrl));

      // If page doesn't start loading within 15 seconds, show error
      Future.delayed(const Duration(seconds: 15), () {
        if (mounted && !_pageStarted) {
          LoggerService().logError(
              'WebViewLoadTimeout',
              'Page did not start loading after 15 seconds',
              StackTrace.current);
          setState(() => _hasError = true);
        }
      });
    } catch (e, st) {
      // Suppress emulator/platform channel errors in non-fatal logs
      if (!e.toString().contains('channel-error')) {
        LoggerService()
            .logError('WebViewInit', 'Init error: ${e.toString()}', st);
      }
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  /// Normalize YouTube short links to full URLs for better WebView support
  String _normalizeUrl(String url) {
    if (url.contains('youtu.be')) {
      // youtu.be/VIDEO_ID → youtube.com/embed/VIDEO_ID
      final videoId = url.split('/').last.split('?').first;
      return 'https://www.youtube.com/embed/$videoId';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppThemeColors.of(context).cardBackground;

    return Scaffold(
      backgroundColor: AppThemeColors.of(context).gradientEnd,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: Semantics(
          button: true,
          label: 'Back',
          child: InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            child: const SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Icon(Icons.arrow_back_ios,
                  color: AppColors.pastelAqua, size: 20),
            ),
          ),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Refresh page',
            child: InkWell(
              onTap: () {
                setState(() {
                  _hasError = false;
                  _loadingProgress = 0;
                });
                _controller.reload();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child:
                    Icon(Icons.refresh, color: AppColors.pastelAqua, size: 20),
              ),
            ),
          ),
        ],
        bottom: _loadingProgress < 100
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(
                  value: _loadingProgress / 100,
                  backgroundColor: Colors.transparent,
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.pastelAqua),
                ),
              )
            : null,
      ),
      body: _hasError
          ? _buildErrorView()
          : WebViewWidget(controller: _controller),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: AppColors.pastelAqua),
            const SizedBox(height: 16),
            const Text(
              'No connection',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Open this page while online to cache it for offline use.',
              style: TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () {
                setState(() {
                  _hasError = false;
                  _loadingProgress = 0;
                });
                _controller.reload();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppColors.pastelAqua.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Retry',
                    style: TextStyle(color: AppColors.pastelAqua)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
