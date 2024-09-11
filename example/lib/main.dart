import 'package:flutter/material.dart';
import 'package:storyboard_flutter/storyboard_flutter.dart';

void main() {
  runApp(const MyApp());
}

/// {@template main}
/// MyApp widget.
/// {@endtemplate}
class MyApp extends StatelessWidget {
  /// {@macro main}
  const MyApp({
    super.key, // ignore: unused_element
  });

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.transparent,
            dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: RenderStoryboard(
            storyboard: Storyboard(
              plugins: [ParametersPlugin()],
              stories: [
                Story(
                  id: 'some-screen',
                  title: 'Some Screen',
                  children: [
                    Story(
                      id: 'shop-card',
                      title: 'Shop Card',
                      builder: (context) {
                        final parametersScope = ParametersScope.of(context);
                        return SizedBox(
                          width: 350,
                          child: ShopCard(
                            title: parametersScope.addParameter(
                              StringParameter(name: 'titled', value: 'Title'),
                            ),
                            price: parametersScope.addParameter(
                              DoubleParameter(name: 'price', value: 10),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
}

class ShopCard extends StatefulWidget {
  final String title;
  final double price;

  const ShopCard({
    super.key,
    required this.title,
    required this.price,
  });

  @override
  ShopCardState createState() => ShopCardState();
}

class ShopCardState extends State<ShopCard> {
  int _count = 0;

  void _incrementCount() {
    setState(() {
      _count++;
    });
  }

  void _decrementCount() {
    setState(() {
      if (_count > 0) _count--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '\$${widget.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _decrementCount,
                    ),
                    Text(
                      '$_count',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _incrementCount,
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add to cart logic here
                  },
                  child: const Text('Add to Cart'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
