//
//  SearchResult.swift
//  Wikipeter
//
//  Created by Adrian Böhme on 28.04.20.
//  Copyright © 2020 Adrian Böhme. All rights reserved.
//

import Foundation

class SearchResult: Decodable {
    let query: Query
}

class Query: Decodable {
    let geosearch: [Result]
}

class Result: NSObject, Decodable, Identifiable, ObservableObject {
    let pageid: Int
    let title: String
    let lat: Double
    let lon: Double
    let dist: Double
}
