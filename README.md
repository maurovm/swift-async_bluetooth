# AsyncBluetooth

Swift Package that replicates some of the functionality provided by
Apple's CoreBluetooth module, but using Swift's latest async/await
concurrency features 

---

AsyncBluetooth is free software: you can redistribute it or modify
it under the terms of the GNU General Public License as published by the
Free Software Foundation, version 2 only. Please check the file
[COPYING](COPYING) for more information on the license and copyright.

If you want to submit pull requests or contribute source code to this 
repository, please read the [CONTRIBUTING.md](CONTRIBUTING.md) for
more information about contributing guidelines.

If you use this app in your projects and publish the results, please cite the
following manuscript:

> Villarroel, M. and Davidson, S. "Open-source software mobile platform for
physiological data acquisition". arXiv (In preparation). 2022

---

Examples of other applications making use of the above Swift Packages are:

- [swift-async_pulse_ox](https://github.com/maurovm/swift-async_pulse_ox): 
A Swift Package containing the functionality to connect and record time-series
data from devices that support Bluetooth Low Energy (BLE) protocol, such as
heart rate monitors and pulse oximeters. Examples of supported time-series are
heart rate, peripheral oxygen saturation (SpO<sub>2</sub>), Photoplethysmogram
(PPG), battery status and more.
- [swift-pulse_ox_recorder](https://github.com/maurovm/swift-pulse_ox_recorder):
The companion application (XCode, Settings.bundle, etc) to record time-series
data from devices that support Bluetooth Low Energy (BLE) protocol.


## Connecting to Bluetooth devices


The API is similar to CoreBluetooth. You start by creating the Central Manager
and wait until is ready to use:

```swift
let central_manager  = ASB_central_manager()
try await central_manager.wait_until_is_powered_on()
```

Once the Bluetooth service is ready, you can scan for all available BLE 
peripherals with:

```swift
for try await peripheral in await central_manager.scan_for_peripherals()
{
    // use the peripheral
}
```

or search for specific peripherals:

```swift
for try await peripheral in await central_manager.scan_for_peripherals().filter{ $0.name == "XXXX"}
{
    // use the peripheral
}
```

If you want to stop the scanning process, you can call:

```swift
await central_manager.stop_scan()
```

To connect or disconnect from a peripheral:

```swift
try await central_manager.connect(peripheral)
// to disconnect
try await central_manager.disconnect(peripheral)
```

To discover services and characteristics for a given peripheral:

```swift
let all_services = try await peripheral.discover_services()
let all_characteristics = try await peripheral.discover_characteristics(nil, for: service)
```

Data sent by a BLE device is wrapped in a struct, containing the arrival
timestamp for packet received, using the following struct:

```swift
public struct ASB_data
{   
    public let timestamp : ASB_timestamp
    public let data      : Data          // the actual data
}


public typealias ASB_timestamp = UInt64 // Epoch/Unix timestamp in nanoseconds
```

Once you are connected to a BLE peripheral, you can just simply read the value
of a Characteristic by:

```swift
let value = try await peripheral.read_value(for: characteristic)
```

Or receive continous values in real-time by simply iterating over the 
data stream:


```swift
let data_stream = try await peripheral.notification_values(for: characteristic)

// data_stream is of type AsyncThrowingStream<ASB_data, Error> 


for try await ble_data in data_stream
{
    // process ble_data
}
```

to stop receiveing dta you either exit the loop, or call:

```swift
await peripheral.stop_notifications(from: characteristic)
```

Check the Swift Package [swift-async_pulse_ox](https://github.com/maurovm/swift-async_pulse_ox) 
and the application [swift-pulse_ox_recorder](https://github.com/maurovm/swift-pulse_ox_recorder) 
for examples on how to use the "AsyncBluetooth" module.
