//
//  BasicScreen.swift
//  BluetoothPing
//
//  Created by Roman Podymov on 18/06/2025.
//  Copyright © 2025 BluetoothPing. All rights reserved.
//

import Eureka
import Resolver
import RxSwift
import UIKit

class BasicScreen: FormViewController {
    let disposeBag = DisposeBag()
    @Injected var centralManager: CentralManagerInterface
    unowned var section: Section!
}
