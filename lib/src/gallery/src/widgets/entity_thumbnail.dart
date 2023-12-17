import 'dart:io';

import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// Widget to display [DrishyaEntity] thumbnail
class EntityThumbnail extends StatelessWidget {
  ///
  const EntityThumbnail({
    Key? key,
    required this.entity,
    this.onBytesGenerated,
  }) : super(key: key);

  ///
  final DrishyaEntity entity;

  /// Callback function triggered when image bytes is generated
  final ValueSetter<Uint8List?>? onBytesGenerated;

  Future<File?> thmnnail(DrishyaEntity entity) async {
    final file = await entity.file;
    if (file == null) return null;

    final uint8list = await VideoThumbnail.thumbnailFile(
      video: file.path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      maxWidth:
          200, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 50,
    );
    if (uint8list == null) return null;
    return File(uint8list);
  }

  @override
  Widget build(BuildContext context) {
    Widget child = const SizedBox();
    print('video preview');

    //
    if (entity.type == AssetType.image || entity.type == AssetType.video) {
      /*   if (entity.type == AssetType.image) {
        print(entity.pickedFile?.path ?? '');
        child = Image.file(File(entity.file ?? ''));
      } else */
      if (entity.pickedThumbData != null) {
        print(
          'video preview->entity.pickedThumbData != null ${entity.duration}',
        );
        child = Image.memory(
          entity.pickedThumbData!,
          fit: BoxFit.fill,
        );
      } else {
        print('video preview-> ese ${entity.duration}}');
        child = FutureBuilder(
          future: thmnnail(entity),
          builder: (context, data) {
            if (data.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (data.data == null) return const Icon(Icons.video_call);
            return Image.file(
              data.data! as File,
              fit: BoxFit.cover,
            );
          },
        );
      }
    }

    if (entity.type == AssetType.audio) {
      child = const Center(child: Icon(Icons.audiotrack, color: Colors.white));
    }

    if (entity.type == AssetType.other) {
      child = const Center(child: Icon(Icons.file_copy, color: Colors.white));
    }

    if (entity.type == AssetType.video || entity.type == AssetType.audio) {
      child = Stack(
        fit: StackFit.expand,
        children: [
          child,
          Align(
            alignment: Alignment.bottomRight,
            child: _DurationView(duration: entity.duration),
          ),
        ],
      );
    }

    return AspectRatio(
      aspectRatio: 1 / 2,
      child: child,
    );
  }
}

/// ImageProvider implementation
@immutable
class _MediaThumbnailProvider extends ImageProvider<_MediaThumbnailProvider> {
  /// Constructor for creating a [_MediaThumbnailProvider]
  const _MediaThumbnailProvider({
    required this.entity,
    this.onBytesLoaded,
  });

  ///
  final DrishyaEntity entity;
  final ValueSetter<Uint8List?>? onBytesLoaded;

  /*  @override
  ImageStreamCompleter load(
    _MediaThumbnailProvider key,
    // DecoderCallback decode,
  ) =>
      MultiFrameImageStreamCompleter(
        codec: _loadAsync(key, decode),
        scale: 1,
        informationCollector: () sync* {
          yield ErrorDescription('Id: ${entity.id}');
        },
      ); */

  /*  Future<ui.Codec> _loadAsync(
    _MediaThumbnailProvider key,
  ) async {
    assert(key == this, 'Checks _MediaThumbnailProvider');
    final bytes =
        await entity.thumbnailDataWithSize(const ThumbnailSize(250, 250));

    // final bytes = await entity.thumbnailData;
    onBytesLoaded?.call(bytes);
    // return decode(bytes!);
    return Object();
  } */

  @override
  Future<_MediaThumbnailProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<_MediaThumbnailProvider>(this);

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    // ignore: test_types_in_equals
    final typedOther = other as _MediaThumbnailProvider;
    return entity.id == typedOther.entity.id;
  }

  @override
  int get hashCode => entity.id.hashCode;

  @override
  String toString() => '$_MediaThumbnailProvider("${entity.id}")';
}

class _DurationView extends StatelessWidget {
  const _DurationView({
    Key? key,
    required this.duration,
  }) : super(key: key);

  final int duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black.withOpacity(0.7),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          duration.formatedDuration,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

extension on int {
  String get formatedDuration {
    final duration = Duration(seconds: this);
    final min = duration.inMinutes.remainder(60).toString().padRight(2, '0');
    final sec = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }
}
