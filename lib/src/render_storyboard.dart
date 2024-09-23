import 'dart:async';

import 'package:flutter/material.dart';
import 'package:storyboard_flutter/src/plugin.dart';
import 'package:storyboard_flutter/src/storyboard.dart';
import 'package:storyboard_flutter/storyboard_flutter.dart';

/// {@template render_storyboard}
/// Widget that renders the provided [storyboard].
/// {@endtemplate}
class RenderStoryboard extends StatefulWidget {
  /// {@macro render_storyboard}
  const RenderStoryboard({
    required this.storyboard,
    super.key,
  });

  /// Storyboard to render.
  final Storyboard storyboard;

  @override
  State<RenderStoryboard> createState() => _RenderStoryboardState();
}

class _RenderStoryboardState extends State<RenderStoryboard> {
  @override
  Widget build(BuildContext context) => StoryNotifier(
        storyboard: widget.storyboard,
        child: ParametersScope(
          child: _StoryboardWrappers(
            plugins: widget.storyboard.plugins,
            child: _RenderStoryboard(storyboard: widget.storyboard),
          ),
        ),
      );
}

/// {@template render_storyboard}
/// _RenderStoryboard widget.
/// {@endtemplate}
class _RenderStoryboard extends StatefulWidget {
  /// {@macro render_storyboard}
  const _RenderStoryboard({
    required this.storyboard,
    super.key, // ignore: unused_element
  });

  final Storyboard storyboard;

  @override
  State<_RenderStoryboard> createState() => __RenderStoryboardState();
}

class __RenderStoryboardState extends State<_RenderStoryboard> {
  late var storyNotifier = StoryNotifier.of(context);

  void onStorySelected(Story story) => storyNotifier.setActiveStory(story);

  @override
  Widget build(BuildContext context) {
    final activeStory = storyNotifier.activeStory;
    return Row(
      children: [
        StoriesVerticalList(
          stories: widget.storyboard.stories,
          onStorySelected: onStorySelected,
          activeStory: activeStory,
        ),
        Expanded(
          flex: 3,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                if (activeStory == null) {
                  return const SizedBox.shrink();
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        activeStory.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: activeStory.builder!(context),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        OptionsSidebar(storyboard: widget.storyboard, activeStory: activeStory),
      ],
    );
  }
}

class OptionsSidebar extends StatelessWidget {
  const OptionsSidebar({
    super.key,
    required this.storyboard,
    required this.activeStory,
  });

  final Storyboard storyboard;
  final Story? activeStory;

  @override
  Widget build(BuildContext context) => Material(
        elevation: 2,
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: SizedBox(
          width: 250,
          height: double.infinity,
          child: Column(
            children: [
              if (activeStory != null) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _Parameters(activeStory: activeStory!),
                ),
                const Divider(),
              ],
              for (final plugin in storyboard.plugins)
                if (plugin.panelBuilder != null) ...[
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: plugin.panelBuilder!(context),
                  ),
                ],
            ],
          ),
        ),
      );
}

/// {@template render_storyboard}
/// _Parameters widget.
/// {@endtemplate}
class _Parameters extends StatelessWidget {
  /// {@macro render_storyboard}
  const _Parameters({
    super.key, // ignore: unused_element
    required this.activeStory,
  });

  final Story activeStory;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Parameters', style: TextStyle(fontWeight: FontWeight.bold)),
          for (final parameter in activeStory.parameters)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: parameter.build(
                context,
                onChanged: (value) => context.parameters.updateParameterValue(
                  storyId: activeStory.id,
                  parameterName: parameter.name,
                  value: value,
                ),
              ),
            ),
        ],
      );
}

/// {@template storyboard_wrappers}
/// _StoryboardWrappers widget.
/// {@endtemplate}
class _StoryboardWrappers extends StatelessWidget {
  /// {@macro storyboard_wrappers}
  const _StoryboardWrappers({
    required this.plugins,
    required this.child,
  });

  final List<Plugin> plugins;
  final Widget child;

  @override
  Widget build(BuildContext context) => plugins.fold(child, (child, plugin) {
        final wrapper = plugin.storyboardWrapper;

        if (wrapper == null) {
          return child;
        }

        return wrapper(context, child);
      });
}

/// {@template stories_list}
/// Widget that renders the provided [stories] in a tree view.
/// {@endtemplate}
class StoriesVerticalList extends StatefulWidget {
  /// {@macro stories_list}
  const StoriesVerticalList({
    required this.stories,
    required this.onStorySelected,
    required this.activeStory,
    super.key,
  });

  /// List of stories.
  final List<Story> stories;

  /// Callback when a story is selected.
  final ValueChanged<Story> onStorySelected;

  /// Active story.
  final Story? activeStory;

  @override
  State<StoriesVerticalList> createState() => _StoriesVerticalListState();
}

class _StoriesVerticalListState extends State<StoriesVerticalList> {
  double width = 200;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          SizedBox(
            width: width,
            child: Material(
              elevation: 2,
              color: Theme.of(context).colorScheme.surfaceContainer,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: widget.stories.length,
                itemBuilder: (context, index) => _StoryTile(
                  story: widget.stories[index],
                  activeStory: widget.activeStory,
                  onStorySelected: widget.onStorySelected,
                  isRoot: true,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            top: 0,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    width = (width + details.primaryDelta!).clamp(200.0, 400.0);
                  });
                },
                child: const SizedBox(
                  height: double.infinity,
                  width: 4,
                  child: ColoredBox(color: Colors.transparent),
                ),
              ),
            ),
          ),
        ],
      );
}

/// {@template expansion_tile}
/// _ExpansionTile widget.
/// {@endtemplate}
class _StoryTile extends StatefulWidget {
  /// {@macro expansion_tile}
  const _StoryTile({
    // ignore: unused_element
    super.key,
    required this.story,
    required this.activeStory,
    required this.onStorySelected,
    this.isRoot = false,
    this.nestingLevel = 0,
  });

  /// Story to render.
  final Story story;

  /// Active story.
  final Story? activeStory;

  /// Whether the tile is root.
  final bool isRoot;

  /// Nesting level.
  final int nestingLevel;

  /// Callback when a story is selected.
  final ValueChanged<Story> onStorySelected;

  @override
  State<_StoryTile> createState() => _StoryTileState();
}

class _StoryTileState extends State<_StoryTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    final children = story.children;
    final isLeaf = children.isEmpty;

    final isSelected = story == widget.activeStory;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          dense: true,
          tileColor: isSelected ? Theme.of(context).colorScheme.surfaceContainerHighest : null,
          title: Text(story.title),
          contentPadding: const EdgeInsets.only(left: 8, right: 8),
          leading: Padding(
            padding: EdgeInsets.only(left: 8.0 * widget.nestingLevel),
            child:
                isLeaf ? const Icon(Icons.insert_drive_file_outlined) : const Icon(Icons.folder_open_rounded),
          ),
          trailing: isLeaf ? null : Icon(_isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded),
          onTap: () {
            if (!isLeaf) {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            } else {
              widget.onStorySelected(story);
            }
          },
        ),
        if (_isExpanded)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final child in children)
                _StoryTile(
                  story: child,
                  activeStory: widget.activeStory,
                  onStorySelected: widget.onStorySelected,
                  nestingLevel: widget.nestingLevel + 1,
                ),
            ],
          ),
      ],
    );
  }
}

/// {@template story_notifier}
/// StoryNotifier widget.
/// {@endtemplate}
class StoryNotifier extends StatefulWidget {
  /// {@macro story_notifier}
  const StoryNotifier({
    required this.storyboard,
    required this.child,
    super.key,
  });

  final Storyboard storyboard;

  /// Child widget.
  final Widget child;

  /// Get the state of StoryNotifier.
  static StoryNotifierState of(BuildContext context, {bool listen = true}) {
    final notifier = listen
        ? context.dependOnInheritedWidgetOfExactType<_StoryNotifierInherited>()
        : context.getInheritedWidgetOfExactType<_StoryNotifierInherited>();

    return notifier!.state;
  }

  @override
  State<StoryNotifier> createState() => StoryNotifierState();
}

/// State for widget StoryNotifier.
class StoryNotifierState extends State<StoryNotifier> {
  String? _storyId;

  Story? get activeStory {
    final activeId = _storyId;

    if (activeId == null) {
      return null;
    }

    for (final story in widget.storyboard.getAllStoriesUnordered()) {
      if (story.id == activeId) {
        return story;
      }
    }

    return null;
  }

  /// Set active story.
  void setActiveStory(Story story) {
    scheduleMicrotask(() {
      setState(() {
        _storyId = story.id;
      });
    });
  }

  @override
  Widget build(BuildContext context) => _StoryNotifierInherited(
        storyId: _storyId,
        state: this,
        child: widget.child,
      );
}

/// {@template story_notifier_inherited}
/// _StoryNotifierInherited widget.
/// {@endtemplate}
class _StoryNotifierInherited extends InheritedWidget {
  /// {@macro story_notifier_inherited}
  const _StoryNotifierInherited({
    required this.storyId,
    required this.state,
    required super.child,
    super.key, // ignore: unused_element
  });

  final String? storyId;
  final StoryNotifierState state;

  @override
  bool updateShouldNotify(covariant _StoryNotifierInherited oldWidget) => storyId != oldWidget.storyId;
}
