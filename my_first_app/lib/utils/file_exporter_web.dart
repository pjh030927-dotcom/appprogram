import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<bool> exportTextFile({
  required String fileName,
  required String content,
}) async {
  // Windows 메모장에서도 한글이 깨지지 않도록 UTF-8 BOM(\uFEFF) 추가
  final blob = web.Blob(
    <web.BlobPart>['\uFEFF$content'.toJS].toJS,
    web.BlobPropertyBag(type: 'text/plain;charset=utf-8'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = fileName
    ..style.display = 'none';

  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
  return true;
}
