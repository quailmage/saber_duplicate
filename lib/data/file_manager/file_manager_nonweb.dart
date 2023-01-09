
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image_gallery_saver_v3/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future fmExportFile(String fileName, Uint8List bytes, {bool isImage = false}) async {
  File? tempFile;
  Future<File> getTempFile() async {
    final String tempFolder = (await getTemporaryDirectory()).path;
    final File file = File("$tempFolder/$fileName");
    await file.writeAsBytes(bytes);
    return file;
  }

  if (Platform.isAndroid || Platform.isIOS) {
    if (isImage) { // save image to gallery
      final Map result = await ImageGallerySaver.saveImage(
        bytes,
        quality: 100,
        name: fileName,
      );
      if (result["isSuccess"] == true) return;
    }

    // otherwise share file
    tempFile = await getTempFile();
    await Share.shareXFiles([XFile(tempFile.path)]);
  } else { // desktop, open save-as dialog
    String? outputFile = await FilePicker.platform.saveFile(
      fileName: fileName,
      initialDirectory: (await getDownloadsDirectory())?.path,
      allowedExtensions: [fileName.split(".").last],
    );
    if (outputFile != null) {
      File file = File(outputFile);
      await file.writeAsBytes(bytes);
    }
  }

  // delete temp file if it isn't null
  await tempFile?.delete();
}
