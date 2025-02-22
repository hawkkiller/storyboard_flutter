import 'package:flutter/widgets.dart';
import 'package:storyboard_flutter/src/plugin.dart';

/// Storyboard is a collection of all stories.
class Storyboard {
  Storyboard({
    required this.stories,
    this.plugins = const [],
  }) {
    final allStories = getAllStories();

    // verify that all stories have unique ids
    final storyIds = allStories.map((story) => story.id).toSet();

    if (storyIds.length != allStories.length) {
      throw Exception(
        'Identifiers of stories must be unique. However, there are duplicates.',
      );
    }
  }

  /// List of stories.
  final List<Story> stories;

  /// List of plugins.
  final List<Plugin> plugins;

  /// Returns all stories, including nested ones.
  List<Story> getAllStories() {
    List<Story> allStories = [];
    List<Story> storiesToProcess = List.from(stories);

    while (storiesToProcess.isNotEmpty) {
      Story currentStory = storiesToProcess.removeLast();
      allStories.add(currentStory);

      // Add children to the list of stories to process
      storiesToProcess.addAll(currentStory.children.reversed);
    }

    return allStories;
  }
}

/// Story is the smallest piece of the Storyboard.
///
/// It can be used to represent a single screen or a single component.
/// It can have children stories to represent a screen with multiple components.
class Story {
  Story({
    required this.id,
    required this.title,
    this.builder,
    this.children = const [],
  });

  /// Unique identifier of the story.
  final String id;

  /// Title of the story.
  ///
  /// For example, "Login Screen", "Button", "Text Field".
  final String title;

  /// Builder function that returns the widget to be rendered.
  ///
  /// If this is null, then this is considered as a folder.
  final WidgetBuilder? builder;

  /// Children stories.
  final List<Story> children;

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  // ignore: unnecessary_overrides
  int get hashCode => super.hashCode;
}
