//
//  Operators.swift
//  LinearAlgebra-macOS
//
//  Created by Pinkham, Jamie on 10/26/17.
//  Copyright © 2017 Jamie Pinkham. All rights reserved.
//

import Foundation

infix operator .* : MultiplicationPrecedence
infix operator ./ : MultiplicationPrecedence
infix operator ./. : MultiplicationPrecedence
infix operator .^ : MultiplicationPrecedence

postfix operator ′ 

infix operator ||| : DefaultPrecedence
