import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

/// A simple class to hold file data, mimicking file_picker's PlatformFile.
class WebFile {
  final String name;
  final Uint8List bytes;

  WebFile({required this.name, required this.bytes});
}

/// Triggers a browser file picker and returns the selected file.
Future<WebFile?> pickFile() async {
  final completer = Completer<WebFile?>();
  final input = document.createElement('input'.toJS) as HTMLInputElement;
  input.type = 'file'.toJS;
  input.accept = '.gpx'.toJS;

  // Hide the input element
  input.style.setProperty('display'.toJS, 'none'.toJS);

  input.onchange = (JSAny? _) {
    final files = input.files;
    if (files.length > 0) {
      final file = files[0]! as File;
      // The arrayBuffer() method returns a promise that resolves with an ArrayBuffer.
      final promise = file.arrayBuffer();
      promise.toDart.then((arrayBuffer) {
        final byteBuffer = (arrayBuffer! as JSArrayBuffer).toDart;
        completer.complete(WebFile(
            name: file.name.toDart, bytes: byteBuffer.asUint8List()));
      });
    } else {
      completer.complete(null);
    }
  }.toJS;

  document.body!.appendChild(input);
  input.click();

  // Clean up the input element after the user has made a selection.
  completer.future.whenComplete(() {
    document.body!.removeChild(input);
  });

  return completer.future;
}

// JS Interop definitions for DOM elements

@JS('document')
external Document get document;

@JS()
@staticInterop
class Document {}

extension DocumentExtension on Document {
  external HTMLInputElement createElement(JSString tag);
  external HTMLElement? get body;
}

@JS()
@staticInterop
class HTMLElement {}

extension HTMLElementExtension on HTMLElement {
  external void appendChild(HTMLElement child);
  external void removeChild(HTMLElement child);
  external CSSStyleDeclaration get style;
}

@JS()
@staticInterop
class HTMLInputElement extends HTMLElement {}

extension HTMLInputElementExtension on HTMLInputElement {
  external set accept(JSString v);
  external set type(JSString v);
  external void click();
  external set onchange(JSFunction f);
  external JSArray<JSAny?> get files;
}

@JS('File')
@staticInterop
class File {}

extension FileExtension on File {
  external JSString get name;
  external JSPromise<JSAny?> arrayBuffer();
}

@JS()
@staticInterop
class CSSStyleDeclaration {}

extension CSSStyleDeclarationExtension on CSSStyleDeclaration {
  external void setProperty(JSString propertyName, JSString value);
}
