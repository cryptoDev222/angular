import 'dart:math';

import 'package:angular/src/core/application_tokens.dart';
import 'package:angular/src/core/exception_handler.dart';
import 'package:angular/src/core/linker/component_factory.dart';
import 'package:angular/src/core/linker/component_loader.dart';
import 'package:angular/src/core/linker/dynamic_component_loader.dart';
import 'package:angular/src/di/injector.dart';

/// Implementation of [SlowComponentLoader] that throws [UnsupportedError].
///
/// This is to allow a migration path for common components that may need to
/// inject [SlowComponentLoader] for the legacy `bootstrapStatic` method, but
/// won't actually use it in apps that called `bootstrapFactory`.
class _ThrowingSlowComponentLoader implements SlowComponentLoader {
  static const _slowComponentLoaderWarning =
      'You are using runApp or runAppAsync, which does not support loading a '
      'component with SlowComponentLoader. Please migrate this code to use '
      'ComponentLoader instead.';

  const _ThrowingSlowComponentLoader();

  @override
  Future<ComponentRef<T>> load<T>(_, __) {
    throw UnsupportedError(_slowComponentLoaderWarning);
  }

  @override
  Future<ComponentRef<T>> loadNextToLocation<T>(_, __, [___]) {
    throw UnsupportedError(_slowComponentLoaderWarning);
  }
}

/// Returns a simple application [Injector] that is hand-authored.
///
/// Some of the services provided below ([ExceptionHandler], [APP_ID]) may be
/// overriden by the user-supplied injector - the returned [InjectorFactory] is
/// used as the "base" application injector.
///
/// Previously this used `@GenerateInjector`, but that requires running the
/// Angular generator _on_ Angular itself, which leads to tricky circular
/// dependency issues for little value.
InjectorFactory minimalApp() {
  return (parent) {
    return Injector.map({
      APP_ID: _createRandomAppId(),
      ExceptionHandler: const ExceptionHandler(),
      ComponentLoader: const ComponentLoader(),
      SlowComponentLoader: const _ThrowingSlowComponentLoader(),
    }, parent);
  };
}

/// Creates a random [APP_ID] for use in CSS encapsulation.
String _createRandomAppId() {
  final random = Random();
  String char() => String.fromCharCode(97 + random.nextInt(26));
  return '${char()}${char()}${char()}';
}
