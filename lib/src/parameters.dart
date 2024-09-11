import 'dart:async';

import 'package:flutter/material.dart';
import 'package:storyboard_flutter/src/plugin.dart';
import 'package:storyboard_flutter/storyboard_flutter.dart';

class ParametersPlugin extends Plugin {
  ParametersPlugin()
      : super(
          name: 'Parameters',
          description: 'Adds parameters to the story.',
        );

  @override
  ChildBuilder? get storyboardWrapper => (context, child) => ParametersScope(child: child);

  @override
  WidgetBuilder? get panelBuilder => (context) {
        final story = StoryNotifier.of(context).activeStory;
        if (story == null) return const SizedBox.shrink();

        final parameters = ParametersScope.of(context).getParameters(story);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Parameters', style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            const SizedBox(height: 8),
            ...parameters.map((parameter) => _buildParameterWidget(context, story, parameter)),
          ],
        );
      };

  Widget _buildParameterWidget(BuildContext context, Story story, Parameter parameter) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: parameter.build(
        context,
        onChanged: (value) => ParametersScope.of(context).updateParameter(
          parameter: parameter,
          story: story,
          value: value,
        ),
      ),
    );
  }
}

class ParametersNotifier extends ChangeNotifier {
  final Map<String, Map<String, Parameter>> _parameters = {};

  T addParameter<T>(Story story, Parameter<T> parameter) {
    final storyParameters = _parameters[story.id] ??= {};
    final existingParameter = storyParameters[parameter.name] as Parameter<T>?;

    if (existingParameter != null) return existingParameter.value;

    storyParameters[parameter.name] = parameter;
    scheduleMicrotask(notifyListeners);
    return parameter.value;
  }

  List<Parameter> getParameters(Story story) => _parameters[story.id]?.values.toList() ?? [];

  void updateParameter<T>({
    required Parameter<T> parameter,
    required Story story,
    required T value,
  }) {
    final storyParameters = _parameters[story.id];
    if (storyParameters != null) {
      storyParameters[parameter.name] = parameter.copyWithValue(content: value);
      scheduleMicrotask(notifyListeners);
    }
  }
}

class ParametersScope extends StatefulWidget {
  const ParametersScope({required this.child, super.key});

  final Widget child;

  static ParametersScopeState of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_ParametersScopeInherited>();
    assert(inherited != null, 'ParametersScopeInherited not found in the widget tree.');
    return inherited!.state;
  }

  @override
  ParametersScopeState createState() => ParametersScopeState();
}

class ParametersScopeState extends State<ParametersScope> {
  final _parametersNotifier = ParametersNotifier();

  T addParameter<T>(Parameter<T> parameter) => _parametersNotifier.addParameter(
        StoryNotifier.of(context).activeStory!,
        parameter,
      );

  List<Parameter> getParameters(Story story) => _parametersNotifier.getParameters(story);

  void updateParameter<T>({
    required Parameter<T> parameter,
    required Story story,
    required T value,
  }) =>
      _parametersNotifier.updateParameter(parameter: parameter, story: story, value: value);

  @override
  Widget build(BuildContext context) {
    return _ParametersScopeInherited(
      state: this,
      notifier: _parametersNotifier,
      child: widget.child,
    );
  }
}

class _ParametersScopeInherited extends InheritedNotifier<ParametersNotifier> {
  const _ParametersScopeInherited({
    required this.state,
    required ParametersNotifier super.notifier,
    required super.child,
  });

  final ParametersScopeState state;
}

abstract class Parameter<T> {
  const Parameter({required this.name, required this.value});

  final String name;
  final T value;

  Parameter<T> copyWithValue({required T content});

  Widget build(BuildContext context, {required ValueChanged<T> onChanged});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Parameter<T> && runtimeType == other.runtimeType && name == other.name && value == other.value;

  @override
  int get hashCode => name.hashCode ^ value.hashCode;
}

class StringParameter extends Parameter<String> {
  StringParameter({required super.name, required super.value});

  @override
  Widget build(BuildContext context, {required ValueChanged<String> onChanged}) => TextFormField(
        initialValue: value,
        onChanged: onChanged,
        decoration: InputDecoration(labelText: name),
      );

  @override
  Parameter<String> copyWithValue({required String content}) => StringParameter(name: name, value: content);
}

class DoubleParameter extends Parameter<double> {
  DoubleParameter({
    required super.name,
    required super.value,
    this.min = 0,
    this.max = 100,
  });

  final double min;
  final double max;

  @override
  Widget build(BuildContext context, {required ValueChanged<double> onChanged}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name),
          Slider(value: value, onChanged: onChanged, min: min, max: max),
        ],
      );

  @override
  Parameter<double> copyWithValue({required double content}) =>
      DoubleParameter(name: name, value: content, min: min, max: max);
}
