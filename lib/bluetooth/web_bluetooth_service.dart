import 'dart:js_interop';

@JS('navigator.bluetooth')
external Bluetooth? get bluetooth;

@JS()
@staticInterop
class Bluetooth {}

extension BluetoothExtension on Bluetooth {
  external JSPromise<JSAny?> requestDevice(RequestOptions options);
}

@JS()
@staticInterop
class BluetoothDevice {}

extension BluetoothDeviceExtension on BluetoothDevice {
  external JSString get id;
  external JSString? get name;
  external BluetoothRemoteGATTServer? get gatt;
}

@JS()
@staticInterop
class BluetoothRemoteGATTServer {}

extension BluetoothRemoteGATTServerExtension on BluetoothRemoteGATTServer {
  external JSPromise<JSAny?> getPrimaryService(JSString service);
  external JSPromise<JSAny?> connect();
  external void disconnect();
}

@JS()
@staticInterop
class BluetoothRemoteGATTService {}

extension BluetoothRemoteGATTServiceExtension on BluetoothRemoteGATTService {
  external JSPromise<JSAny?> getCharacteristic(JSString characteristic);
}

@JS()
@staticInterop
class BluetoothRemoteGATTCharacteristic {}

extension BluetoothRemoteGATTCharacteristicExtension
    on BluetoothRemoteGATTCharacteristic {
  external JSPromise<JSAny?> startNotifications();
  external JSPromise<JSAny?> stopNotifications();
  external JSPromise<JSAny?> writeValue(JSObject value);
  external JSPromise<JSAny?> readValue();
  external JSDataView? get value;

  external set oncharacteristicvaluechanged(JSFunction f);
}

@JS()
@anonymous
@staticInterop
class RequestOptions {
  external factory RequestOptions({
    JSArray<JSAny?> filters,
    JSArray<JSString> optionalServices,
  });
}

@JS()
@anonymous
@staticInterop
class BluetoothScanFilter {
  external factory BluetoothScanFilter({
    JSArray<JSString> services,
  });
}

@JS('DataView')
@staticInterop
class JSDataView {}

extension JSDataViewExtension on JSDataView {
  external int getInt16(int byteOffset, [bool littleEndian]);
}

@JS()
@staticInterop
class Event {}

extension EventExtension on Event {
  external JSAny? get target;
}