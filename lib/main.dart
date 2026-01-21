import 'package:flutter/material.dart';
import 'package:nesui/component/nesui.dart';

void main() => runApp(const Demo());

class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        extensions: const [
          NesuiTheme(
            brand: Color(0xFF2563EB),
            onBrand: Colors.white,
            border: Color(0xFFE5E7EB),
            radius: 12,
          ),
        ],
      ),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NesuiButton(
                  fullWidth: true,
                  onPressed: () {},
                  child: const Text('Nesui Button'),
                ),
                const SizedBox(height: 12),
                NesuiButton(
                  fullWidth: true,
                  variant: NesuiButtonVariant.outline,
                  onPressed: () {},
                  child: const Text('Outline'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
