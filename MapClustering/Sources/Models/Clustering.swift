//
//  Clustering.swift
//  MapClustering
//
//  Created by Yoo Hwa Park on 2020/05/20.
//  Copyright © 2020 Yoo Hwa Park. All rights reserved.
//

import Foundation
import NMapsMap

class Clustering {
    private func increaseClusterSize(left: NMFMarker, right: NMFMarker) {
        if let iSize = left.userInfo["size"] as? Int {
            if let kSize = right.userInfo["size"] as? Int {
                left.userInfo["size"] = iSize + kSize
                left.captionText = String(iSize + kSize)
                left.width = CGFloat(Double(iSize + kSize) * 0.3 + 70)
                left.height = CGFloat(Double(iSize + kSize) * 0.3 + 70)
            }
        }
    }
    
    private func decreaseClusterSize(left: NMFMarker, right: NMFMarker) {
        if let iSize = left.userInfo["size"] as? Int {
            if let kSize = right.userInfo["size"] as? Int {
                left.userInfo["size"] = iSize - kSize
                left.captionText = String(iSize - kSize)
                left.width = CGFloat(Double(iSize - kSize) * 0.3 + 70)
                left.height = CGFloat(Double(iSize - kSize) * 0.3 + 70)
            }
        }
    }
    
    private func updateMergingClusters(from visibleCenterMarkers: [NMFMarker], with clusterIndex: [Int]) {
        //merge
        let iIdx = clusterIndex[0]
        let kIdx = clusterIndex[1]
        let iCenterMarker = visibleCenterMarkers[iIdx]
        let kCenterMarker = visibleCenterMarkers[kIdx]
        if var coveredMarkers = iCenterMarker.userInfo["coveredMarkers"] as? [NMFMarker] {
            coveredMarkers.append(kCenterMarker)
            iCenterMarker.userInfo["coveredMarkers"] = coveredMarkers
        }
        increaseClusterSize(left: iCenterMarker, right: kCenterMarker)
        kCenterMarker.hidden = true
    }
    
    private func mergeCluster(of visibleCenterMarkers: [NMFMarker], from distArray: [[Double]], with minDistance: Double) {
        var distanceArray = distArray

        for iIdx in 0..<visibleCenterMarkers.count {
            for kIdx in iIdx+1..<visibleCenterMarkers.count {
                if distanceArray[iIdx].contains(-1) { break }
                if distanceArray[iIdx][kIdx] < minDistance {
                    updateMergingClusters(from: visibleCenterMarkers, with: [iIdx, kIdx])
                }
                distanceArray[kIdx][iIdx] = -1
            }
        }
    }
    
    private func splitCluster(of visibleCenterMarkers: [NMFMarker], with minDistance: Double) {
        visibleCenterMarkers.forEach { centerMarker in
            if let coveredMarkers = centerMarker.userInfo["coveredMarkers"] as? [NMFMarker] {
                var markersToSplit: [NMFMarker] = []
                coveredMarkers.forEach { coveredMarker in
                    let iPos = centerMarker.position
                    let kPos = coveredMarker.position
                    if Vector([iPos.lat, iPos.lng]).distanceTo(Vector([kPos.lat, kPos.lng])) > minDistance {
                        markersToSplit.append(coveredMarker)
                        decreaseClusterSize(left: centerMarker, right: coveredMarker)
                        coveredMarker.hidden = false
                    }
                }
                centerMarker.userInfo["coveredMarkers"] = coveredMarkers.filter { !markersToSplit.contains($0) }
            }
        }
    }
    
    private func makeDistanceArray(with centerMarkers: [NMFMarker]) -> [[Double]] {
        var distanceArray = Array(repeating: Array(repeating: 0.0, count: centerMarkers.count), count: centerMarkers.count)
        for iIdx in 0..<centerMarkers.count {
            for kIdx in iIdx..<centerMarkers.count {
                let iPos = centerMarkers[iIdx].position
                let kPos = centerMarkers[kIdx].position
                distanceArray[iIdx][kIdx] = Vector([iPos.lat, iPos.lng]).distanceTo(Vector([kPos.lat, kPos.lng]))
                distanceArray[kIdx][iIdx] = distanceArray[iIdx][kIdx]
            }
        }
        return distanceArray
    }
    
    func calcZoomClustering(with mapView: NMFMapView, centerMarkers: [NMFMarker]) {
        let minDistance = (mapView.contentBounds.northEastLng - mapView.contentBounds.southWestLng) / 4
        
        let distanceArray = makeDistanceArray(with: centerMarkers)
        
        let visibleCenterMarkers = centerMarkers.filter { !$0.hidden }
        mergeCluster(of: visibleCenterMarkers, from: distanceArray, with: minDistance)
        splitCluster(of: visibleCenterMarkers, with: minDistance)
    }
}
