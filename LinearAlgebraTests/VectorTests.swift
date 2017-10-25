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
    
    let v1: Vector = [1.0, 2.0, 3.0]
    let v2: Vector = [1.0, 2.0, 3.0]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testVectorAddition() {
        var v1 = self.v1
        print(v1 += v2)
    }
    
    func testVectorSubtraction() {
        
    }
    
    func testVectorMultiplication() {
        
    }
    
    func testVectorDivision() {
        
    }
    
    func testScalarAddition() {
        
    }
    
    func testScalarSubtraction() {
        
    }
    
    func testScalarMultiplication() {
        
    }
    
    func testScalarDivision() {
        
    }
    
    func testAbs() {
        
    }
    
    func testUnaryMinus() {
        
    }
    
    func testThreshold() {
        
    }
    
    func testPower() {
        
    }
    
    func testSquareRoot() {
        
    }
    
    func testExp() {
        
    }
    
    func testLog() {
        
    }
    
    func testLog2() {
        
    }
    
    func testLog10() {
        
    }
    
    func testVectorMagnitude() {
        let v1: Vector = [-0.221, 7.437]
        let v2: Vector = [8.813, -1.331, -6.247]
        
        print(v1.magnitude)
        print(v2.magnitude)
    }
    
    func testVectorNormalization() {
        let v1: Vector = [5.581, -2.136]
        print(v1.normalize())
        let v2: Vector = [1.996, 3.108, -4.554]
        print(v2.normalize())
    }
    
    func testSubscripting() {
        
    }
    
}
