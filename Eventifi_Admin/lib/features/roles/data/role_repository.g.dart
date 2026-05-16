// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(roleRepository)
const roleRepositoryProvider = RoleRepositoryProvider._();

final class RoleRepositoryProvider
    extends $FunctionalProvider<RoleRepository, RoleRepository, RoleRepository>
    with $Provider<RoleRepository> {
  const RoleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'roleRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roleRepositoryHash();

  @$internal
  @override
  $ProviderElement<RoleRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RoleRepository create(Ref ref) {
    return roleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoleRepository>(value),
    );
  }
}

String _$roleRepositoryHash() => r'92031ae8bcda368a28234c73595e2d151a3881a5';
