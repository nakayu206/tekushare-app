/// ストアで配布済みのビルドと、更新案内の設定。
class AppUpdate {
  const AppUpdate({
    required this.latestBuild,
    required this.minimumBuild,
    required this.version,
    required this.storeUri,
  });

  final int latestBuild;
  final int minimumBuild;
  final String version;
  final Uri storeUri;

  /// 不正な設定やストア以外への誘導は採用しない。
  static AppUpdate? fromMap(Map<String, dynamic> data) {
    final latest = data['latestBuild'];
    final minimum = data['minimumBuild'];
    final version = data['version'];
    final uri = Uri.tryParse(
        data['storeUrl'] is String ? data['storeUrl'] as String : '');
    if (latest is! int ||
        minimum is! int ||
        minimum < 0 ||
        latest < minimum ||
        version is! String ||
        version.trim().isEmpty ||
        uri == null ||
        uri.scheme != 'https' ||
        uri.userInfo.isNotEmpty ||
        !{'play.google.com', 'apps.apple.com'}.contains(uri.host)) {
      return null;
    }
    return AppUpdate(
        latestBuild: latest,
        minimumBuild: minimum,
        version: version,
        storeUri: uri);
  }

  bool isRequired(int currentBuild) => currentBuild < minimumBuild;
  bool isAvailable(int currentBuild) => currentBuild < latestBuild;
}
