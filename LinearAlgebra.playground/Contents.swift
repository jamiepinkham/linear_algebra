//: Playground - noun: a place where people can play

@testable import LinearAlgebra
import Accelerate

//let v1: Vector = [-5.955, -4.904, -1.874]
//let v2: Vector = [-4.496, -8.755,7.103]
//
//print(v1.dot(v2))
//
//let v3: Vector = [3.183, -7.627]
//let v4: Vector = [-2.668, 5.319]
//
//print(angle(v3, v4))
//
//
//let v5: Vector = [7.35, 0.221, 5.188]
//let v6: Vector = [2.751, 8.259, 3.985]
//let vAngle = angle(v5, v6)
//print(vAngle * 180 / .pi)


//let v7: Vector = [-7.579,-7.88]
//let v8: Vector = [22.737, 23.64]
//
//v7.parallel(to: v8)
//v7.orthogonal(to: v8)
//
//let v9: Vector = [-2.029, 9.97, 4.172]
//let v10: Vector = [-9.231, -6.639, -7.245]
//
//v9.parallel(to: v10)
//v9.orthogonal(to: v10)
//
//let v11: Vector = [-2.328, -7.284, -1.214]
//let v12: Vector = [-1.821, 1.072, -2.940]
//
//v11.dot(v12) <= .ulpOfOne
//
//v11.parallel(to: v12)
//v11.orthogonal(to: v12)
//
//let v13: Vector = [2.118, 4.827]
//let v14: Vector = [0, 0]
//
//v13.magnitude
//v14.magnitude
//
//v13.parallel(to: v14)
//v13.orthogonal(to: v14)
//
//let v1: Vector = [3.039, 1.879]
//let b1: Vector = [0.825, 2.036]
//
//let projbv = v1.project(b1)
//
//let v2: Vector = [-9.88, -3.264,-8.159]
//let b2: Vector = [-2.155, -9.353, -9.473]
//
//let vperp = v2.componentOrthogonal(to: b2)
//
//let v3: Vector = [3.009, -6.172, 3.692, -2.51]
//let b3: Vector = [6.404, -9.144, 2.759, 8.718]
//
//let vpar = v3.componentParallel(to: b3)
//let vorth = v3.componentOrthogonal(to: b3)

//let r1: Vector = [0, 0, 0]
//
//let m = Matrix(vectors: [r1, r1, r1])
//
//let n = m.map { (v) -> Vector in
//    return v + 1.0
//}
//
//print(n.values)

//let vector: Vector = [1,2,3]
let m = Matrix(elements: [1, 2, 3], [0, 1, 4], [5, 6, 0])
print(m.singularValueDecomposition())
//let m1 = Matrix(elements: [3,4,5], [6, 7, 8])
//
//m == m1
//
//for i in m {
//    print(i)
//}

//let n = m.append(vector: vector)
//print(n)
//let a = try? n.inversed()
//print(try n.inversed())


//print(try n.inversed() * n)
//let m2 = Matrix(elements: [[1, 2, 1], [0, -3, 2]])
//print(m2)
//print(m2.values)
//let A: Matrix = [[-3, 2], [5, -4]]
//print(A.values)
//print(A)

//
//print(m2.multiply(matrix: res))

//let m = Matrix.eye(rows: 3, columns: 3)

//func multiply(lhs: Matrix, rhs: Matrix) -> Matrix {
//    var out = Matrix.zeros(rows: lhs.rows, columns: rhs.columns)
//    vDSP_mmulD(lhs.values, 1, rhs.values, 1, &out.values, 1, vDSP_Length(lhs.rows), vDSP_Length(rhs.columns), vDSP_Length(rhs.columns))
//    return out
//}
//
//func asVectors(matrix: Matrix) -> [Vector] {
//    guard !matrix.values.isEmpty else { return [] }
//    let range = (0..<matrix.columns - 1)
//    print(range)
//    let vectors = range.map { i -> Vector in
//        let start = i * matrix.columns
//        print(start)
//        let end = start + matrix.rows - 1
//        print(end)
//        let slice = matrix.values[start...end]
//        print(slice)
//        return Vector(values: Array(slice))
//    }
//    return vectors
//}
//
//print(multiply(lhs: m2, rhs: res))




