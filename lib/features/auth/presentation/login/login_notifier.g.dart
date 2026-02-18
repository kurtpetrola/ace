// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$loginNotifierHash() => r'bdd8e91b2fcd84e63bac0f47094edc3913062258';

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

abstract class _$LoginNotifier
    extends BuildlessAutoDisposeNotifier<LoginState> {
  late final UserType userType;

  LoginState build({
    UserType userType = UserType.student,
  });
}

/// See also [LoginNotifier].
@ProviderFor(LoginNotifier)
const loginNotifierProvider = LoginNotifierFamily();

/// See also [LoginNotifier].
class LoginNotifierFamily extends Family<LoginState> {
  /// See also [LoginNotifier].
  const LoginNotifierFamily();

  /// See also [LoginNotifier].
  LoginNotifierProvider call({
    UserType userType = UserType.student,
  }) {
    return LoginNotifierProvider(
      userType: userType,
    );
  }

  @override
  LoginNotifierProvider getProviderOverride(
    covariant LoginNotifierProvider provider,
  ) {
    return call(
      userType: provider.userType,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'loginNotifierProvider';
}

/// See also [LoginNotifier].
class LoginNotifierProvider
    extends AutoDisposeNotifierProviderImpl<LoginNotifier, LoginState> {
  /// See also [LoginNotifier].
  LoginNotifierProvider({
    UserType userType = UserType.student,
  }) : this._internal(
          () => LoginNotifier()..userType = userType,
          from: loginNotifierProvider,
          name: r'loginNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$loginNotifierHash,
          dependencies: LoginNotifierFamily._dependencies,
          allTransitiveDependencies:
              LoginNotifierFamily._allTransitiveDependencies,
          userType: userType,
        );

  LoginNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userType,
  }) : super.internal();

  final UserType userType;

  @override
  LoginState runNotifierBuild(
    covariant LoginNotifier notifier,
  ) {
    return notifier.build(
      userType: userType,
    );
  }

  @override
  Override overrideWith(LoginNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: LoginNotifierProvider._internal(
        () => create()..userType = userType,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userType: userType,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<LoginNotifier, LoginState>
      createElement() {
    return _LoginNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LoginNotifierProvider && other.userType == userType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userType.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin LoginNotifierRef on AutoDisposeNotifierProviderRef<LoginState> {
  /// The parameter `userType` of this provider.
  UserType get userType;
}

class _LoginNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<LoginNotifier, LoginState>
    with LoginNotifierRef {
  _LoginNotifierProviderElement(super.provider);

  @override
  UserType get userType => (origin as LoginNotifierProvider).userType;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
