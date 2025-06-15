//
//  TestCentralManager.swift
//  BluetoothPing
//
//  Created by Roman Podymov on 07/05/2024.
//  Copyright © 2024 BluetoothPing. All rights reserved.
//

import Foundation
import RxBluetoothKit
import RxSwift

final class TestCentralManager {
    static let shared = TestCentralManager()

    private init() {}

    private weak var characteristicDelegate: CharacteristicDelegate?
}

extension TestCentralManager: CentralManagerInterface {
    func start() -> Observable<ScannedPeripheral> {
        Observable.just({
            fatalError()
        }())
    }

    func connect(to _: Peripheral) -> Observable<ConnectedPeripheral> {
        Observable.just({
            fatalError()
        }())
    }

    func readCharacteristicValue(characteristic _: Characteristic) -> Single<String> {
        Observable.just("").asSingle()
    }

    func writeCharacteristicValueWithoutResponse(
        peripheral _: Peripheral,
        characteristic _: Characteristic,
        value _: Data
    ) -> Single<Void> {
        Observable.just(()).asSingle()
    }

    func writeCharacteristicValueWithResponse(
        peripheral _: Peripheral,
        characteristic _: Characteristic,
        value _: Data
    ) -> Single<Void> {
        Observable.just(()).asSingle()
    }

    func maximumWriteValueLength(peripheral _: Peripheral, characteristic _: Characteristic) -> MaxDataSize {
        .init()
    }

    func disconnect(_: RPPeripheral) {}
}
