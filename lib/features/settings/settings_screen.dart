import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _manifestUrl =
      'https://raw.githubusercontent.com/nhatlong2595-max/dtt-finance-android/main/update.json';
  static const _apkMime = 'application/vnd.android.package-archive';

  bool checking = false;
  String version = '...';
  int buildNumber = 0;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      version = info.version;
      buildNumber = int.tryParse(info.buildNumber) ?? 0;
    });
  }

  Future<void> _checkUpdate() async {
    if (checking) return;
    setState(() => checking = true);
    try {
      final response = await http
          .get(Uri.parse(_manifestUrl), headers: {'Cache-Control': 'no-cache'})
          .timeout(const Duration(seconds: 25));
      if (response.statusCode != 200) {
        throw Exception('Không đọc được update.json (HTTP ${response.statusCode}).');
      }

      final manifest = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final app = (manifest['app'] ?? '').toString();
      if (app != 'DTT_Finance') {
        throw const FormatException('Manifest không thuộc ứng dụng DTT Finance.');
      }
      final latestCode = manifest['versionCode'] as int?;
      final latestVersion = (manifest['latestVersion'] ?? '').toString();
      final notes = (manifest['releaseNotes'] ?? 'Cải thiện ứng dụng').toString();
      final apkUrl = (manifest['apkUrl'] ?? '').toString();
      final expectedSha = (manifest['sha256'] ?? '').toString().trim().toLowerCase();

      if (latestCode == null || latestVersion.isEmpty || apkUrl.isEmpty ||
          !RegExp(r'^[a-f0-9]{64}$').hasMatch(expectedSha)) {
        throw const FormatException('Thông tin phiên bản hoặc SHA-256 trong manifest không hợp lệ.');
      }
      final uri = Uri.tryParse(apkUrl);
      if (uri == null || uri.scheme != 'https' ||
          uri.host != 'github.com' || !uri.path.contains('/releases/download/')) {
        throw const FormatException('Đường dẫn APK không phải GitHub Release hợp lệ.');
      }

      if (!mounted) return;
      if (latestCode <= buildNumber) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bạn đang dùng phiên bản mới nhất (v$version).')),
        );
      } else {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Có phiên bản DTT Finance mới'),
            content: Text(
              'Phiên bản hiện tại: $version (build $buildNumber)\n'
              'Phiên bản mới: $latestVersion (build $latestCode)\n\n'
              'Nội dung cập nhật: $notes\n\n'
              'Ứng dụng sẽ tải APK, xác minh SHA-256 rồi mở trình cài đặt Android.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Để sau'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _downloadAndInstall(apkUrl, expectedSha);
                },
                child: const Text('TẢI VÀ CẬP NHẬT'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      if (mounted) _showMessage('Không kiểm tra được cập nhật: $error');
    } finally {
      if (mounted) setState(() => checking = false);
    }
  }

  Future<void> _downloadAndInstall(String apkUrl, String expectedSha) async {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(children: [
            CircularProgressIndicator(),
            SizedBox(width: 18),
            Expanded(child: Text('Đang tải và xác minh bản cập nhật...')),
          ]),
        ),
      ),
    );

    try {
      final request = http.Request('GET', Uri.parse(apkUrl));
      final streamed = await http.Client()
          .send(request)
          .timeout(const Duration(minutes: 3));
      if (streamed.statusCode != 200) {
        throw HttpException('GitHub trả về HTTP ${streamed.statusCode}.');
      }
      final bytes = await streamed.stream.toBytes();
      if (bytes.isEmpty) throw const FormatException('File APK tải về rỗng.');

      final actualSha = sha256.convert(bytes).toString().toLowerCase();
      if (actualSha != expectedSha) {
        throw const FormatException('SHA-256 không khớp. Đã hủy cài đặt để bảo vệ dữ liệu.');
      }

      final directory = await getTemporaryDirectory();
      final apkFile = File('${directory.path}/dtt-finance-update.apk');
      await apkFile.writeAsBytes(bytes, flush: true);

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      final result = await OpenFilex.open(apkFile.path, type: _apkMime);
      if (result.type != ResultType.done) {
        throw Exception(result.message.isEmpty
            ? 'Android chưa mở được trình cài đặt APK.'
            : result.message);
      }
      _showMessage('Đã mở trình cài đặt Android. Hãy xác nhận Cập nhật để hoàn tất.');
    } catch (error) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).maybePop();
        _showMessage('Cập nhật chưa hoàn tất: $error');
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 5)),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Cài đặt')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Hồ sơ cá nhân'),
                subtitle: const Text('Thông tin người dùng'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Bảo mật ứng dụng'),
                subtitle: const Text('Tùy chọn bảo mật sẽ được bổ sung trong bản tiếp theo'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.backup_outlined),
                title: const Text('Sao lưu dữ liệu'),
                subtitle: const Text('Sao lưu đám mây chưa bật'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.system_update_alt),
                title: const Text('Phiên bản ứng dụng'),
                subtitle: Text('DTT Finance v$version · build $buildNumber'),
                trailing: checking
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.chevron_right),
                onTap: checking ? null : _checkUpdate,
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: checking ? null : _checkUpdate,
              icon: const Icon(Icons.cloud_download_outlined),
              label: Text(checking ? 'Đang kiểm tra...' : 'Kiểm tra cập nhật online'),
            ),
            const SizedBox(height: 8),
            const Text(
              'DTT Finance kiểm tra update.json trên GitHub, tải APK đầy đủ, xác minh SHA-256 và mở trình cài đặt Android. Android vẫn yêu cầu người dùng xác nhận cập nhật.',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      );
}
