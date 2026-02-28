import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_colors.dart';

/// Stateful page input widget for PDF viewer
/// Manages its own TextEditingController lifecycle
class PdfPageInput extends StatefulWidget {
  final int currentPage;
  final ValueChanged<String> onPageSubmitted;

  const PdfPageInput({
    super.key,
    required this.currentPage,
    required this.onPageSubmitted,
  });

  @override
  State<PdfPageInput> createState() => _PdfPageInputState();
}

class _PdfPageInputState extends State<PdfPageInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.currentPage}');
  }

  @override
  void didUpdateWidget(PdfPageInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage) {
      _controller.text = '${widget.currentPage}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: TextField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onSubmitted: widget.onPageSubmitted,
        controller: _controller,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.pastelAqua,
            ),
        decoration: InputDecoration(
          prefix: Text(
            'p. ',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.pastelAqua,
                ),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        ),
      ),
    );
  }
}
