part of 'proxy_repository.dart';

/// Provides the active [ProxyRepository] to the widget tree.
class ProxyRepositoryScope extends InheritedNotifier<ProxyRepository> {
  /// Creates a repository scope for descendant widgets.
  const ProxyRepositoryScope({
    required ProxyRepository repository,
    required super.child,
    super.key,
  }) : super(notifier: repository);

  /// Returns the nearest repository from the build context.
  static ProxyRepository of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ProxyRepositoryScope>();
    assert(scope != null, 'ProxyRepositoryScope was not found in the tree.');
    return scope!.notifier!;
  }
}
