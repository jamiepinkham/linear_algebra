//
//  LinearAlgebraTests.swift
//  LinearAlgebraTests
//
//  Created by Jamie Pinkham on 10/25/17.
//  Copyright © 2017 Jamie Pinkham. All rights reserved.
//

@testable import LinearAlgebra
import XCTest

class VectorTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEquality() {
        let v1: Vector = [1.0, 2.0]
        let v2: Vector = [1.0, 2.0]
        XCTAssertEqual(v1, v2)
    }
    
    func testInequality() {
        let v1: Vector = [1.0, 2.0]
        let v2: Vector = [1.0, 4.0]
        XCTAssertTrue(v1 != v2)
    }
    
    func testLessGreaterThan() {
        let v1: Vector = [11.0, 12.0]
        let v2: Vector = [1.0, 2.0]
        XCTAssertTrue(v1 > v2)
        XCTAssertTrue(v2 < v1)
    }
    
    func testLessThanGreaterEqualToThan() {
        let v1: Vector = [11.0, 12.0]
        let v2: Vector = [1.0, 2.0]
        let v3: Vector = [1.0, 2.0]
        XCTAssertTrue(v1 >= v2)
        XCTAssertTrue(v2 <= v1)
        XCTAssertTrue(v2 >= v3)
        XCTAssertTrue(v2 <= v3)
    }
    
    func testAddition() {
        let vec1: Vector = [1.0, 2.0, 3.0]
        let vec2: Vector = [4.0, 5.0, 6.0]
        let res: Vector = [5.0, 7.0, 9.0]
        XCTAssertEqual(vec1 + vec2, res)
    }
    
    func testSubtraction() {
        let vec1: Vector = [1.0, 2.0, 3.0]
        let vec2: Vector = [4.0, 5.0, 6.0]
        let res: Vector = [-3.0, -3.0, -3.0]
        XCTAssertEqual(vec1 - vec2, res)
    }
    
    func testMultiplication() {
        let vec1: Vector = [1.0, 2.0, 3.0]
        let vec2: Vector = [4.0, 5.0, 6.0]
        let res: Vector = [4.0, 10.0, 18.0]
        XCTAssertEqual(vec1 .* vec2, res)
    }
    
    func testDivision() {
        let vec1: Vector = [1.0, 2.0, 3.0]
        let vec2: Vector = [4.0, 5.0, 6.0]
        let res: Vector = [1.0 / 4.0, 2.0 / 5.0, 3.0 / 6.0]
        XCTAssertEqual((vec1 / vec2), res)
    }
    
    func testScalarAddition() {
        let vec: Vector = [1.0, 2.0, 3.0]
        let s = 7.0
        let res: Vector = [8.0, 9.0, 10.0]
        XCTAssertEqual(vec + s, res)
        XCTAssertEqual(s + vec, res)
    }
    
    func testScalarSubtraction() {
        let vec: Vector = [1.0, 2.0, 3.0]
        let s = 7.0
        let res1: Vector = [-6.0, -5.0, -4.0]
        let res2: Vector = [6.0, 5.0, 4.0]
        XCTAssertEqual(vec - s, res1)
        XCTAssertEqual(s - vec, res2)
    }
    
    func testScalarMultiplication() {
        let vec: Vector = [1.0, 2.0, 3.0]
        let s = 7.0
        let res: Vector = [7.0, 14.0, 21.0]
        XCTAssertEqual(vec * s, res)
        XCTAssertEqual(s * vec, res)
    }
    
    func testScalarDivision() {
        let vec: Vector = [1.0, 2.0, 3.0]
        let s = 7.0
        let res1: Vector = [1.0 / 7.0, 2.0 / 7.0, 3.0 / 7.0]
        let res2: Vector = [7.0 / 1.0, 7.0 / 2.0, 7.0 / 3.0]
        XCTAssertEqual(vec / s, res1)
        XCTAssertEqual(s / vec, res2)
    }
    
    func testAbs() {
        let vec: Vector = [1.0, -2.0, 3.0]
        let res: Vector = [1.0, 2.0, 3.0]
        XCTAssertEqual(vec.absolute(), res)
    }
    
    func testNegate() {
        let vec: Vector = [1.0, -2.0, 3.0]
        let res: Vector = [-1.0, 2.0, -3.0]
        XCTAssertEqual(-vec, res)
    }
    
    func testThreshold() {
        let vec: Vector = [1.0, -2.0, 3.0]
        let res: Vector = [1.0, 0.0, 3.0]
        XCTAssertEqual(vec.threshold(0.0), res)
    }
    
    func testDotProduct() {
        let vec1: Vector = [1.0, 2.0, 3.0]
        let vec2: Vector = [4.0, 5.0, 6.0]
        let res = 32.0
        XCTAssertEqual((vec1 * vec2), res)
    }
    
    func testPower() {
        let vec: Vector = [1.0, 2.0, 3.0]
        let p = 3.0
        let res: Vector = [1.0, 8.0, 27.0]
        XCTAssertEqual(vec ^ p, res)
    }
    
    func testSquareRoot() {
        let vec: Vector = [1.0, 2.0, 3.0]
        let res: Vector = [sqrt(1.0), sqrt(2.0), sqrt(3.0)]
        XCTAssertEqual(vec.squareRoot(), res)
        XCTAssertEqual(vec.squareRoot(), vec ^ 0.5)
    }
    
    func testExp() {
        let vec: Vector = [1.0, 2.0, 3.0]
        let res: Vector = [exp(1.0), exp(2.0), exp(3.0)]
        XCTAssertEqual(vec.exp(), res)
    }
    
    func testLog() {
        let vec: Vector = [1.0, 2.0, 3.0]
        let res: Vector = [log(1.0), log(2.0), log(3.0)]
        XCTAssertEqual(vec.log(), res)
    }
    
    func testLog2() {
        let vec: Vector = [1.0, 2.0, 3.0]
        let res: Vector = [log2(1.0), log2(2.0), log2(3.0)]
        XCTAssertEqual(vec.log2(), res)
    }
    
    func testLog10() {
        let vec: Vector = [1.0, 2.0, 3.0]
        let res: Vector = [log10(1.0), log10(2.0), log10(3.0)]
        XCTAssertEqual(vec.log10(), res)
    }
    
//    func testVectorMagnitude() {
//        let v1: Vector = [-0.221, 7.437]
//        let v2: Vector = [8.813, -1.331, -6.247]
//
//        print(v1.magnitude)
//        print(v2.magnitude)
//    }
//
//    func testVectorNormalization() {
//        let v1: Vector = [5.581, -2.136]
//        print(v1.normalize())
//        let v2: Vector = [1.996, 3.108, -4.554]
//        print(v2.normalize())
//    }
    
    func testSubscripting() {
        
    }
    
}
