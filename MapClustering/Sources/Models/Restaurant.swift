//
//  Restaurant.swift
//  MapClustering
//
//  Created by Yoo Hwa Park on 2020/05/13.
//  Copyright © 2020 Yoo Hwa Park. All rights reserved.
//

import Foundation

struct Restaurant: Codable {
    var id: String
    var name: String
    private var latitude: String
    private var longitude: String
    var imageUrl: String?
    var category: String
    
    var lat: Double {
        return (latitude as NSString).doubleValue
    }
    var lng: Double {
        return (longitude as NSString).doubleValue
    }
    var bigCategory: [BigCategory] {
        if category == "중식당" {
            return [.chinese]
        } else if ["양식","이탈리아음식","햄버거","스테이크,립","프랑스음식"].contains(category) {
            return [.western]
        } else if ["일식당","생선회","우동,소바","일본식라면","초밥,롤","덮밥"].contains(category) {
            return [.japanese]
        } else if ["베트남음식","인도음식","멕시코,남미음식"].contains(category) {
            return [.world]
        } else if ["베이커리","샌드위치","카페,디저트","카페","테이크아웃커피","과일,주스전문점","차","도넛","다방","떡카페","과일,주스전문점"].contains(category) {
            return [.cafe]
        } else if ["바(BAR)","맥주,호프","단란주점","술집","와인","요리주점","유흥주점"].contains(category) {
            return [.pub]
        } else if category == "돈가스" {
            return [.korean, .japanese]
        } else if category == "이자카야" {
            return [.japanese, .pub]
        } else if ["육류,고기요리","소고기 구이","돼지고기구이","닭요리","뷔페","오리요리","퓨전음식","소고기구이"].contains(category) {
            return [.other]
        } else {
            return [.korean]
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case latitude = "y"
        case longitude = "x"
        case imageUrl
        case category
    }
}

struct Restaurants: Codable {
    var places: [Restaurant]
}
