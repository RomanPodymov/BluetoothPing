//
//  CharacteristicsScreen.swift
//  BluetoothPing
//
//  Created by Roman Podymov on 07/05/2024.
//  Copyright © 2024 BluetoothPing. All rights reserved.
//

import Dispatch
import Eureka
import Resolver
import RxBluetoothKit
import RxSwift

struct CharacteristicsScreenData {
    let peripheral: Peripheral
    let service: Service
}

final class CharacteristicsScreen: BasicScreen {
    var data: CharacteristicsScreenData? {
        didSet {
            if let data {
                loadCharacteristics(service: data.service)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let section = Section(L10n.Section.characteristics)
        form +++ section
        self.section = section
    }

    private func loadCharacteristics(service: Service) {
        service.discoverCharacteristics(nil)
            .subscribe(
                onSuccess: { [weak self] in
                    self?.onCharacteristicsReceived($0)
                },
                onFailure: nil,
                onDisposed: nil,
            )
            .disposed(by: disposeBag)
    }
}

extension CharacteristicsScreen {
    func onCharacteristicsReceived(_ characteristics: [Characteristic]) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            for characteristic in characteristics {
                section <<< LabelRow(characteristic.characteristic.uuid.uuidString) { row in
                    row.title = characteristic.characteristic.uuid.uuidString
                }.onCellSelection { [weak self] _, _ in
                    guard let self, let data else { return }

                    let controller = CharacteristicScreen()
                    navigationController?.pushViewController(controller, animated: true)
                    controller.data = .init(
                        peripheral: data.peripheral,
                        characteristic: characteristic,
                    )
                }
            }
        }
    }
}
