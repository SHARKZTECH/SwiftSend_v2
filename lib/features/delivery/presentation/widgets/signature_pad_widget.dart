import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignaturePadWidget extends StatefulWidget {
  final Function(List<Point>)? onSignatureChanged;
  final double height;
  final Color penColor;
  final double strokeWidth;

  const SignaturePadWidget({
    super.key,
    this.onSignatureChanged,
    this.height = 200,
    this.penColor = Colors.black,
    this.strokeWidth = 3,
  });

  @override
  State<SignaturePadWidget> createState() => SignaturePadWidgetState();
}

class SignaturePadWidgetState extends State<SignaturePadWidget> {
  late SignatureController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: widget.strokeWidth,
      penColor: widget.penColor,
      exportBackgroundColor: Colors.white,
      onDrawStart: () => widget.onSignatureChanged?.call(_controller.points),
      onDrawEnd: () => widget.onSignatureChanged?.call(_controller.points),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void clear() {
    _controller.clear();
    widget.onSignatureChanged?.call([]);
  }

  bool get isEmpty => _controller.isEmpty;

  Future<dynamic> toImage() async {
    return await _controller.toPngBytes();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Stack(
              children: [
                Signature(
                  controller: _controller,
                  backgroundColor: Colors.white,
                ),
                // Signature line hint
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 40,
                  child: Container(
                    height: 1,
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                // X mark for signature
                Positioned(
                  left: 16,
                  bottom: 44,
                  child: Text(
                    'X',
                    style: TextStyle(
                      color: theme.colorScheme.outline.withOpacity(0.5),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Hint text
                if (_controller.isEmpty)
                  Center(
                    child: Text(
                      'Sign here',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: clear,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Clear'),
            ),
          ],
        ),
      ],
    );
  }
}
