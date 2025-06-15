//
//  CharacteristicScreen.swift
//  BluetoothPing
//
//  Created by Roman Podymov on 08/05/2024.
//  Copyright © 2024 BluetoothPing. All rights reserved.
//

import CoreBluetooth
import Eureka
import Resolver
import RxBluetoothKit
import RxSwift

struct CharacteristicScreenData {
    let peripheral: Peripheral
    let characteristic: Characteristic
}

enum CharacteristicScreenTag: String, CaseIterable {
    case value
    case maxWriteSize
    case writeWithoutResponse
    case writeWithResponse
}

final class CharacteristicScreen: FormViewController {
    private unowned var section: Section!

    @Injected private var centralManager: CentralManagerInterface

    var maxSizes: MaxDataSize? {
        didSet {
            createRows(
                value: readValue ?? "",
                maxSizes: maxSizes ?? .init()
            )
        }
    }

    var readValue: String? {
        didSet {
            createRows(
                value: readValue ?? "",
                maxSizes: maxSizes ?? .init()
            )
        }
    }

    private let disposeBag = DisposeBag()
    var data: CharacteristicScreenData? {
        didSet {
            if let data {
                centralManager.readCharacteristicValue(
                    characteristic: data.characteristic
                )
                .subscribe(
                    onSuccess: { [weak self] in
                        self?.readValue = $0
                    },
                    onFailure: nil,
                    onDisposed: nil
                ).disposed(by: disposeBag)

                maxSizes = centralManager.maximumWriteValueLength(
                    peripheral: data.peripheral,
                    characteristic: data.characteristic
                )
            }
        }
    }

    var isCancelled = false

    override func viewDidLoad() {
        super.viewDidLoad()

        let section = Section(L10n.Section.characteristic)
        form +++ section
        self.section = section
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        isCancelled = true
    }
}

extension CharacteristicScreen: CharacteristicDelegate {
    func onCharacteristicValueReceived(_ value: String) {
        readValue = value
    }

    func onCharacteristicErrorReceived(_ error: CentralManagerError) {
        readValue = switch error {
        case .characteristicNotReadable:
            L10n.Section.characteristicErrorRead
        case .characteristicNotWritable:
            L10n.Section.characteristicErrorWrite
        case .resolverCancelled:
            ""
        case .peripheralNotFound:
            ""
        }
    }

    private func createRows(value: String, maxSizes _: MaxDataSize) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            section.removeAll(type: CharacteristicScreenTag.self)

            section <<< LabelRow(CharacteristicScreenTag.value.rawValue) { row in
                row.title = L10n.Section.characteristicValue
                row.value = value
            } <<< LabelRow(CharacteristicScreenTag.maxWriteSize.rawValue) { [weak self] row in
                row.title = L10n.Section.characteristicMax
                let withResponse = self?.maxSizes?.withResponse.map { String($0) } ?? "N/A"
                let withoutResponse = self?.maxSizes?.withoutResponse.map { String($0) } ?? "N/A"
                row.value = withResponse +
                    " " +
                    withoutResponse
            }

            section <<< ButtonRow(CharacteristicScreenTag.writeWithResponse.rawValue) { [weak self] row in
                row.title = L10n.Section.characteristicWriteWithResponse
                row.onCellSelection { [weak self] _, _ in
                    guard let self, let data else { return }

                    ping(data: data, bytesCount: maxSizes?.withResponse ?? 0)
                }
            }

            section <<< ButtonRow(CharacteristicScreenTag.writeWithoutResponse.rawValue) { [weak self] row in
                row.title = L10n.Section.characteristicWriteWithoutResponse
                row.onCellSelection { [weak self] _, _ in
                    guard let self, let data else { return }

                    ping(data: data, bytesCount: maxSizes?.withoutResponse ?? 0)
                }
            }
        }
    }

    private func ping(data: CharacteristicScreenData, bytesCount: Int) {
        promise(data: data, bytesCount: bytesCount, bytes: [0])
            .subscribe(
                onSuccess: { [weak self] in
                    print($0)
                },
                onFailure: nil,
                onDisposed: nil
            ).disposed(by: disposeBag)
    }

    private func promise(data: CharacteristicScreenData, bytesCount: Int, bytes: [UInt8]) -> Single<[UInt8]> {
        promise(
            for: bytes,
            data: data
        ).flatMap { [weak self] nextResult in
            if nextResult.count > bytesCount || self?.isCancelled ?? false {
                return Observable.just([]).asSingle()
            } else {
                return self?.promise(data: data, bytesCount: bytesCount, bytes: nextResult) ?? Observable.just([]).asSingle()
            }
        }
    }

    private func promise(for result: [UInt8], data: CharacteristicScreenData) -> Single<[UInt8]> {
        centralManager.writeCharacteristicValueWithoutResponse(
            peripheral: data.peripheral,
            characteristic: data.characteristic,
            value: Data(result)
        ).map {
            let nextResult = generateData(previousResult: result)
            return nextResult
        }.delay(
            .milliseconds(10),
            scheduler: Self.scheduler
        )
    }

    private static let scheduler = SerialDispatchQueueScheduler(qos: .background, internalSerialQueueName: "")
}

extension Section {
    func removeAll(type: (some CaseIterable & RawRepresentable).Type) {
        for item in type.allCases {
            removeAll(where: { $0.tag == item.rawValue as? String })
        }
    }
}

func generateData(previousResult: [UInt8] = [0]) -> [UInt8] {
    let last = previousResult.last!
    if last == UInt8.max {
        return previousResult + [0]
    } else {
        return previousResult.prefix(previousResult.count - 1) + [last + 1]
    }
}
