//
//  LinearAlgebraTests.swift
//  LinearAlgebraTests
//
//  Created by Pinkham, Jamie on 10/25/17.
//  Copyright © 2017 Jamie Pinkham. All rights reserved.
//

import XCTest
import LinearAlgebra

class PerformanceTests: XCTestCase {
    
    let a = Matrix.random(rows: 1000, columns: 1000)
    let b = Matrix.random(rows: 1000, columns: 1000)
    let x = Vector.random(count: 1000000)
    let y = Vector.random(count: 1000000)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInvert() {
        measure {
            do {
                _ = try self.a.inversed()
            } catch {
                print("non-invertible matrix")
            }
        }
    }
    
//    func testCholesky() {
//        let aTa = transpose(a) * a
//        measure {
//            _ = chol(aTa)
//        }
//    }
    
    func testDot() {
        measure {
            _ = self.x * self.y
        }
    }
    
    func testTranspose() {
        measure {
            _ = self.a.transposed()
        }
    }
    
    func testMultiply() {
        measure {
            _ = self.a * self.b
        }
    }
    
    func testSigmoid() {
        measure {
            _ = 1 / (1 + (-self.a).exp())
        }
    }
    
    func testReLU() {
        measure {
            _ = self.a.threshold(0.0)
        }
    }
    
}
