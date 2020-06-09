//
//  Centroid.swift
//  MapClustering
//
//  Created by 조윤영 on 2020/05/17.
//  Copyright © 2020 Yoo Hwa Park. All rights reserved.
//

import Foundation

struct Centroid {
    var kmeans: KMeans
    var clusterDict: [Vector: [Vector]]
}
