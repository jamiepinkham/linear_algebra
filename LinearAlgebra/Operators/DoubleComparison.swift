//
//  DoubleComparison.swift
//  LinearAlgebra
//
//  Created by Jamie Pinkham on 10/24/17.
//  Copyright © 2017 Jamie Pinkham. All rights reserved.
//

import Foundation

precedencegroup EquivalencePrecedence {
    higherThan: ComparisonPrecedence
    lowerThan: AdditionPrecedence
}

infix operator ==~ : EquivalencePrecedence
infix operator !=~ : EquivalencePrecedence
infix operator <=~ : ComparisonPrecedence
infix operator >=~ : ComparisonPrecedence
infix operator <~ : ComparisonPrecedence
infix operator >~ : ComparisonPrecedence


func ==~ (left: Double, right: Double) -> Bool {
    return fabs(left.distance(to: right)) <= .ulpOfOne
}

func !=~ (left: Double, right: Double) -> Bool {
    return !(left ==~ right)
}

func <=~ (left: Double, right: Double) -> Bool {
    return left ==~ right || left <~ right
}

func >=~ (left: Double, right: Double) -> Bool {
    return left ==~ right || left >~ right
}

func <~ (left: Double, right: Double) -> Bool {
    return left.distance(to: right) > .ulpOfOne
}

func >~ (left: Double, right: Double) -> Bool {
    return left.distance(to: right) < -.ulpOfOne
}

func applyComparison<T>(lhs: [T], rhs: [T], f: (T, T) -> Bool) -> Int {
    return zip(lhs, rhs).filter(f).count
}
