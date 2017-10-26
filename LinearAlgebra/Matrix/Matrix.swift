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
        columns = r
    }
    
    init(rows r: Int, columns c: Int, repeating vector: Vector) {
        precondition(r * c == vector.values.count, "Matrix dimensions must agree")
        values = vector.values
        rows = r
        columns = r
    }
    
    func asVectors() -> [Vector] {
        guard !self.values.isEmpty else { return [] }
        let range = (0...self.columns - 1)
        let vectors = range.map { i -> Vector in
            let start = i * self.rows
            let end = start + self.rows - 1
            let slice = self.values[start...end]
            return Vector(values: Array(slice))
        }
        return vectors
    }
    
    public init(matrix other: Matrix) {
        values = other.values
        rows = other.rows
        columns = other.columns
    }
    
    public init(vector: Vector) {
        values = vector.values
        rows = vector.values.count
        columns = 1
    }
    
    public init(vectors: [Vector]) {
        precondition(vectors.count > 0, "must not be empty")
        precondition(vectors[0].values.count > 0, "must not be empty")
        precondition(Set(vectors.map { $0.values.count }).count == 1, "Input dimensions must agree")
        values = vectors.flatMap { $0.values }
        rows = vectors.count
        columns = vectors[0].values.count
    }
    
    public init(elements: [Double]...) {
        precondition(elements.count > 0, "must not be empty")
        precondition(elements[0].count > 0, "must not be empty")
        precondition(Set(elements.map { $0.count }).count == 1, "Input dimensions must agree")
        columns = elements.count
        rows = elements[0].count
        self.values = Array(elements.joined())
    }
    
    public static func zeros(rows: Int, columns: Int) -> Matrix {
        precondition(rows > 0 && columns > 0, "must have positive rows and columns")
        return Matrix(rows: rows, columns: columns, repeating: 0.0)
    }
    
    public static func ones(rows: Int, columns: Int) -> Matrix {
        precondition(rows > 0 && columns > 0, "must have positive rows and columns")
        return Matrix(rows: rows, columns: columns, repeating: 1.0)
    }
    
    public static func eye(rows: Int, columns: Int) -> Matrix {
        let vectors: [Vector] = (0..<rows).map { i in
            var row = Array(repeating: 0.0, count: columns)
            if (i < columns) {
                row[i] = 1.0
            }
            return Vector(values: row)
        }
        
        return Matrix(vectors: vectors)
    }
    
    public static func random(rows: Int, columns: Int) -> Matrix {
        let values = LinearAlgebra.random(from: 0.0...4096.0, count: rows * columns)
        return Matrix(rows: rows, columns: columns, values: values)
    }
    
    public func insert(vector: Vector, at index: Int) -> Matrix {
        return insert(matrix: Matrix(vector: vector), at: index)
    }
    
    public func insert(matrix: Matrix, at index: Int) -> Matrix {
        precondition(matrix.columns == matrix.columns, "Input dimensions must agree")
        precondition(index <= matrix.rows, "Index out of bounds")
        
        var res = Matrix.zeros(rows: self.rows + matrix.rows, columns: self.columns)
        
        if (index > 0) {
            vDSP_mmovD(matrix.values, &res.values, vDSP_Length(self.columns), vDSP_Length(index), vDSP_Length(self.columns), vDSP_Length(res.columns))
        }
        vDSP_mmovD(matrix.values, &res.values[index * res.columns], vDSP_Length(self.columns), vDSP_Length(matrix.rows), vDSP_Length(self.columns), vDSP_Length(res.columns))
        
        if (index < self.rows) {
            matrix.values.withUnsafeBufferPointer { bufPtr in
                let p = bufPtr.baseAddress! + index * matrix.columns
                vDSP_mmovD(p, &res.values[(index + matrix.rows) * res.columns], vDSP_Length(self.columns), vDSP_Length(self.rows - index), vDSP_Length(self.columns), vDSP_Length(res.columns))
            }
        }
        return res
    }
    
    public func append(matrix: Matrix) -> Matrix {
        precondition(matrix.columns == self.columns && matrix.rows == 1, "Input dimensions must agree")
        return insert(matrix: matrix, at: matrix.rows)
    }
    
    public func append(vector: Vector) -> Matrix {
        let r = Matrix(vector: vector)
        return append(matrix: r)
    }
    
    public func append(value: Double) -> Matrix {
        let vector = Vector(values: Array(repeating: 0.0, count:self.columns))
        return append(vector: vector)
    }
    
    public func append(vectors: [Vector]) -> Matrix{
        let matrix = Matrix(vectors: vectors)
        return append(matrix: matrix)
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
        let vector = Vector(values: Array(repeating: 0.0, count: self.columns))
        return prepend(vector: vector)
    }
    
    public func map(_ f: (Double) -> Double) -> Matrix {
        return Matrix(rows: self.rows, columns: self.columns, values: self.values.map(f))
    }
    
    public func map(_ f: @escaping (Vector) -> Vector) -> Matrix {
        return Matrix(vectors: self.asVectors().map(f))
    }
    
    public func reduce(_ f: (Vector) -> Double, dimension: Dimension = .row) -> Vector {
        let m: Matrix
        switch dimension {
        case .row:
            m = self
        case .column:
            m = self.transpose()
        }
        return Vector(values: m.asVectors().map(f))
    }
    
    public func transpose() -> Matrix {
        var matrix = Matrix.zeros(rows: self.rows, columns: self.columns)
        vDSP_mtransD(self.values, 1, &matrix.values, 1, vDSP_Length(self.columns), vDSP_Length(self.rows))
        return matrix
    }
    
    public func dot(matrix: Matrix) -> Matrix {
        precondition(self.columns == matrix.rows, "Matrix dimensions must agree")
        var ret = Matrix.zeros(rows: self.rows, columns: matrix.columns)
        vDSP_mmulD(self.values, 1, matrix.values, 1, &(ret.values), 1, vDSP_Length(self.rows), vDSP_Length(self.rows), vDSP_Length(self.columns))
        return ret
    }
    
    public func raise(to: Int) throws -> Matrix {
        switch to {
        case 1:
            return self
        case -1:
            return try inverse()
        case _ where to > 1:
            var matrix = Matrix(matrix: self)
            let range = (0...to)
            range.forEach { _ in
                matrix = matrix.multiply(matrix: matrix)
            }
            return matrix
        case _ where to < -1:
            let matrix = try inverse()
            return try matrix.raise(to:-to)
        default:
            throw MatrixAlgebraError.nonZeroPower
        }
    }
    
    public func inverse() throws -> Matrix {
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
    
    public func add(matrix: Matrix) -> Matrix {
        let v1: Vector = Vector(values: self.values)
        let v2: Vector = Vector(values: matrix.values)
        let result = v1 + v2
        return Matrix(rows: self.rows, columns: self.columns, values: result.values)
    }
    
    public func subtract(matrix: Matrix) -> Matrix {
        let v1: Vector = Vector(values: self.values)
        let v2: Vector = Vector(values: matrix.values)
        let result = v1 - v2
        return Matrix(rows: self.rows, columns: self.columns, values: result.values)
    }
    
    public func multiply(matrix: Matrix) -> Matrix {
        let v1: Vector = Vector(values: self.values)
        let v2: Vector = Vector(values: matrix.values)
        let result: Vector = v1 .* v2
        return Matrix(rows: self.rows, columns: self.columns, values: result.values)
    }
    
    public func divide(matrix: Matrix) -> Matrix {
        let v1: Vector = Vector(values: self.values)
        let v2: Vector = Vector(values: matrix.values)
        let result = v1 / v2
        return Matrix(rows: self.rows, columns: self.columns, values: result.values)
    }
    
    public func add(scalar: Double) -> Matrix {
        return Matrix(rows: self.rows, columns: self.columns, values: self.values.map { $0 + scalar})
    }
    
    public func subtract(scalar: Double) -> Matrix {
        return Matrix(rows: self.rows, columns: self.columns, values: self.values.map { $0 - scalar})
    }
    
    public func multiply(scalar: Double) -> Matrix {
        return Matrix(rows: self.rows, columns: self.columns, values: self.values.map { $0 * scalar})
    }
    
    public func divide(scalar: Double) -> Matrix {
        return Matrix(rows: self.rows, columns: self.columns, values: self.values.map { $0 / scalar})
    }
    
    public func add(vector: Vector) -> Matrix {
        return self.map({ (v) -> Vector in
            return v + vector
        })
    }
    
    public func subtract(vector: Vector) -> Matrix {
        return self.map({ (v) -> Vector in
            return v - vector
        })
    }
    
    public func multiply(vector: Vector) -> Matrix {
        return self.map({ (v) -> Vector in
            return v .* vector
        })
    }
    
    public func divide(vector: Vector) -> Matrix {
        return self.map({ (v) -> Vector in
            return v / vector
        })
    }
    
    public func abs() -> Matrix {
        return self.map({ (v) -> Vector in
            return v.absolute()
        })
    }
    
    public func negate() -> Matrix {
        return self.map({ (v) -> Vector in
            v.negate()
        })
    }
    
    public func threshold(_ threshold: Double) -> Matrix {
        return self.map({ (v) -> Vector in
            v.threshold(threshold)
        })
    }
    
    public subscript(_ row: Int, column: Int) -> Double {
        get {
            return self.values[(row * column) + column]
        }
        
        set {
            self.values[(row * column) + column] = newValue
        }
    }
    
    public subscript(row row: Int) -> Vector {
        get {
            let startIndex = row * columns
            let endIndex = row * columns + columns
            return Vector(values: Array(self.values[startIndex..<endIndex]))
        }
        
        set {
            let startIndex = row * columns
            let endIndex = row * columns + columns
            values.replaceSubrange(startIndex..<endIndex, with: newValue.values)
        }
    }
    
    public subscript(column column: Int) -> Vector {
        get {
            let values = (0..<rows).map { i -> Double in
                let index = i * columns + column
                return self.values[index]
            }
            return Vector(values: values)
        }
        
        set {
            (0..<rows).forEach { i in
                let index = i * columns + column
                values[index] = newValue.values[i]
            }
        }
    }
}
//MARK: matrix/matrix operations
public func + (lhs: Matrix, rhs: Matrix) -> Matrix {
    return lhs.add(matrix: rhs)
}

public func - (lhs: Matrix, rhs: Matrix) -> Matrix {
    return lhs.subtract(matrix: rhs)
}

public func * (lhs: Matrix, rhs: Matrix) -> Matrix {
    return lhs.dot(matrix: rhs)
}

public func / (lhs: Matrix, rhs: Matrix) -> Matrix {
    return lhs.divide(matrix: rhs)
}

public func .* (lhs: Matrix, rhs: Matrix) -> Matrix {
    return lhs.multiply(matrix: rhs)
}
//MARK: matrix double operations
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
    return rhs.subtract(scalar: lhs)
}

public func * (lhs: Double, rhs: Matrix) -> Matrix {
    return rhs.multiply(scalar: lhs)
}

public func / (lhs: Double, rhs: Matrix) -> Matrix {
    return rhs.divide(scalar: lhs)
}
//MARK: matrix/vector operations
public func + (lhs: Matrix, rhs: Vector) -> Matrix {
    return lhs.add(vector: rhs)
}

public func - (lhs: Matrix, rhs: Vector) -> Matrix {
    return lhs.subtract(vector: rhs)
}

public func * (lhs: Matrix, rhs: Vector) -> Matrix {
    return lhs.multiply(vector: rhs)
}

public func .* (lhs: Matrix, rhs: Vector) -> Matrix {
    return lhs.multiply(vector: rhs)
}

public func .* (lhs: Vector, rhs: Matrix) -> Matrix {
    return rhs.multiply(vector: lhs)
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

public func .^ (lhs: Matrix, rhs: Int) throws -> Matrix {
    return try lhs.raise(to: rhs)
}

//MARK: Comparable
extension Matrix: Equatable {
    public static func == (lhs: Matrix, rhs: Matrix) -> Bool {
        return lhs.rows == rhs.rows && lhs.columns == rhs.columns && applyComparison(lhs: lhs.values, rhs: rhs.values, f: ==~) == 0
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

extension Matrix: CustomStringConvertible {
    public var description: String {
        return "\(self.asVectors().map{ $0.description }.joined(separator: "\n"))"
    }
}

extension Matrix: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: [Double]...) {
        precondition(elements.count > 0, "must not be empty")
        precondition(elements[0].count > 0, "must not be empty")
        precondition(Set(elements.map { $0.count }).count == 1, "Input dimensions must agree")
        columns = elements.count
        rows = elements[0].count
        values = Array(elements.joined())
    }
}


