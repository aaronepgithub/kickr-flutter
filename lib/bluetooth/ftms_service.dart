import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:kickr_flutter/bluetooth/web_bluetooth_service.dart';

class FtmsService {
  BluetoothDevice? _device;

  static const String ftmsServiceUUID = '00001826-0000-1000-8000-00805f9b34fb';
  static const String indoorBikeDataCharacteristicUUID =
      '00002ad2-0000-1000-8000-00805f9b34fb';
  static const String fitnessMachineControlPointCharacteristicUUID =
      '00002ad9-0000-1000-8000-00805f9b34fb';

  final StreamController<int> _powerController =
      StreamController<int>.broadcast();
  Stream<int> get powerStream => _powerController.stream;

  BluetoothRemoteGATTCharacteristic? _controlPointCharacteristic;

  Future<bool> connect() async {
    final bt = bluetooth;
    if (bt == null) {
      print('Web Bluetooth not available');
      return false;
    }

    final filters = [
      BluetoothScanFilter(services: [ftmsServiceUUID.toJS].toJS),
    ];
    final jsFilters = JSArray<JSAny?>.withLength(filters.length);
    for (var i = 0; i < filters.length; i++) {
        jsFilters[i] = filters[i];
    }

    final options = RequestOptions(
      filters: jsFilters,
      optionalServices: [ftmsServiceUUID.toJS].toJS,
    );

    try {
      final device = (await bt.requestDevice(options).toDart) as BluetoothDevice?;
      _device = device;
      if (_device == null) return false;

      await _device!.gatt!.connect().toDart;
      final service = (await _device!.gatt!
          .getPrimaryService(ftmsServiceUUID.toJS)
          .toDart) as BluetoothRemoteGATTService;

      _controlPointCharacteristic = (await service
          .getCharacteristic(fitnessMachineControlPointCharacteristicUUID.toJS)
          .toDart) as BluetoothRemoteGATTCharacteristic;
      final indoorBikeDataCharacteristic = (await service
          .getCharacteristic(indoorBikeDataCharacteristicUUID.toJS)
          .toDart) as BluetoothRemoteGATTCharacteristic;

      await indoorBikeDataCharacteristic.startNotifications().toDart;
      indoorBikeDataCharacteristic.oncharacteristicvaluechanged =
          (Event event) {
        final characteristic =
            event.target as BluetoothRemoteGATTCharacteristic;
        final value = characteristic.value;
        if (value != null) {
          final power = value.getInt16(2, true);
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
      final command = Uint8List.fromList([0x00]);
      try {
        await _controlPointCharacteristic!.writeValue(command.buffer.toJS).toDart;
      } catch (e) {
        print('Error requesting control: $e');
      }
    }
  }

  Future<void> setSimulationParameters(double grade) async {
    if (_controlPointCharacteristic != null) {
      final command = ByteData(5);
      command.setUint8(0, 0x11);
      command.setInt16(1, (grade * 100).round(), Endian.little);
      command.setInt16(3, 0, Endian.little);

      try {
        await _controlPointCharacteristic!.writeValue(command.buffer.toJS).toDart;
      } catch (e) {
        print('Error setting simulation parameters: $e');
      }
    }
  }

  Future<void> setResistance(int resistance) async {
    if (_controlPointCharacteristic != null) {
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