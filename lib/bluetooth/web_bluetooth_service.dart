import 'dart:async';
import 'dart:js_interop';

@JS('navigator.bluetooth')
external Bluetooth? get bluetooth;

@JS()
@staticInterop
class Bluetooth implements JSObject {}

extension BluetoothExtension on Bluetooth {
  external JSPromise<BluetoothDevice> requestDevice(RequestOptions options);
}

@JS()
@staticInterop
class BluetoothDevice implements JSObject {}

extension BluetoothDeviceExtension on BluetoothDevice {
  external JSString get id;
  external JSString? get name;
  external BluetoothRemoteGATTServer? get gatt;
}

@JS()
@staticInterop
class BluetoothRemoteGATTServer implements JSObject {}

extension BluetoothRemoteGATTServerExtension on BluetoothRemoteGATTServer {
  external JSPromise<BluetoothRemoteGATTService> getPrimaryService(
      JSString service);
  external JSPromise<JSObject> connect();
  external void disconnect();
}

@JS()
@staticInterop
class BluetoothRemoteGATTService implements JSObject {}

extension BluetoothRemoteGATTServiceExtension on BluetoothRemoteGATTService {
  external JSPromise<BluetoothRemoteGATTCharacteristic> getCharacteristic(
      JSString characteristic);
}

@JS()
@staticInterop
class BluetoothRemoteGATTCharacteristic implements JSObject {}

extension BluetoothRemoteGATTCharacteristicExtension
    on BluetoothRemoteGATTCharacteristic {
  external JSPromise<JSAny> startNotifications();
  external JSPromise<JSAny> stopNotifications();
  external JSPromise<JSAny> writeValue(JSObject value);
  external JSPromise<JSDataView> readValue();

  external set oncharacteristicvaluechanged(JSFunction f);
}

@JS()
@anonymous
@staticInterop
class RequestOptions implements JSObject {
  external factory RequestOptions({
    JSArray<BluetoothScanFilter> filters,
    JSArray<JSString> optionalServices,
  });
}

@JS()
@anonymous
@staticInterop
class BluetoothScanFilter implements JSObject {
  external factory BluetoothScanFilter({
    JSArray<JSString> services,
  });
}

@JS('DataView')
@staticInterop
class JSDataView implements JSObject {}

extension JSDataViewExtension on JSDataView {
  external int getInt16(int byteOffset, [bool littleEndian]);
}

// Interop definitions for Event handling
@JS()
@staticInterop
class Event implements JSObject {}

extension EventExtension on Event {
  external EventTarget? get target;
}

@JS()
@staticInterop
class EventTarget implements JSObject {}

extension EventTargetExtension on EventTarget {
  external JSDataView? get value;
}