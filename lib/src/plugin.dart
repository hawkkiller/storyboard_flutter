import 'package:flutter/widgets.dart';

typedef ChildBuilder = Widget Function(BuildContext context, Widget child);

/// Plugin that can be added to the storyboard.
abstract class Plugin {
  /// Creates a new plugin.
  const Plugin({
    required this.name,
    required this.description,
  });

  /// Name of the plugin.
  final String name;

  /// Description of the plugin.
  final String description;

  /// Optionally wrap the story with a widget.
  /// 
  /// This [BuildContext] is the parent for both the panel, the sidebar and the story.
  /// 
  /// For example, to add device frame around the story or 
  /// make window resizable.
  ChildBuilder? get storyboardWrapper => null;

  /// Builds the widget for panel.
  /// 
  /// This can be used to add parameters panel for the story.
  WidgetBuilder? get panelBuilder => null;
}
