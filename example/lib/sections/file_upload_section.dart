import 'dart:async';

import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

/// Demonstrates files at different stages of an upload.
class FileUploadSection extends StatefulWidget {
  /// Creates the file upload gallery section.
  const FileUploadSection({super.key});

  @override
  State<FileUploadSection> createState() => _FileUploadSectionState();
}

class _FileUploadSectionState extends State<FileUploadSection> {
  Timer? _timer;
  final item = LumenUploadItem(name: 'invoice.pdf', statusLabel: 'Waiting to upload', progress: 0);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LumenFileUpload(
          items: <LumenUploadItem>[
            LumenUploadItem(name: 'report.pdf', statusLabel: 'Waiting to upload', progress: 0),
            _getItem(),

            LumenUploadItem(
              name: 'notes.txt',
              status: LumenUploadStatus.failed,
              statusLabel: 'Connection lost',
              progress: 0.32,
            ),
          ],
        ),
        const SizedBox(height: 24),
        LumenButton(icon: Icons.upload, onPressed: _startTimer, label: 'Upload'),
      ],
    );
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  LumenUploadItem _getItem() {
    return item;
  }

  void _startTimer() {
    if (_timer != null) return;
    _timer = Timer(const Duration(milliseconds: 100), () async {
      await Future.delayed(const Duration(seconds: 1));
      item.status = LumenUploadStatus.uploading;
      item.statusLabel = 'Uploading';
      while (item.progress < 1.0) {
        item.progress += 0.01;
        await Future.delayed(const Duration(milliseconds: 100));
      }
      item.status = LumenUploadStatus.completed;
      item.statusLabel = 'File uploaded';
      _stopTimer();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
