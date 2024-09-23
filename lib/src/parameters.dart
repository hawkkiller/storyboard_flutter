import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:storyboard_flutter/storyboard_flutter.dart';

/// {@template parameters_scope}
/// ParametersScope widget.
/// {@endtemplate}
class ParametersScope extends StatefulWidget {
  /// {@macro parameters_scope}
  const ParametersScope({
    required this.child,
    super.key,
  });

  final Widget child;

  /// Obtain [ParametersScopeState] from [context].
  static ParametersScopeState of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<_InheritedParameters>();
    if (result == null) {
      throw Exception('No $ParametersScope found in context');
    }
    return result.state;
  }

  @override
  State<ParametersScope> createState() => ParametersScopeState();
}

/// State for widget ParametersScope.
class ParametersScopeState extends State<ParametersScope> {
  /// Story id -> {parameter name -> parameter value}
  var _storiesParams = <String, Map<String, Object?>>{};

  @override
  void didChangeDependencies() {
    final story = StoryNotifier.of(context).activeStory;

    if (story != null && _storiesParams.containsKey(story.id) == false) {
      _storiesParams = {
        story.id: Map.fromEntries(
          story.parameters.map(
            (parameter) => MapEntry(
              parameter.name,
              parameter.initialValue,
            ),
          ),
        ),
      };
    }

    super.didChangeDependencies();
  }

  void updateParameterValue<T extends Object?>({
    required String storyId,
    required String parameterName,
    required T value,
  }) =>
      setState(
        () => _storiesParams = {
          ..._storiesParams,
          storyId: {
            ...(_storiesParams[storyId] ?? const {}),
            parameterName: value,
          },
        },
      );

  /// Get parameter value.
  T getParameterValue<T extends Object?>(String parameterName, {String? storyId}) {
    final activeStory = storyId ?? StoryNotifier.of(context, listen: false).activeStory?.id;

    return _storiesParams[activeStory]?[parameterName] as T;
  }

  @override
  Widget build(BuildContext context) => _InheritedParameters(
        state: this,
        storiesParams: _storiesParams,
        child: widget.child,
      );
}

/// {@template inherited_parameters}
/// _InheritedParameters widget.
/// {@endtemplate}
class _InheritedParameters extends InheritedWidget {
  /// {@macro inherited_parameters}
  const _InheritedParameters({
    required super.child,
    required this.state,
    required this.storiesParams,
    super.key, // ignore: unused_element
  });

  final ParametersScopeState state;
  final Map<String, Map<String, Object?>> storiesParams;

  @override
  bool updateShouldNotify(covariant _InheritedParameters oldWidget) => !mapEquals(
        storiesParams,
        oldWidget.storiesParams,
      );
}

extension ParametersExtension on BuildContext {
  /// Get parameters scope.
  ParametersScopeState get parameters => ParametersScope.of(this);
}

abstract class Parameter<T> {
  const Parameter({required this.name, required this.initialValue});

  final String name;
  final T initialValue;

  Widget build(BuildContext context, {required ValueChanged<T> onChanged});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Parameter<T> &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          initialValue == other.initialValue;

  @override
  int get hashCode => name.hashCode ^ initialValue.hashCode;
}

class StringParameter extends Parameter<String> {
  StringParameter({required super.name, required super.initialValue});

  @override
  Widget build(BuildContext context, {required ValueChanged<String> onChanged}) => TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        decoration: InputDecoration(labelText: name),
      );
}

class DoubleParameter extends Parameter<double> {
  DoubleParameter({
    required super.name,
    required super.initialValue,
    this.min = 0,
    this.max = 100,
  });

  final double min;
  final double max;

  @override
  Widget build(
    BuildContext context, {
    required ValueChanged<double> onChanged,
  }) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name),
          Slider(
            value: ParametersScope.of(context).getParameterValue(name),
            onChanged: onChanged,
            min: min,
            max: max,
          ),
        ],
      );
}
