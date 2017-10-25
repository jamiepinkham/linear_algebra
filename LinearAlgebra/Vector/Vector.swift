//
//  Vector.swift
//  LinearAlgebra
//
//  Created by Jamie Pinkham on 10/24/17.
//  Copyright © 2017 Jamie Pinkham. All rights reserved.
//

import Foundation
import Accelerate

public struct Vector {
    let values: [Double]
    let dimension: Int
    init(values: [Double]) {
        self.values = values
        dimension = self.values.count
    }
    
    static func zeros(_ count: Int) -> Vector {
        return Vector(values: Array(repeating: 0.0, count: count))
    }
    
    static func ones(_ count: Int) -> Vector {
        return Vector(values: Array(repeating: 1.0, count: count))
    }
    //MARK: Vector Arithmatic
    public func add(_ vector: Vector) -> Vector {
        precondition(self.dimension == vector.dimension, "vectors must have same dimension")
        var ret = Array(repeating: 0.0, count: self.dimension)
        vDSP_vaddD(self.values, 1, vector.values, 1, &ret, 1, vDSP_Length(self.dimension))
        return Vector(values: ret)
    }
    
    public func subtract(_ vector: Vector) -> Vector {
        precondition(self.dimension == vector.dimension, "vectors must have same dimension")
        var ret = Array(repeating: 0.0, count: self.dimension)
        vDSP_vsubD(self.values, 1, vector.values, 1, &ret, 1, vDSP_Length(self.dimension))
        return Vector(values: ret)
    }
    
    public func multiply(_ vector: Vector) -> Vector {
        precondition(self.dimension == vector.dimension, "vectors must have same dimension")
        var ret = Array(repeating: 0.0, count: self.dimension)
        vDSP_vmulD(self.values, 1, vector.values, 1, &ret, 1, vDSP_Length(self.dimension))
        return Vector(values: ret)
    }
    
    public func divide(_ vector: Vector) -> Vector {
        precondition(self.dimension == vector.dimension, "vectors must have same dimension")
        var ret = Array(repeating: 0.0, count: self.dimension)
        vDSP_vdivD(self.values, 1, vector.values, 1, &ret, 1, vDSP_Length(self.dimension))
        return Vector(values: ret)
    }
    
    public func dot(_ vector: Vector) -> Double {
        precondition(self.dimension == vector.dimension, "vectors must have same dimension")
        var c: Double = 0.0
        vDSP_dotprD(self.values, 1, vector.values, 1, &c, vDSP_Length(self.dimension))
        return c
    }
    
    //MARK: Scalar Arithmatic
    public func add(_ scalar: Double) -> Vector {
        var ret = Array(repeating: 0.0, count: self.dimension)
        var scalar = scalar
        vDSP_vsaddD(self.values, 1, &scalar, &ret, 1, vDSP_Length(self.dimension))
        return Vector(values: ret)
    }
    
    public func subtract(_ scalar: Double) -> Vector {
        var ret = Array(repeating: 0.0, count: self.dimension)
        var scalar = -scalar
        vDSP_vsaddD(self.values, 1, &scalar, &ret, 1, vDSP_Length(self.dimension))
        return Vector(values: ret)
    }
    
    public func multiply(_ scalar: Double) -> Vector {
        var ret = Array(repeating: 0.0, count: self.dimension)
        var scalar = scalar
        vDSP_vsmulD(self.values, 1, &scalar, &ret, 1, vDSP_Length(self.dimension))
        return Vector(values: ret)
    }
    
    public func divide(_ scalar: Double) -> Vector {
        var ret = Array(repeating: 0.0, count: self.dimension)
        var scalar = scalar
        vDSP_vsdivD(self.values, 1, &scalar, &ret, 1, vDSP_Length(self.dimension))
        return Vector(values: ret)
    }
    
    //MARK: Unary Arithmatic
    public func absolute() -> Vector {
        var ret = Array(repeating: 0.0, count: self.dimension)
        vDSP_vabsD(self.values, 1, &ret, 1, vDSP_Length(self.dimension))
        return Vector(values: ret)
    }
    
    public func unaryMinus() -> Vector {
        var ret = Array(repeating: 0.0, count: self.dimension)
        vDSP_vnegD(self.values, 1, &ret, 1, vDSP_Length(self.dimension))
        return Vector(values: ret)
    }
    //MARK: Threshold
    public func threshold(_ scalar: Double) -> Vector {
        var b = Array(repeating: 0.0, count: self.dimension)
        var t = scalar
        vDSP_vthrD(self.values, 1, &t, &b, 1, vDSP_Length(self.dimension))
        return Vector(values: b)
    }
    //MARK: Exponential Arithmatic
    public func power(_ p: Double) -> Vector {
        var c = Array(repeating: 0.0, count: self.dimension)
        var l = Int32(self.dimension)
        var p = p
        vvpows(&c, &p, self.values, &l)
        return Vector(values: c)
    }
    
    public func square() -> Vector {
        var c = Array(repeating: 0.0, count: self.dimension)
        vDSP_vsqD(self.values, 1, &c, 1, vDSP_Length(self.dimension))
        return Vector(values: c)
    }
    
    public func squareRoot() -> Vector {
        var c = Array(repeating: 0.0, count: self.dimension)
        var l = Int32(self.dimension)
        vvsqrt(&c, self.values, &l)
        return Vector(values: c)
    }
    
    public func exp() -> Vector {
        var c = Array(repeating: 0.0, count: self.dimension)
        var l = Int32(self.dimension)
        vvexp(&c, self.values, &l)
        return Vector(values: c)
    }
    
    public func log() -> Vector {
        var c = Array(repeating: 0.0, count: self.dimension)
        var l = Int32(self.dimension)
        vvlog(&c, self.values, &l)
        return Vector(values: c)
    }
    
    public func log2() -> Vector {
        var c = Array(repeating: 0.0, count: self.dimension)
        var l = Int32(self.dimension)
        vvlog2(&c, self.values, &l)
        return Vector(values: c)
    }
    
    public func log10() -> Vector {
        var c = Array(repeating: 0.0, count: self.dimension)
        var l = Int32(self.dimension)
        vvlog10(&c, self.values, &l)
        return Vector(values: c)
    }
    //MARK: magnitude
    public var magnitude: Double {
        var c = 0.0
        vDSP_svesqD(self.values, 1, &c, vDSP_Length(self.dimension))
        return sqrt(c)
    }
    //MARK: normalization
    public func normalize() -> Vector {
        let normal = 1 / self.magnitude
        return self.multiply(normal)
    }
    
    public func orthogonal(to other: Vector) -> Bool {
        return self.dot(other) ==~ 0.0
    }
    
    public func parallel(to other: Vector) -> Bool {
        if self.isZero || other.isZero { return true }
        return abs(self.normalize().dot(other.normalize())) ==~ 1.0
    }
    
    private var isZero: Bool {
        return self.magnitude == 0
    }
    
    //MARK: subscripting
    public subscript(key: Int) -> Double {
        precondition(key >= 0 && key < self.dimension, "key is out of bounds")
        return self.values[key]
    }
}

//MARK: Operators
infix operator .* : MultiplicationPrecedence

public func + (lhs: Vector, rhs: Vector) -> Vector {
    return lhs.add(rhs)
}

public func += (lhs: inout Vector, rhs: Vector) -> Vector {
    return lhs.add(rhs)
}
public func - (lhs: Vector, rhs: Vector) -> Vector {
    return lhs.subtract(rhs)
}

public func -= (lhs: inout Vector, rhs: Vector) -> Vector {
    return lhs.subtract(rhs)
}

public func * (lhs: Vector, rhs: Vector) -> Double {
    return lhs.dot(rhs)
}

public func *= (lhs: inout Vector, rhs: Vector) -> Vector {
    return lhs.multiply(rhs)
}

public func / (lhs: Vector, rhs: Vector) -> Vector {
    return lhs.divide(rhs)
}

public func /= (lhs: inout Vector, rhs: Vector) -> Vector {
    return lhs.divide(rhs)
}

public func + (lhs: Vector, rhs: Double) -> Vector {
    return lhs.add(rhs)
}

public func - (lhs: Vector, rhs: Double) -> Vector {
    return lhs.subtract(rhs)
}

public func .* (lhs: Vector, rhs: Vector) -> Vector {
    return lhs.multiply(rhs)
}

public func / (lhs: Vector, rhs: Double) -> Vector {
    return lhs.divide(rhs)
}

public func * (lhs: Vector, rhs: Double) -> Vector {
    return lhs.multiply(rhs)
}

public prefix func - (_ a: Vector) -> Vector {
    return a.unaryMinus()
}

public func ^ (_ a: Vector, _ p: Double) -> Vector {
    return a.power(p)
}

public func angle(_ lhs: Vector, _ rhs: Vector) -> Double {
    return acos(lhs.normalize().dot(rhs.normalize()))
}

//MARK: ExpressibleByArrayLiteral
extension Vector: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Double
    public init(arrayLiteral elements: Double...) {
        self.init(values: elements)
    }
}

//MARK: Equatable
extension Vector: Equatable {
    public static func ==(lhs: Vector, rhs: Vector) -> Bool {
        return lhs.dimension == rhs.dimension &&
            applyComparison(lhs: lhs.values, rhs: rhs.values, f: !=~) == 0
    }
    
    public static func !=(lhs: Vector, rhs: Vector) -> Bool {
        return !(lhs == rhs)
    }
}

//MARK: Comparable
extension Vector: Comparable {
    public static func <(lhs: Vector, rhs: Vector) -> Bool {
        return lhs.dimension != rhs.dimension ||
            applyComparison(lhs: lhs.values, rhs: rhs.values, f: <~) != 0
    }
    public static func >(lhs: Vector, rhs: Vector) -> Bool {
        return lhs.dimension != rhs.dimension ||
            applyComparison(lhs: lhs.values, rhs: rhs.values, f: >~) != 0
    }
    
    public static func <=(lhs: Vector, rhs: Vector) -> Bool {
        return lhs.dimension != rhs.dimension ||
            applyComparison(lhs: lhs.values, rhs: rhs.values, f: <=~) != 0
    }
    public static func >=(lhs: Vector, rhs: Vector) -> Bool {
        return lhs.dimension != rhs.dimension ||
            applyComparison(lhs: lhs.values, rhs: rhs.values, f: >=~) != 0
    }
}
private func applyComparison<T>(lhs: [T], rhs: [T], f: (T, T) -> Bool) -> Int {
    return zip(lhs, rhs).filter(f).count
}

//MARK: CustomStringConvertible
extension Vector: CustomStringConvertible {
    public var description: String {
        return "[" + self.values.map{"\($0)"}.joined(separator: ", ") + "]"
    }
}


