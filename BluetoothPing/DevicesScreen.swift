//
//  DevicesScreen.swift
//  BluetoothPing
//
//  Created by Roman Podymov on 07/05/2024.
//  Copyright © 2024 BluetoothPing. All rights reserved.
//

import CoreBluetooth
import Eureka
import Resolver
import RxBluetoothKit
import RxSwift

class BasicScreen: FormViewController {
    let disposeBag = DisposeBag()
    @Injected var centralManager: CentralManagerInterface
}

final class DevicesScreen: BasicScreen {
    private unowned var section: Section!

    private var scannedPeripherals: [ScannedPeripheral] = [] {
        didSet {
            let per = scannedPeripherals.map(\.peripheral)
            for item in per {
                onPeripheralReceived(item)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let section = Section(L10n.Section.device)
        form +++ section
        self.section = section

        centralManager.start()
            .filter { [weak self] newPeripheral in
                guard let self else { return false }
                return !scannedPeripherals.contains(where: {
                    $0.peripheral.identifier == newPeripheral.peripheral.identifier
                })
            }
            .subscribe { [weak self] in
                self?.scannedPeripherals.append($0)
            }
            .disposed(by: disposeBag)
    }
}

extension DevicesScreen {
    func onPeripheralReceived(_ peripheral: Peripheral) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            guard !section.contains(where: {
                $0.tag == peripheral.identifier.uuidString
            }) else {
                return
            }

            section <<< LabelRow(peripheral.identifier.uuidString) { row in
                row.title = (peripheral.name.map { $0 + " " } ?? "") + peripheral.identifier.uuidString
            }.onCellSelection { [weak self] _, _ in
                let controller = ServicesScreen()
                self?.navigationController?.pushViewController(controller, animated: true)
                controller.data = .init(peripheral: peripheral)
            }
        }
    }
}
