import 'package:material_ui/material_ui.dart';

/// The name, status label, and progress of one file in a `LumenFileUpload`.
///
/// The upload list listens to this object. Assign [progress], [status], or
/// [statusLabel] to update that row. [status] selects the label color.
/// [statusLabel] is the text and is not derived from [status].
class LumenUploadItem with ChangeNotifier {
  /// File name displayed in the row and announced with its progress.
  final String name;

  LumenUploadStatus _status;

  /// App-provided status text, including any error details to show.
  String _statusLabel;

  /// Stored upload fraction, independent of [status].
  double _progress;

  /// Describes a file, its status label, and its reported progress.
  ///
  /// [progress] must be from `0.0` to `1.0` inclusive. A value outside that
  /// range, including `NaN`, throws an assertion error when assertions are
  /// enabled. Otherwise the argument is stored as given. [status] defaults to
  /// [LumenUploadStatus.pending]. [statusLabel] defaults to an empty string.
  new({
    required this.name,
    this._status = LumenUploadStatus.pending,
    this._statusLabel = '',
    this._progress = 0,
  }) : assert(_progress >= 0 && _progress <= 1, 'Progress must be between 0 and 1 inclusive');

  /// Stored upload fraction, independent of [status].
  ///
  /// With assertions enabled this is from `0.0` to `1.0` inclusive. Without
  /// them, a constructor argument outside that range is kept. The setter clamps
  /// finite values into range.
  double get progress => _progress;

  /// Sets the progress fraction and notifies listeners.
  ///
  /// Finite values below `0.0` become `0.0`, and finite values above `1.0`
  /// become `1.0`. `NaN` is stored unchanged. Listeners are notified when the
  /// assigned value is not equal to the stored fraction. Clamping back to the
  /// current fraction still notifies. `NaN` never compares equal, so assigning
  /// it notifies again.
  set progress(double value) {
    if (_progress == value) return;
    _progress = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// State used to color [statusLabel].
  LumenUploadStatus get status => _status;

  /// Sets the status used to color [statusLabel] and notifies listeners when it changes.
  set status(LumenUploadStatus value) {
    if (_status == value) return;
    _status = value;
    notifyListeners();
  }

  /// App-provided status text, including any error details to show.
  ///
  /// Independent of [status]. The upload row shows this string as given.
  String get statusLabel => _statusLabel;

  /// Sets the status text and notifies listeners when it changes.
  set statusLabel(String value) {
    if (_statusLabel == value) return;
    _statusLabel = value;
    notifyListeners();
  }
}

/// Color key for a file's [LumenUploadItem.statusLabel] in a `LumenFileUpload` row.
///
/// The label text comes from the app. These values only choose its color.
enum LumenUploadStatus {
  /// Waiting to upload. The label uses the muted text color.
  pending,

  /// Upload in progress. The label uses the primary color.
  uploading,

  /// Upload finished successfully. The label uses the success color.
  completed,

  /// Upload failed. The label uses the danger color.
  failed,
}
