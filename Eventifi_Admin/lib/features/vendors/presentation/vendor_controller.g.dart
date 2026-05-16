// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VendorController)
const vendorControllerProvider = VendorControllerProvider._();

final class VendorControllerProvider
    extends $AsyncNotifierProvider<VendorController, List<Vendor>> {
  const VendorControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vendorControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vendorControllerHash();

  @$internal
  @override
  VendorController create() => VendorController();
}

String _$vendorControllerHash() => r'e183dc6774dfedb73dc017ead50d691532a964fd';

abstract class _$VendorController extends $AsyncNotifier<List<Vendor>> {
  FutureOr<List<Vendor>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Vendor>>, List<Vendor>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Vendor>>, List<Vendor>>,
              AsyncValue<List<Vendor>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
