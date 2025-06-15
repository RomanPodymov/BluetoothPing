//
//  CentralManagerInterface.swift
//  BluetoothPing
//
//  Created by Roman Podymov on 07/05/2024.
//  Copyright © 2024 BluetoothPing. All rights reserved.
//

import CoreBluetooth
import RxBluetoothKit
import RxSwift

enum CentralManagerError: Error {
    case resolverCancelled
    case peripheralNotFound
    case characteristicNotReadable
    case characteristicNotWritable
}

struct RPPeripheral {
    let identifier: UUID
    let name: String?
}

struct RPService {
    let identifier: CBUUID
    let name: String?
}

struct RPCharacteristic {
    let identifier: CBUUID
    let name: String?
}

struct MaxDataSize {
    let withResponse: Int?
    let withoutResponse: Int?

    init(withResponse: Int? = nil, withoutResponse: Int? = nil) {
        self.withResponse = withResponse
        self.withoutResponse = withoutResponse
    }
}

protocol CharacteristicDelegate: AnyObject {
    func onCharacteristicValueReceived(_: String)
    func onCharacteristicErrorReceived(_: CentralManagerError)
}

protocol CentralManagerInterface: AnyObject {
    typealias ConnectedPeripheral = Peripheral

    func start() -> Observable<ScannedPeripheral>
    func connect(to peripheral: Peripheral) -> Observable<ConnectedPeripheral>
    func readCharacteristicValue(characteristic: Characteristic) -> Single<String>
    func writeCharacteristicValueWithoutResponse(
        peripheral: Peripheral,
        characteristic: Characteristic,
        value: Data
    ) -> Single<Void>
    func writeCharacteristicValueWithResponse(
        peripheral: Peripheral,
        characteristic: Characteristic,
        value: Data
    ) -> Single<Void>
    func disconnect(_ peripheral: RPPeripheral)
    func maximumWriteValueLength(peripheral: Peripheral, characteristic: Characteristic) -> MaxDataSize
}
