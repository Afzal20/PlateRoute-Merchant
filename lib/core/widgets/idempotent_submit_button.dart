import 'package:flutter/material.dart';

class IdempotentSubmitButton extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onPressed;
  final ButtonStyle? style;

  const IdempotentSubmitButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.style,
  });

  @override
  State<IdempotentSubmitButton> createState() => _IdempotentSubmitButtonState();
}

class _IdempotentSubmitButtonState extends State<IdempotentSubmitButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onPressed();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: widget.style,
      onPressed: _isLoading ? null : _handlePress,
      child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: Colors.white,
              ),
            )
          : widget.child,
    );
  }
}
