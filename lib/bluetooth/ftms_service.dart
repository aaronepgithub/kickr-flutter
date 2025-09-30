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
      final device = await bt.requestDevice(options).toDart;
      _device = device as BluetoothDevice?;
      if (_device == null) return false;

      await _device!.gatt!.connect().toDart;
      final service = await _device!.gatt!.getPrimaryService(ftmsServiceUUID.toJS).toDart as BluetoothRemoteGATTService;

      // Get characteristics
      _controlPointCharacteristic = await service.getCharacteristic(fitnessMachineControlPointCharacteristicUUID.toJS).toDart as BluetoothRemoteGATTCharacteristic;
      final indoorBikeDataCharacteristic = await service.getCharacteristic(indoorBikeDataCharacteristicUUID.toJS).toDart as BluetoothRemoteGATTCharacteristic;

      // Subscribe to power notifications
      await indoorBikeDataCharacteristic.startNotifications().toDart;
      indoorBikeDataCharacteristic.oncharacteristicvaluechanged = (Event event) {
        final characteristic = event.target as EventTarget;
        final value = characteristic.value;
        if (value != null) {
          final power = value.getInt16(2, true); // littleEndian = true
          _powerController.add(power);
        }
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
        await _controlPointCharacteristic!.writeValue(command.buffer.toJS).toDart;
        print("Requested FTMS control");
      } catch (e) {
        print('Error requesting control: $e');
      }
    }
  }

  Future<void> setSimulationParameters(double grade) async {
    if (_controlPointCharacteristic != null) {
      // Op Code 0x11 for Set Indoor Bike Simulation Parameters
      final command = ByteData(5);
      command.setUint8(0, 0x11);
      // Wind Speed and Crr are not used in the simplified command
      command.setInt16(1, (grade * 100).round(), Endian.little); // Grade scaled by 100
      command.setInt16(3, 0, Endian.little); // Crr set to 0

      try {
        await _controlPointCharacteristic!.writeValue(command.buffer.toJS).toDart;
      } catch (e) {
        print('Error setting simulation parameters: $e');
      }
    }
  }

  Future<void> setResistance(int resistance) async {
    if (_controlPointCharacteristic != null) {
      // Op Code 0x04 for Set Target Resistance Level
      final command = Uint8List.fromList([0x04, resistance]);
      try {
        await _controlPointCharacteristic!.writeValue(command.buffer.toJS).toDart;
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