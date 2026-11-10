//
//  BluetoothPingTests.swift
//  BluetoothPing
//
//  Created by Roman Podymov on 19/06/2025.
//  Copyright © 2025 BluetoothPing. All rights reserved.
//

@testable import BluetoothPingApp
import XCTest

final class BluetoothPingTests: XCTestCase {
    func testDefaultPacketStartsWithOne() {
        XCTAssertEqual(generateData(), [1])
    }

    func testEmptyPacketStartsWithZero() {
        XCTAssertEqual(generateData(previousResult: []), [0])
    }

    func testIncrementsLastByteWithoutChangingPrefix() {
        XCTAssertEqual(generateData(previousResult: [12, 34, 56]), [12, 34, 57])
    }

    func testByteBeforeMaximumDoesNotGrowPacket() {
        XCTAssertEqual(generateData(previousResult: [254]), [255])
    }

    func testMaximumByteAppendsZeroWithoutOverflow() {
        XCTAssertEqual(generateData(previousResult: [255]), [255, 0])
        XCTAssertEqual(generateData(previousResult: [12, 255]), [12, 255, 0])
    }

    func testSequenceReachesNextPacketSize() {
        var packet: [UInt8] = [0]

        for expected in 1 ... 255 {
            packet = generateData(previousResult: packet)
            XCTAssertEqual(packet, [UInt8(expected)])
        }

        packet = generateData(previousResult: packet)
        XCTAssertEqual(packet, [255, 0])
        XCTAssertEqual(generateData(previousResult: packet), [255, 1])
    }
}
