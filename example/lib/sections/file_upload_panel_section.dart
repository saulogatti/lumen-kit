import 'dart:async';

import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

/// Demonstrates [LumenFileUploadPanel] with a simulated picker and uploads.
///
/// Choose files stands in for the app's picker: it shows the busy state, then
/// adds a file and uploads it. Every second file fails halfway so Retry can be
/// tried. The Drag over switch stands in for the app's drop handler.
class FileUploadPanelSection extends StatefulWidget {
  /// Creates the upload panel gallery section.
  const FileUploadPanelSection({super.key});

  @override
  State<FileUploadPanelSection> createState() => _FileUploadPanelSectionState();
}

class _FileUploadPanelSectionState extends State<FileUploadPanelSection> {
  static const _pickDelay = Duration(milliseconds: 400);
  static const _tick = Duration(milliseconds: 100);
  static const _steps = 10;

  final List<_SimulatedFile> _files = <_SimulatedFile>[];
  Timer? _picker;
  Timer? _uploads;
  int _picked = 0;
  bool _dragging = false;

  @override
  void dispose() {
    _picker?.cancel();
    _uploads?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: <Widget>[
        LumenFileUploadPanel(
          title: 'Attach documents',
          hint: 'PDF or PNG, up to 10 MB',
          actionLabel: 'Choose files',
          onPick: _pick,
          busy: _picker != null,
          highlighted: _dragging,
          items: <LumenUploadItem>[for (final file in _files) file.item],
          onRemove: (index) => setState(() => _files.removeAt(index)),
          onRetry: _retry,
        ),
        LumenSwitch(
          label: 'Drag over',
          value: _dragging,
          onChanged: (value) => setState(() => _dragging = value),
        ),
      ],
    );
  }

  void _pick() {
    setState(() {
      _picker = Timer(_pickDelay, () {
        _picked++;
        setState(() {
          _picker = null;
          _files.add(
            _SimulatedFile(
              LumenUploadItem(
                name: 'document-$_picked.pdf',
                status: LumenUploadStatus.uploading,
                statusLabel: 'Uploading',
              ),
              failHalfway: _picked.isEven,
            ),
          );
        });
        _startUploads();
      });
    });
  }

  void _retry(int index) {
    setState(() {
      final file = _files[index];
      file.item = file.item.copyWith(
        status: LumenUploadStatus.uploading,
        statusLabel: 'Uploading',
        progress: 0,
      );
    });
    _startUploads();
  }

  void _startUploads() {
    _uploads ??= Timer.periodic(_tick, (_) => setState(_advance));
  }

  void _advance() {
    for (final file in _files) {
      final item = file.item;
      if (item.status != LumenUploadStatus.uploading) {
        continue;
      }
      // Whole steps keep the halfway check exact despite floating point.
      final progress = ((item.progress * _steps).round() + 1) / _steps;
      if (file.failHalfway && progress >= 0.5) {
        file.failHalfway = false;
        file.item = item.copyWith(
          status: LumenUploadStatus.failed,
          statusLabel: 'Connection lost',
          progress: progress,
        );
      } else if (progress >= 1) {
        file.item = item.copyWith(
          status: LumenUploadStatus.completed,
          statusLabel: 'Uploaded',
          progress: 1,
        );
      } else {
        file.item = item.copyWith(progress: progress);
      }
    }
    if (!_files.any((file) => file.item.status == LumenUploadStatus.uploading)) {
      _uploads?.cancel();
      _uploads = null;
    }
  }
}

/// A gallery file and whether its first upload attempt should fail.
class _SimulatedFile {
  LumenUploadItem item;
  bool failHalfway;

  _SimulatedFile(this.item, {required this.failHalfway});
}
