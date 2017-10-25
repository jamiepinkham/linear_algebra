//
//  Matrix.swift
//  LinearAlgebra
//
//  Created by Pinkham, Jamie on 10/25/17.
//  Copyright © 2017 Jamie Pinkham. All rights reserved.
//

import Foundation
import Accelerate

public enum Dim {
    case row
    case column
}

public struct Matrix {
    var values: [Double]
    public let rows: Int
    public let columns: Int
    
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
    
    public func insert(row: Vector, at index: Int) -> Matrix {
        return insert(rows: Matrix(vector: row), at: index)
    }
    
    public func insert(rows: Matrix, at index: Int) -> Matrix {
        precondition(rows.columns == rows.columns, "Input dimensions must agree")
        precondition(index <= rows.rows, "Index out of bounds")
        
        var res = Matrix.zeros(rows: self.rows + rows.rows, columns: self.columns)
        
        if (index > 0) {
            vDSP_mmovD(rows.values, &res.values, vDSP_Length(self.columns), vDSP_Length(index), vDSP_Length(self.columns), vDSP_Length(res.columns))
        }
        vDSP_mmovD(rows.values, &res.values[index * res.columns], vDSP_Length(self.columns), vDSP_Length(rows.rows), vDSP_Length(self.columns), vDSP_Length(res.columns))
        
        if (index < self.rows) {
            rows.values.withUnsafeBufferPointer { bufPtr in
                let p = bufPtr.baseAddress! + index * rows.columns
                vDSP_mmovD(p, &res.values[(index + rows.rows) * res.columns], vDSP_Length(self.columns), vDSP_Length(self.rows - index), vDSP_Length(self.columns), vDSP_Length(res.columns))
            }
        }
        return res
    }
}
