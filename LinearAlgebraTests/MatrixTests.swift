//
//  MatrixTests.swift
//  LinearAlgebra
//
//  Created by Pinkham, Jamie on 10/27/17.
//  Copyright © 2017 Jamie Pinkham. All rights reserved.
//

import XCTest
@testable import LinearAlgebra

class MatrixTests: XCTestCase {

    func testUnaryPlus() {
        let a = Matrix(elements: [[1, 2, 3], [6, 5, 4]])
        XCTAssertEqual(a.abs(), Matrix(elements: [[1, 2, 3], [6, 5, 4]]))
    }
    
    func testUnaryPlusOperator() {
        let a = Matrix(elements: [[1, 2, 3], [6, 5, 4]])
        XCTAssertEqual(+a, Matrix(elements: [[1, 2, 3], [6, 5, 4]]))
    }
    
    func testUnaryMinus() {
        let a = Matrix(elements: [[1, 2, 3], [6, 5, 4]])
        XCTAssertEqual(a.negate(), Matrix(elements: [[-1, -2, -3], [-6, -5, -4]]))
    }
    
    func testUnaryMinusOperator() {
        let a = Matrix(elements: [[1, 2, 3], [6, 5, 4]])
        XCTAssertEqual(-a, Matrix(elements: [[-1, -2, -3], [-6, -5, -4]]))
    }
    
    func testAdd() {
        
        let a = Matrix(elements: [[1, 2, 3], [6, 5, 4]])
        
        XCTAssertEqual(a.add(scalar: 1), Matrix(elements: [[2, 3, 4], [7, 6, 5]]))
        XCTAssertEqual(1 + a, Matrix(elements: [[2, 3, 4], [7, 6, 5]]))
        
        let b = Matrix(elements: [[0, 1, 2], [3, 4, 5]])
        XCTAssertEqual(a + b, Matrix(elements: [[1, 3, 5], [9, 9, 9]]))
    }
    

    func testSubtract() {
        
        let a = Matrix(elements: [[1, 2, 3], [6, 5, 4]])
        
        XCTAssertEqual(a - 1, Matrix(elements: [[0, 1, 2], [5, 4, 3]]))
        XCTAssertEqual(1 - a, Matrix(elements: [[0, -1, -2], [-5, -4, -3]]))
        
        let b = Matrix(elements: [[0, 1, 2], [3, 4, 5]])
        XCTAssertEqual(a - b, Matrix(elements: [[1, 1, 1], [3, 1, -1]]))
    }
    
    func testElementWiseProduct() {
        
        let a = Matrix(elements: [[1, 2, 3], [6, 5, 4]])
        
        XCTAssertEqual(a.multiply(scalar: 2), Matrix(elements: [[2, 4, 6], [12, 10, 8]]))
        XCTAssertEqual(2 * a, Matrix(elements: [[2, 4, 6], [12, 10, 8]]))
        
        let b = Matrix(elements: [[0, 1, 2], [3, 4, 5]])
        XCTAssertEqual(a.elementWise(matrix: b), Matrix(elements: [[0, 2, 6], [18, 20, 20]]))
        XCTAssertEqual(a .* b, Matrix(elements: [[0, 2, 6], [18, 20, 20]]))
    }
    
    func testElementWiseProductOperator() {
        
        let a = Matrix(elements: [[1, 2, 3], [6, 5, 4]])
        
        XCTAssertEqual(a * 2, Matrix(elements: [[2, 4, 6], [12, 10, 8]]))
        XCTAssertEqual(2 * a, Matrix(elements: [[2, 4, 6], [12, 10, 8]]))
        
        let b = Matrix(elements: [[0, 1, 2], [3, 4, 5]])
        XCTAssertEqual(a .* b, Matrix(elements: [[0, 2, 6], [18, 20, 20]]))
    }
    
    func testDivide() {
        let a = Matrix(elements: [[1, 2, 3], [6, 5, 4]])
        
        XCTAssertEqual(a / 2, Matrix(elements: [[0, 1, 1], [3, 2, 2]]))
        XCTAssertEqual(2 / a, Matrix(elements: [[2, 1, 0], [0, 0, 0]]))
        
//        let b = Matrix(elements: [[1, 1, 2], [3, 4, 5]])
//        XCTAssertEqual(try! a / b, Matrix(elements: [[1, 2, 1], [2, 1, 0]]))
    }
        
//    func testModulo() {
//        let a = Matrix(elements: [[1, 2, 3], [6, 5, 4]])
//
//        XCTAssertEqual(modulo(a, 2), Matrix(elements: [[1, 0, 1], [0, 1, 0]]))
//        XCTAssertEqual(modulo(3, a), Matrix(elements: [[0, 1, 0], [3, 3, 3]]))
//
//        let b = Matrix(elements: [[1, 1, 2], [3, 4, 5]])
//        XCTAssertEqual(modulo(a, b), Matrix(elements: [[0, 0, 1], [0, 1, 4]]))
//    }
//
//    func testModuloOperator() {
//        let a = Matrix(elements: [[1, 2, 3], [6, 5, 4]])
//
//        XCTAssertEqual(a % 2, Matrix(elements: [[1, 0, 1], [0, 1, 0]]))
//        XCTAssertEqual(3 % a, Matrix(elements: [[0, 1, 0], [3, 3, 3]]))
//
//        let b = Matrix(elements: [[1, 1, 2], [3, 4, 5]])
//        XCTAssertEqual(a % b, Matrix(elements: [[0, 0, 1], [0, 1, 4]]))
//    }

}
