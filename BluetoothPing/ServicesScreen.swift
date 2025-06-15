//
//  ServicesScreen.swift
//  BluetoothPing
//
//  Created by Roman Podymov on 05/05/2024.
//  Copyright © 2024 BluetoothPing. All rights reserved.
//

import CoreBluetooth
import Eureka
import Resolver
import RxBluetoothKit
import RxSwift
import UIKit

struct ServicesScreenData {
    let peripheral: Peripheral
}

final class ServicesScreen: FormViewController {
    private unowned var section: Section!

    @Injected private var centralManager: CentralManagerInterface

    private let disposeBag = DisposeBag()
    public var data: ServicesScreenData? {
        didSet {
            if let data {
                centralManager.connect(to: data.peripheral)
                    .subscribe(
                        onNext: { [weak self] in
                            self?.loadServices(peripheral: $0)
                        },
                        onError: {
                            print($0)
                        },
                        onCompleted: {}
                    )
                    .disposed(by: disposeBag)
            }
        }
    }

    private func loadServices(peripheral: Peripheral) {
        peripheral.discoverServices(nil)
            .subscribe(
                onSuccess: { [weak self] in
                    self?.onServicesReceived($0)
                },
                onFailure: {
                    print($0)
                },
                onDisposed: nil
            )
            .disposed(by: disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let section = Section(L10n.Section.service)
        form +++ section
        self.section = section
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)

        if parent == nil, let peripheral = data?.peripheral {}
    }
}

extension ServicesScreen {
    func onServicesReceived(_ services: [Service]) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            for service in services {
                section <<< LabelRow(service.service.uuid.uuidString) { row in
                    row.title = service.service.uuid.uuidString
                }.onCellSelection { [weak self] _, _ in
                    guard let self, let data else { return }

                    let controller = CharacteristicsScreen()
                    navigationController?.pushViewController(controller, animated: true)
                    controller.data = .init(peripheral: data.peripheral, service: service)
                }
            }
        }
    }
}
