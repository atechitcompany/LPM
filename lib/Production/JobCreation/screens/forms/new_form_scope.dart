import 'package:flutter/material.dart';
import 'new_form.dart';

class NewFormScope extends InheritedWidget {
  final NewFormState form;

  const NewFormScope({
    super.key,
    required this.form,
    required Widget child,
  }) : super(child: child);

  static NewFormState of(BuildContext context) {
    final scope =
    context.dependOnInheritedWidgetOfExactType<NewFormScope>();
    assert(scope != null, 'NewFormScope not found in context');
    return scope!.form;
  }

  @override
  bool updateShouldNotify(NewFormScope oldWidget) => false;
}
