//
//  CentralManager.swift
//  BluetoothPing
//
//  Created by Roman Podymov on 07/05/2024.
//  Copyright © 2024 BluetoothPing. All rights reserved.
//

import CoreBluetooth
import RxBluetoothKit
import RxSwift

final class CentralManager: NSObject {
    @MainActor
    static let shared = CentralManager()

    private var centralManager: CBCentralManager!

    private let manager = RxBluetoothKit.CentralManager()
    private var connection: Disposable?
    private let scannedPeripheralSubject = PublishSubject<ScannedPeripheral>()
}

extension CentralManager: CentralManagerInterface {
    func start() -> Observable<ScannedPeripheral> {
        let managerIsOn = manager.observeStateWithInitialValue()
            .filter { $0 == .poweredOn }
            .compactMap { [weak self] _ in self?.manager }

        connection = managerIsOn
            .flatMap { $0.scanForPeripherals(withServices: nil) }
            .subscribe(scannedPeripheralSubject)

        return scannedPeripheralSubject
    }

    func connect(to peripheral: Peripheral) -> Observable<ConnectedPeripheral> {
        peripheral.establishConnection()
    }

    public final func readCharacteristicValue(
        characteristic: Characteristic
    ) -> Single<String> {
        characteristic.readValue().map {
            String(data: $0.value ?? .init(), encoding: .utf8) ?? ""
        }
    }

    func writeCharacteristicValueWithoutResponse(
        peripheral: Peripheral,
        characteristic: Characteristic,
        value: Data
    ) -> Single<Void> {
        peripheral.writeValue(
            value,
            for: characteristic,
            type: .withoutResponse,
            canSendWriteWithoutResponseCheckEnabled: true
        ).map { _ in
            ()
        }
    }

    func writeCharacteristicValueWithResponse(
        peripheral: Peripheral,
        characteristic: Characteristic,
        value: Data
    ) -> Single<Void> {
        peripheral.writeValue(
            value,
            for: characteristic,
            type: .withResponse,
            canSendWriteWithoutResponseCheckEnabled: true
        ).map { _ in
            ()
        }
    }

    func maximumWriteValueLength(peripheral: Peripheral, characteristic: Characteristic) -> MaxDataSize {
        .init(
            withResponse: characteristic.properties.contains(.write) ?
                peripheral.maximumWriteValueLength(for: .withResponse) :
                nil,
            withoutResponse: characteristic.properties.contains(.writeWithoutResponse) ?
                peripheral.maximumWriteValueLength(for: .withoutResponse) :
                nil
        )
    }
}
