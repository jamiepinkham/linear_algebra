//
//  Matrix.swift
//  LinearAlgebra
//
//  Created by Pinkham, Jamie on 10/25/17.
//  Copyright © 2017 Jamie Pinkham. All rights reserved.
//

import Foundation
import Accelerate

enum MatrixAlgebraError: Error {
    case nonInvertible
    case nonZeroPower
}

public struct Matrix {
    
    public enum Dimension {
        case row
        case column
    }
    
    var values: [Double]
    public let rows: Int
    public let columns: Int
    //MARK: internal initializers
    init(rows r: Int, columns c: Int, values v: [Double]) {
        precondition(r * c == v.count, "Matrix dimensions must agree")
        values = v
        rows = r
        columns = c
    }
    
    init(rows r: Int, columns c: Int, repeating value: Double = 0.0) {
        precondition(r > 0 && c > 0, "Matrix dimensions must be positive")
        values = Array(repeating: value, count: r * c)
        rows = r
        columns = c
    }
    //MARK: public initializers
    public init(matrix other: Matrix) {
        values = other.values
        rows = other.rows
        columns = other.columns
    }
    
    public init(vector: Vector) {
        values = vector.values
        rows = 1
        columns = vector.values.count
    }
    
    public init(elements: [Double]...) {
        self.init(rows: elements.count, columns: elements[0].count, repeating: 0.0)
        
        for (i, row) in elements.enumerated() {
            precondition(row.count == columns, "All rows should have the same number of columns")
            values.replaceSubrange(i*columns ..< (i + 1)*columns, with: row)
        }
    }
    
    public init(elements: [[Double]]) {
        self.init(rows: elements.count, columns: elements[0].count, repeating: 0.0)
        
        for (i, row) in elements.enumerated() {
            precondition(row.count == columns, "All rows should have the same number of columns")
            values.replaceSubrange(i*columns ..< (i + 1)*columns, with: row)
        }
    }
    //MARK: helper initializers
    public static func zeros(rows: Int, columns: Int) -> Matrix {
        precondition(rows > 0 && columns > 0, "must have positive rows and columns")
        return Matrix(rows: rows, columns: columns, repeating: 0.0)
    }
    
    public static func ones(rows: Int, columns: Int) -> Matrix {
        precondition(rows > 0 && columns > 0, "must have positive rows and columns")
        return Matrix(rows: rows, columns: columns, repeating: 1.0)
    }
    
    public static func eye(rows: Int, columns: Int) -> Matrix {
        let vectors: [[Double]] = (0..<rows).map { i in
            var row = Array(repeating: 0.0, count: columns)
            if (i < columns) {
                row[i] = 1.0
            }
            return row
        }
        return Matrix(elements: vectors)
        
    }
    
    public static func random(rows: Int, columns: Int) -> Matrix {
        let values = LinearAlgebra.random(from: 0.0...4096.0, count: rows * columns)
        return Matrix(rows: rows, columns: columns, values: values)
    }
    //MARK: insertion methods
    public func insert(matrix: Matrix, at index: Int) -> Matrix {
        precondition(matrix.columns == self.columns, "Input dimensions must agree")
        precondition(index <= self.rows, "Index out of bounds")
        
        var res = Matrix.zeros(rows: self.rows + matrix.rows, columns: self.columns)
        
        if (index > 0) {
            vDSP_mmovD(self.values, &res.values, vDSP_Length(self.columns), vDSP_Length(index), vDSP_Length(self.columns), vDSP_Length(res.columns))
        }
        
        vDSP_mmovD(matrix.values, &res.values[index * res.columns], vDSP_Length(self.columns), vDSP_Length(matrix.rows), vDSP_Length(self.columns), vDSP_Length(res.columns))
        
        if (index < self.rows) {
            self.values.withUnsafeBufferPointer { bufPtr in
                let p = bufPtr.baseAddress! + index * self.columns
                vDSP_mmovD(p, &res.values[(index + matrix.rows) * res.columns], vDSP_Length(self.columns), vDSP_Length(self.rows - index), vDSP_Length(self.columns), vDSP_Length(res.columns))
            }
        }
        
        return res
    }
    
    public func append(matrix: Matrix) -> Matrix {
        precondition(matrix.columns == self.columns && matrix.rows == 1, "Input dimensions must agree")
        return insert(matrix: matrix, at: self.rows)
    }
    
    public func append(vector: Vector) -> Matrix {
        let r = Matrix(vector: vector)
        return append(matrix: r)
    }
    
    public func append(value: Double) -> Matrix {
        let vector = Vector(values: Array(repeating: value, count:self.columns))
        return append(vector: vector)
    }
    
    public func prepend(matrix: Matrix) -> Matrix {
        precondition(matrix.columns == self.columns && matrix.rows == 1, "Input dimensions must agree")
        return insert(matrix: matrix, at: 0)
    }
    
    public func prepend(vector: Vector) -> Matrix {
        let matrix = Matrix(vector: vector)
        return prepend(matrix: matrix)
    }
    
    public func prepend(value: Double) -> Matrix {
        let vector = Vector(values: Array(repeating: value, count: self.columns))
        return prepend(vector: vector)
    }

    //MARK: transposition
    public func transposed() -> Matrix {
        var matrix = Matrix.zeros(rows: self.rows, columns: self.columns)
        vDSP_mtransD(self.values, 1, &matrix.values, 1, vDSP_Length(self.columns), vDSP_Length(self.rows))
        return matrix
    }
    //MARK: inversion
    public func inversed() throws -> Matrix {
        precondition(self.rows == self.columns, "Matrix dimensions must agree")
        
        var matrix = Matrix(matrix: self)
        var N = __CLPK_integer(sqrt(Double(matrix.values.count)))
        var pivots = [__CLPK_integer](repeating: 0, count: Int(N))
        var workspace = [Double](repeating: 0.0, count: Int(N))
        var error : __CLPK_integer = 0
        
        withUnsafeMutablePointer(to: &N) {
            dgetrf_($0, $0, &matrix.values, $0, &pivots, &error)
            dgetri_($0, &matrix.values, $0, &pivots, &workspace, $0, &error)
        }
        if (error != 0) { throw MatrixAlgebraError.nonInvertible }
        return matrix
    }
    //MARK: mathematic functions
    public func add(matrix: Matrix) -> Matrix {
        var results = matrix
        results.values.withUnsafeMutableBufferPointer { pointer in
            cblas_daxpy(Int32(self.values.count), 1.0, self.values, 1, pointer.baseAddress!, 1)
        }
        return results
    }
    
    public func subtract(matrix: Matrix) -> Matrix {
        return add(matrix:matrix.negate())
    }
    
    public func multiply(matrix: Matrix) -> Matrix {
        precondition(self.columns == matrix.rows, "Matrices can't multiply.")
        var out = Matrix.zeros(rows: self.rows, columns: matrix.columns)
        vDSP_mmulD(self.values, 1, matrix.values, 1, &out.values, 1, vDSP_Length(self.rows), vDSP_Length(matrix.columns), vDSP_Length(self.columns))
        return out
    }
    
    public func divide(matrix: Matrix) throws -> Matrix {
        let inverse = try matrix.inversed()
        return multiply(matrix: inverse)
    }
    
    public func add(scalar: Double) -> Matrix {
        var results = Matrix(rows: self.rows, columns: self.columns, repeating: 0.0)
        let doubles = Array(repeating: scalar, count: self.rows * self.columns)
        vDSP_vsaddD(self.values, 1, doubles, &results.values, 1, vDSP_Length(self.values.count))
        return results
    }
    
    public func subtract(scalar: Double) -> Matrix {
        var results = Matrix(rows: self.rows, columns: self.columns, repeating: 0.0)
        let doubles = Array(repeating: -scalar, count: self.rows * self.columns)
        vDSP_vsaddD(self.values, 1, doubles, &results.values, 1, vDSP_Length(self.values.count))
        return results
    }
    
    public func multiply(scalar: Double) -> Matrix {
        var results = Matrix(rows: self.rows, columns: self.columns, repeating: 0.0)
        let doubles = Array(repeating: scalar, count: self.rows * self.columns)
        vDSP_vmulD(self.values, 1, doubles, 1, &results.values, 1, vDSP_Length(self.values.count))
        return results
    }
    
    public func divide(scalar: Double) -> Matrix {
        var result = Matrix(rows: self.rows, columns: self.columns, repeating: 0.0)
        let doubles = Array(repeating: scalar, count: self.rows * self.columns)
        vDSP_vdivD(self.values, 1, doubles, 1, &result.values, 1, vDSP_Length(self.values.count))
        return result
    }
    
    public func add(vector: Vector) -> Matrix {
        let values = Matrix(elements: Array(repeating: vector.values, count: self.rows))
        return add(matrix: values)
    }
    
    public func subtract(vector: Vector) -> Matrix {
        let values = Matrix(elements: Array(repeating: vector.values, count: self.rows))
        return subtract(matrix: values)
    }
    
    public func multiply(vector: Vector) -> Matrix {
        let doubles = Array(repeating: vector.values, count: self.rows).flatMap { $0 }
        var result = Matrix.zeros(rows: self.rows, columns: self.columns)
        vDSP_vmulD(self.values, 1, doubles, 1, &result.values, 1, vDSP_Length(self.values.count))
        return result
    }
    
    public func divide(vector: Vector) -> Matrix {
        let doubles = Array(repeating: vector.values, count: self.rows).flatMap { $0 }
        var result = Matrix.zeros(rows: self.rows, columns: self.columns)
        vDSP_vdivD(self.values, 1, doubles, 1, &result.values, 1, vDSP_Length(self.values.count))
        return result
    }
    
    public func elementWise(matrix: Matrix) -> Matrix {
        var results = Matrix(rows: self.rows, columns: self.columns, repeating: 0.0)
        vDSP_vmulD(self.values, 1, matrix.values, 1, &results.values, 1, vDSP_Length(self.values.count))
        return results
    }
    
    public func abs() -> Matrix {
        var result = Matrix.zeros(rows: self.rows, columns: self.columns)
        vDSP_vabsD(self.values, 1, &result.values, 1, vDSP_Length(self.rows * self.columns))
        return result
    }
    
    public func negate() -> Matrix {
        var results = Matrix.zeros(rows: self.rows, columns: self.columns)
        vDSP_vnegD(self.values, 1, &results.values, 1, vDSP_Length(self.rows * self.columns))
        return results
    }
    
    public func threshold(_ threshold: Double) -> Matrix {
        var results = Matrix.zeros(rows: self.rows, columns: self.columns)
        var t = threshold
        vDSP_vthrD(self.values, 1, &t, &results.values, 1, vDSP_Length(self.rows * self.columns))
        return results
    }
    
    //MARK: exponentation
    public func raise(to: Int) throws -> Matrix {
        switch to {
        case 1:
            return self
        case -1:
            return try inversed()
        case _ where to > 1:
            var matrix = Matrix(matrix: self)
            let range = (0...to)
            range.forEach { _ in
                matrix = matrix.multiply(matrix: matrix)
            }
            return matrix
        case _ where to < -1:
            let matrix = try inversed()
            return try matrix.raise(to:-to)
        default:
            throw MatrixAlgebraError.nonZeroPower
        }
    }
    
    public func exp() -> Matrix {
        var result = Matrix.zeros(rows: self.rows, columns: self.columns)
        var l = Int32(self.rows * self.columns)
        vvexp(&result.values, self.values, &l)
        return result
    }
    
    //MARK: subscripting
    public subscript(row: Int, column: Int) -> Double {
        get {
            assert(indexIsValidForRow(row, column: column))
            return values[(row * columns) + column]
        }
        
        set {
            assert(indexIsValidForRow(row, column: column))
            values[(row * columns) + column] = newValue
        }
    }
    
    public subscript(row row: Int) -> Vector {
        get {
            assert(row < rows)
            let startIndex = row * columns
            let endIndex = row * columns + columns
            return Vector(values: Array(values[startIndex..<endIndex]))
        }
        
        set {
            assert(row < rows)
            assert(newValue.values.count == columns)
            let startIndex = row * columns
            let endIndex = row * columns + columns
            values.replaceSubrange(startIndex..<endIndex, with: newValue.values)
        }
    }
    
    public subscript(column column: Int) -> Vector {
        get {
            var result = [Double](repeating: 0.0, count: rows)
            for i in 0..<rows {
                let index = i * columns + column
                result[i] = self.values[index]
            }
            return Vector(values: result)
        }
        
        set {
            assert(column < columns)
            assert(newValue.values.count == rows)
            for i in 0..<rows {
                let index = i * columns + column
                values[index] = newValue.values[i]
            }
        }
    }
    
    private func indexIsValidForRow(_ row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
}
//MARK: matrix/matrix operators
public func + (lhs: Matrix, rhs: Matrix) -> Matrix {
    return lhs.add(matrix: rhs)
}

public func - (lhs: Matrix, rhs: Matrix) -> Matrix {
    return lhs.subtract(matrix: rhs)
}

public func * (lhs: Matrix, rhs: Matrix) -> Matrix {
    return lhs.multiply(matrix: rhs)
}

public func / (lhs: Matrix, rhs: Matrix) throws -> Matrix {
    return try lhs.divide(matrix: rhs)
}

public func .* (lhs: Matrix, rhs: Matrix) -> Matrix {
    return lhs.elementWise(matrix: rhs)
}

//MARK: matrix double operators
public func + (lhs: Matrix, rhs: Double) -> Matrix {
    return lhs.add(scalar: rhs)
}

public func - (lhs: Matrix, rhs: Double) -> Matrix {
    return lhs.subtract(scalar: rhs)
}

public func * (lhs: Matrix, rhs: Double) -> Matrix {
    return lhs.multiply(scalar: rhs)
}

public func / (lhs: Matrix, rhs: Double) -> Matrix {
    return lhs.divide(scalar: rhs)
}

public func + (lhs: Double, rhs: Matrix) -> Matrix {
    return rhs.add(scalar: lhs)
}

public func - (lhs: Double, rhs: Matrix) -> Matrix {
    var results = Matrix(rows: rhs.rows, columns: rhs.columns, repeating: 0.0)
    let doubles = Array(repeating: -lhs, count: rhs.rows * rhs.columns)
    vDSP_vsaddD(doubles, 1, rhs.values, &results.values, 1, vDSP_Length(rhs.values.count))
    return results
}

public func * (lhs: Double, rhs: Matrix) -> Matrix {
    return rhs.multiply(scalar: lhs)
}

public func / (lhs: Double, rhs: Matrix) -> Matrix {
    var result = Matrix(rows: rhs.rows, columns: rhs.columns, repeating: 0.0)
    let doubles = Array(repeating: lhs, count: rhs.rows * rhs.columns)
    vDSP_vdivD(doubles, 1, rhs.values, 1, &result.values, 1, vDSP_Length(rhs.values.count))
    return result
}
//MARK: matrix/vector operators
public func + (lhs: Matrix, rhs: Vector) -> Matrix {
    return lhs.add(vector: rhs)
}

public func - (lhs: Matrix, rhs: Vector) -> Matrix {
    return lhs.subtract(vector: rhs)
}

public func * (lhs: Matrix, rhs: Vector) -> Matrix {
    return lhs.multiply(vector: rhs)
}

public func / (lhs: Matrix, rhs: Vector) -> Matrix {
    return lhs.divide(vector: rhs)
}

public func + (lhs: Vector, rhs: Matrix) -> Matrix {
    return rhs.add(vector: lhs)
}

public func - (lhs: Vector, rhs: Matrix) -> Matrix {
    return rhs.subtract(vector: lhs)
}

public func * (lhs: Vector, rhs: Matrix) -> Matrix {
    return rhs.multiply(vector: lhs)
}

public func / (lhs: Vector, rhs: Matrix) -> Matrix {
    return rhs.divide(vector: lhs)
}

//MARK: appending operators
public func === (lhs: Matrix, rhs: Double) -> Matrix {
    return lhs.append(value: rhs)
}

public func === (lhs: Matrix, rhs: Vector) -> Matrix {
    return lhs.append(vector: rhs)
}

public func === (lhs: Double, rhs: Matrix) -> Matrix {
    return rhs.prepend(value: lhs)
}

public func === (lhs: Vector, rhs: Matrix) -> Matrix {
    return rhs.prepend(vector: lhs)
}

public func === (lhs: Matrix, rhs: Matrix) -> Matrix {
    return lhs.append(matrix: rhs)
}

public func ||| (lhs: Matrix, rhs: Double) -> Matrix {
    return lhs.append(value: rhs)
}

public func ||| (lhs: Double, rhs: Matrix) -> Matrix {
    return rhs.prepend(value: lhs)
}

public func ||| (lhs: Vector, rhs: Matrix) -> Matrix {
    return rhs.prepend(vector: lhs)
}

public func ||| (lhs: Matrix, rhs: Vector) -> Matrix {
    return lhs.append(vector: rhs)
}

//MARK: Unary operators
public prefix func - (matrix: Matrix) -> Matrix {
    return matrix.negate()
}

public prefix func + (matrix: Matrix) -> Matrix {
    return matrix.abs()
}

//MARK: exponential operators
public func .^ (lhs: Matrix, rhs: Int) throws -> Matrix {
    return try lhs.raise(to: rhs)
}

//MARK: Equatable
extension Matrix: Equatable {
    public static func == (lhs: Matrix, rhs: Matrix) -> Bool {
        return lhs.rows == rhs.rows && lhs.columns == rhs.columns && applyComparison(lhs: lhs.values, rhs: rhs.values, f: ==~) != 0
    }
    public static func !=(lhs: Matrix, rhs: Matrix) -> Bool {
        return !(lhs == rhs)
    }
}

//MARK: Comparable
extension Matrix: Comparable {
    public static func <(lhs: Matrix, rhs: Matrix) -> Bool {
        return lhs.rows == rhs.rows && lhs.columns == rhs.columns &&
            applyComparison(lhs: lhs.values, rhs: rhs.values, f: <~) != 0
    }
    public static func >(lhs: Matrix, rhs: Matrix) -> Bool {
        return lhs.rows == rhs.rows && lhs.columns == rhs.columns &&
            applyComparison(lhs: lhs.values, rhs: rhs.values, f: >~) != 0
    }
    
    public static func <=(lhs: Matrix, rhs: Matrix) -> Bool {
        return lhs.rows == rhs.rows && lhs.columns == rhs.columns &&
            applyComparison(lhs: lhs.values, rhs: rhs.values, f: <=~) != 0
    }
    public static func >=(lhs: Matrix, rhs: Matrix) -> Bool {
        return lhs.rows == rhs.rows && lhs.columns == rhs.columns &&
            applyComparison(lhs: lhs.values, rhs: rhs.values, f: >=~) != 0
    }
}
//MARK: Sequence
extension Matrix: Sequence {
    public typealias Iterator = AnyIterator<ArraySlice<Double>>
    
    public func makeIterator() -> Matrix.Iterator {
        let end = rows * columns
        var nextRowStart = 0
        return AnyIterator {
            if nextRowStart == end {
                return nil
            }
            let currentRowStart = nextRowStart
            nextRowStart += self.columns
            return self.values[currentRowStart..<nextRowStart]
        }
    }
}

//MARK: CustomStringConvertible
extension Matrix: CustomStringConvertible {
    public var description: String {
        var description = ""
        
        for i in 0..<rows {
            let contents = (0..<columns).map({ "\(self[i, $0])" }).joined(separator: "\t")
            description += "[\t\(contents)\t\n]"
        }
        
        return description
    }
}

//MARK: ExpressibleByArrayLiteral
extension Matrix: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: [Double]...) {
        self.init(elements: elements)
    }
}


