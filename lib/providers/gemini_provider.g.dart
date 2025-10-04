// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gemini_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$geminiHash() => r'18cb9a3241ff1591857211d3d4ce2f7a0e5f2e45';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$Gemini
    extends BuildlessAutoDisposeNotifier<DataState<GeminiResponseModel>> {
  late final String? key;

  DataState<GeminiResponseModel> build(String? key);
}

/// See also [Gemini].
@ProviderFor(Gemini)
const geminiProvider = GeminiFamily();

/// See also [Gemini].
class GeminiFamily extends Family<DataState<GeminiResponseModel>> {
  /// See also [Gemini].
  const GeminiFamily();

  /// See also [Gemini].
  GeminiProvider call(String? key) {
    return GeminiProvider(key);
  }

  @override
  GeminiProvider getProviderOverride(covariant GeminiProvider provider) {
    return call(provider.key);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'geminiProvider';
}

/// See also [Gemini].
class GeminiProvider
    extends
        AutoDisposeNotifierProviderImpl<
          Gemini,
          DataState<GeminiResponseModel>
        > {
  /// See also [Gemini].
  GeminiProvider(String? key)
    : this._internal(
        () => Gemini()..key = key,
        from: geminiProvider,
        name: r'geminiProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$geminiHash,
        dependencies: GeminiFamily._dependencies,
        allTransitiveDependencies: GeminiFamily._allTransitiveDependencies,
        key: key,
      );

  GeminiProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.key,
  }) : super.internal();

  final String? key;

  @override
  DataState<GeminiResponseModel> runNotifierBuild(covariant Gemini notifier) {
    return notifier.build(key);
  }

  @override
  Override overrideWith(Gemini Function() create) {
    return ProviderOverride(
      origin: this,
      override: GeminiProvider._internal(
        () => create()..key = key,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        key: key,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<Gemini, DataState<GeminiResponseModel>>
  createElement() {
    return _GeminiProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GeminiProvider && other.key == key;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, key.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GeminiRef
    on AutoDisposeNotifierProviderRef<DataState<GeminiResponseModel>> {
  /// The parameter `key` of this provider.
  String? get key;
}

class _GeminiProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          Gemini,
          DataState<GeminiResponseModel>
        >
    with GeminiRef {
  _GeminiProviderElement(super.provider);

  @override
  String? get key => (origin as GeminiProvider).key;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
