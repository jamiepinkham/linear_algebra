//
//  Functions.swift
//  LinearAlgebra-macOS
//
//  Created by Pinkham, Jamie on 10/26/17.
//  Copyright © 2017 Jamie Pinkham. All rights reserved.
//

import Foundation
import Accelerate

func within<T>(_ range: ClosedRange<T>) -> T
    where T: FloatingPoint, T: ExpressibleByFloatLiteral {
        return (range.upperBound - range.lowerBound) *
            (T(arc4random()) / T(UInt32.max)) + range.lowerBound
}

func random(from range: ClosedRange<Double>, count: Int) -> [Double] {
    var iDist = __CLPK_integer(1)
    var iSeed = (0..<4).map { _ in __CLPK_integer(within(range)) }
    var n = __CLPK_integer(count)
    var x = Array(repeating: 0.0, count: count)
    dlarnv_(&iDist, &iSeed, &n, &x)
    return x
}
