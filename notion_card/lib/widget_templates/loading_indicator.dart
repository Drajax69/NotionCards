import 'package:flutter/material.dart';

class LoadingIndicator extends StatefulWidget {
  final List<Image> images;
  final String text;

  const LoadingIndicator({super.key, required this.images, required this.text});

  @override
  State<LoadingIndicator> createState() => _CustomProgressIndicatorState();
}

class _CustomProgressIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _controller.addListener(() {
      setState(() {
        _currentImageIndex = (_controller.value * widget.images.length).floor();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return const CircularProgressIndicator();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        widget.images[_currentImageIndex],
        const SizedBox(height: 20),
        Text(
          widget.text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
