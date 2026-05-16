// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EventController)
const eventControllerProvider = EventControllerProvider._();

final class EventControllerProvider
    extends $AsyncNotifierProvider<EventController, List<Event>> {
  const EventControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventControllerHash();

  @$internal
  @override
  EventController create() => EventController();
}

String _$eventControllerHash() => r'4a5b890757d6470e9db101c77d0dc93f5b277727';

abstract class _$EventController extends $AsyncNotifier<List<Event>> {
  FutureOr<List<Event>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Event>>, List<Event>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Event>>, List<Event>>,
              AsyncValue<List<Event>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
