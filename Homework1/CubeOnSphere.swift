import UIKit

typealias Geometry = (vertices: [Float], indices: [Int], colors: [Float])

struct CubeOnSphere {
    private (set) var sphereGeometry: Geometry?
    private (set) var cubeGeometry: Geometry?
    private (set) var geometry: Geometry?

    init(radius: Float, sectors: Int, stacks: Int, cubeColor: UIColor) {
        self.sphereGeometry = sphere(radius: radius, sectorCount: sectors, stackCount: stacks)
        self.cubeGeometry = cube(x: 0, y: radius, z: 0, size: radius / 4, color: CIColor(color: cubeColor))
        guard let sphere = sphereGeometry, let cube = cubeGeometry else { return }
        self.geometry = merge(data: sphere, with: cube)
    }
}

private extension CubeOnSphere {

    func sphere(radius: Float, sectorCount: Int, stackCount: Int) -> Geometry {
        var vertices = [Float]()
        var colors = [Float]()
        var indices = [Int]()

        let sectorStep: Float = 2 * .pi / Float(sectorCount)
        let stackStep: Float = .pi / Float(stackCount)

        for i in 0...stackCount {
            let stackAngle = .pi / 2 - Float(i) * stackStep
            let xy = radius * cosf(stackAngle)
            let z = radius * sinf(stackAngle)

            for j in 0...sectorCount {
                let sectorAngle = Float(j) * sectorStep

                let x = xy * cosf(sectorAngle)
                let y = xy * sinf(sectorAngle)

                vertices.append(contentsOf: [x, y, z])
                colors.append(contentsOf: [min(abs(x), 1.0), min(abs(y), 1.0), min(abs(z), 1.0), 1.0])
            }
        }

        for i in 0..<stackCount {
            var k1 = i * (sectorCount + 1)
            var k2 = k1 + sectorCount + 1

            var j = 0
            while j < sectorCount {
                if i != 0 {
                    indices.append(k1)
                    indices.append(k2)
                    indices.append(k1 + 1)
                }
                if i != (stackCount - 1) {
                    indices.append(k1 + 1)
                    indices.append(k2)
                    indices.append(k2 + 1)
                }
                j += 1
                k1 += 1
                k2 += 1
            }
        }

        return (vertices, indices, colors)
    }

    func cube(x: Float, y: Float, z: Float, size s: Float, color: CIColor) -> Geometry {
        let vertices = [
            s + x, s + y, s + z,   -s + x, s + y, s + z,  -s + x,-s + y, s + z,
            -s + x, -s + y, s + z,   s + x, -s + y, s + z,  s + x,-s + y, -s + z,
            s + x, s + y, s + z,   s + x, -s + y, s + z,  s + x,-s + y, -s + z,
            -s + x, s + y, s + z,   -s + x, s + y, -s + z,  -s + x,-s + y, -s + z,
            -s + x, -s + y, -s + z,   -s + x, -s + y, s + z,  -s + x,s + y, s + z,
            -s + x, -s + y, -s + z,   s + x, -s + y, -s + z,  s + x,-s + y, s + z,
            -s + x, s + y, s + z,   -s + x, s + y, -s + z,  -s + x, -s + y, -s + z,
            -s + x, -s + y, -s + z,   -s + x, -s + y, s + z,  -s + x, s + y, s + z,
            -s + x, -s + y, -s + z,   s + x, -s + y, -s + z,  s + x,-s + y, s + z,
            s + x, -s + y, s + z,   -s + x, -s + y, s + z,  -s + x,-s + y, -s + z,
            s + x, -s + y, -s + z,   -s + x, -s + y, -s + z,  -s + x, s + y, -s + z,
            -s + x, s + y, -s + z,   s + x, s + y, -s + z,  s + x,-s + y, -s + z
        ]
        let indices = [
            0, 1, 2,   2, 3, 0,
            4, 5, 6,   6, 7, 4,
            8, 9,10,  10,11, 8,
            12,13,14,  14,15,12,
            16,17,18,  18,19,16,
            20,21,22,  22,23,20
        ]

        let colors: [Float] = (0..<vertices.count / 3)
            .flatMap {_ in [Float(color.red), Float(color.green), Float(color.blue), 0.99] }
        return (vertices, indices, colors)
    }

    func merge(data lhs: Geometry, with rhs: Geometry) -> Geometry {
        let max = lhs.indices.max() ?? -1
        let indices = rhs.indices.map { max + $0 + 1 }
        return (lhs.vertices + rhs.vertices, lhs.indices + indices, lhs.colors + rhs.colors)
    }
}
