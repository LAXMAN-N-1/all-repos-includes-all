// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RoleController)
const roleControllerProvider = RoleControllerProvider._();

final class RoleControllerProvider
    extends $AsyncNotifierProvider<RoleController, List<Role>> {
  const RoleControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'roleControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roleControllerHash();

  @$internal
  @override
  RoleController create() => RoleController();
}

String _$roleControllerHash() => r'ef62f35383b3b9acc15a53c4e8a5aec5a92e54ae';

abstract class _$RoleController extends $AsyncNotifier<List<Role>> {
  FutureOr<List<Role>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Role>>, List<Role>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Role>>, List<Role>>,
              AsyncValue<List<Role>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
