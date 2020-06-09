//
//  BigCategory.swift
//  MapClustering
//
//  Created by Yoo Hwa Park on 2020/05/15.
//  Copyright © 2020 Yoo Hwa Park. All rights reserved.
//

import Foundation

struct Food {
    var category: BigCategory
    var foodImg: String
}

enum BigCategory: String {
    case korean = "한식"
    case chinese = "중식"
    case japanese = "일식"
    case world = "세계음식"
    case western = "양식"
    case cafe = "카페"
    case pub = "주점"
    case other = "기타"
}
