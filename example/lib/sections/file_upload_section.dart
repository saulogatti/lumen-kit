import 'dart:async';

import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

/// Demonstrates files at different stages of an upload.
///
/// The Upload button simulates sending `invoice.pdf` from pending to completed.
class FileUploadSection extends StatefulWidget {
  /// Creates the file upload gallery section.
  const FileUploadSection({super.key});

  @override
  State<FileUploadSection> createState() => _FileUploadSectionState();
}

class _FileUploadSectionState extends State<FileUploadSection> {
  static const _steps = 20;
  static const _tick = Duration(milliseconds: 100);
  static const _waiting = LumenUploadItem(name: 'invoice.pdf', statusLabel: 'Waiting to upload');

  Timer? _timer;
  LumenUploadItem _invoice = _waiting;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: <Widget>[
        LumenFileUpload(
          items: <LumenUploadItem>[
            _invoice,
            const LumenUploadItem(
              name: 'photo.png',
              status: LumenUploadStatus.uploading,
              statusLabel: 'Uploading',
              progress: 0.65,
            ),
            const LumenUploadItem(
              name: 'report.pdf',
              status: LumenUploadStatus.completed,
              statusLabel: 'Uploaded',
              progress: 1,
            ),
            const LumenUploadItem(
              name: 'notes.txt',
              status: LumenUploadStatus.failed,
              statusLabel: 'Connection lost',
              progress: 0.32,
            ),
          ],
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: LumenButton(
            icon: Icons.upload,
            label: 'Upload',
            onPressed: _timer == null ? _startUpload : null,
          ),
        ),
      ],
    );
  }

  void _startUpload() {
    var step = 0;
    setState(() {
      _invoice = _waiting.copyWith(status: LumenUploadStatus.uploading, statusLabel: 'Uploading');
      _timer = Timer.periodic(_tick, (timer) {
        step++;
        setState(() {
          if (step < _steps) {
            _invoice = _invoice.copyWith(progress: step / _steps);
            return;
          }
          timer.cancel();
          _timer = null;
          _invoice = _invoice.copyWith(
            status: LumenUploadStatus.completed,
            statusLabel: 'Uploaded',
            progress: 1,
          );
        });
      });
    });
  }
}
