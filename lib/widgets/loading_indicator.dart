import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final bool mini;
  const LoadingIndicator({super.key, this.mini = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: mini
          ? const SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Loading news...',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
    );
  }
}