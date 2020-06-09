import Foundation

class KMeans {
    var centroidCnt: Int
    private(set) var centroids = [Vector]()
    var clusterDict = [Vector: [Vector]]()

    init?(centroidCnt: Int) {
        guard centroidCnt > 0 else { return nil }
        self.centroidCnt = centroidCnt
    }

    private func indexOfNearestCenter(_ vecX: Vector, centers: [Vector]) -> Int {
        var nearestDist = Double.greatestFiniteMagnitude
        var minIndex = 0

        for (idx, center) in centers.enumerated() {
            let dist = vecX.distanceTo(center)
            if dist < nearestDist {
                minIndex = idx
                nearestDist = dist
            }
        }
        return minIndex
    }

    func trainCenters(_ points: [Vector], convergeDistance: Double) {
        if points.count < centroidCnt { centroidCnt = points.count }
        let zeroVector = Vector([Double](repeating: 0, count: points[0].length))

        // Randomly take k objects from the input data to make the initial centroids.
        var centers = reservoirSample(points, end: centroidCnt)

        var centerMoveDist = 0.0
        repeat {
            // This array keeps track of which data points belong to which centroids.
            var classification: [[Vector]] = .init(repeating: [], count: centroidCnt)

            // For each data point, find the centroid that it is closest to.
            for point in points {
                let classIndex = indexOfNearestCenter(point, centers: centers)
                classification[classIndex].append(point)
            }

            // Take the average of all the data points that belong to each centroid.
            // This moves the centroid to a new position.
            let newCenters = classification.map { assignedPoints in
                assignedPoints.reduce(zeroVector, +) / Double(assignedPoints.count)
            }

            // Find out how far each centroid moved since the last iteration. If it's
            // only a small distance, then we're done.
            centerMoveDist = 0.0
            for idx in 0..<centroidCnt {
                centerMoveDist += centers[idx].distanceTo(newCenters[idx])
            }

            centers = newCenters
        } while centerMoveDist > convergeDistance

        centroids = centers
    }

    func fit(_ point: Vector) {
        assert(!centroids.isEmpty, "Exception: KMeans tried to fit on a non trained model.")

        let centroidIndex = indexOfNearestCenter(point, centers: centroids)
        let keyExists = clusterDict[centroids[centroidIndex]] != nil
        if keyExists {
            clusterDict[centroids[centroidIndex]]?.append(point)
        } else {
            clusterDict[centroids[centroidIndex]] = [point]
        }
    }

    func fit(_ points: [Vector]) -> [Vector:[Vector]] {
        assert(!centroids.isEmpty, "Exception: KMeans tried to fit on a non trained model.")

        points.forEach(fit)
        return clusterDict
    }

    // Pick k random elements from samples
    func reservoirSample<T>(_ samples: [T], end: Int) -> [T] {
        var result = [T]()

        // Fill the result array with first k elements
        for index in 0..<end {
            result.append(samples[index])
        }

        // Randomly replace elements from remaining pool
        for index in end..<samples.count {
            let nextIndex = Int(arc4random_uniform(UInt32(index + 1)))
            if nextIndex < end {
                result[nextIndex] = samples[index]
            }
        }
        return result
    }
}
