import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:kickr_flutter/bluetooth/web_bluetooth_service.dart';

class FtmsService {
  BluetoothDevice? _device;

  static const String ftmsServiceUUID = '00001826-0000-1000-8000-00805f9b34fb';
  static const String indoorBikeDataCharacteristicUUID = '00002ad2-0000-1000-8000-00805f9b34fb';
  static const String fitnessMachineControlPointCharacteristicUUID = '00002ad9-0000-1000-8000-00805f9b34fb';

  final StreamController<int> _powerController = StreamController<int>.broadcast();
  Stream<int> get powerStream => _powerController.stream;

  BluetoothRemoteGATTCharacteristic? _controlPointCharacteristic;

  Future<bool> connect() async {
    final bt = bluetooth;
    if (bt == null) {
      print('Web Bluetooth not available');
      return false;
    }

    final options = RequestOptions(
      filters: [
        BluetoothScanFilter(services: [ftmsServiceUUID.toJS].toJS),
      ].toJS,
      optionalServices: [ftmsServiceUUID.toJS].toJS,
    );

    try {
      _device = await bt.requestDevice(options).toDart;
      if (_device == null) return false;

      await _device!.gatt!.connect().toDart;
      final service = await _device!.gatt!.getPrimaryService(ftmsServiceUUID.toJS).toDart;

      // Get characteristics
      _controlPointCharacteristic = await service.getCharacteristic(fitnessMachineControlPointCharacteristicUUID.toJS).toDart;
      final indoorBikeDataCharacteristic = await service.getCharacteristic(indoorBikeDataCharacteristicUUID.toJS).toDart;

      // Subscribe to power notifications
      await indoorBikeDataCharacteristic.startNotifications().toDart;
      indoorBikeDataCharacteristic.oncharacteristicvaluechanged = (JSEvent event) {
        final value = getProperty(event.target, 'value') as JSDataView;
        final power = value.getInt16(2, true); // littleEndian = true
        _powerController.add(power);
      }.toJS;

      await requestControl();

      return true;
    } catch (e) {
      print('Error connecting to FTMS device: $e');
      return false;
    }
  }

  Future<void> requestControl() async {
    if (_controlPointCharacteristic != null) {
      final command = Uint8List.fromList([0x00]); // Op Code for Request Control
      try {
        await _controlPointCharacteristic!.writeValue(command.toJS).toDart;
        print("Requested FTMS control");
      } catch (e) {
        print('Error requesting control: $e');
      }
    }
  }

  Future<void> setSimulationParameters(double grade) async {
    if (_controlPointCharacteristic != null) {
      // Op Code 0x11 for Set Indoor Bike Simulation Parameters
      final command = ByteData(7);
      command.setUint8(0, 0x11);
      command.setInt16(1, 0, Endian.little); // Wind Speed (0)
      command.setInt16(3, (grade * 10000).round(), Endian.little); // Grade (e.g., 0.05 -> 500)
      command.setUint8(5, 50); // Crr (0.005 -> 50)
      command.setUint8(6, 12); // Cw (0.1225 -> 12)

      try {
        // Using command.buffer.toJS to pass the underlying ArrayBuffer
        await _controlPointCharacteristic!.writeValue(command.buffer.toJS).toDart;
      } catch (e) {
        print('Error setting simulation parameters: $e');
      }
    }
  }

  Future<void> setResistance(int resistance) async {
    if (_controlPointCharacteristic != null) {
      // Op Code 0x04 for Set Target Resistance Level
      // Resistance is a UINT8
      final command = Uint8List.fromList([0x04, resistance]);
      try {
        await _controlPointCharacteristic!.writeValue(command.toJS).toDart;
      } catch (e) {
        print('Error setting resistance: $e');
      }
    }
  }

  void disconnect() {
    _device?.gatt?.disconnect();
    _powerController.close();
  }
}

// Helper to get a property from a JSObject
@JS('Object.getOwnPropertyDescriptor(obj, prop).value')
external JSAny? getProperty(JSObject obj, JSString prop);