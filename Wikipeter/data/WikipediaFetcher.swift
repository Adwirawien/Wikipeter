//
//  WikipediaFetcher.swift
//  Wikipeter
//
//  Created by Adrian Böhme on 28.04.20.
//  Copyright © 2020 Adrian Böhme. All rights reserved.
//

import Foundation

class WikipediaFetcher {
    func buildURL(languageCode: String, action: String, queries: Dictionary<String, Any>) -> URL? {
        var queryString: String = "";
        for (key, param) in queries {
            queryString += "&\(key)=\(param)"
        }
        queryString = queryString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return URL(string: "https://\(languageCode).wikipedia.org/w/api.php?origin=*&action=\(action)&format=json\(queryString)")
    }
    
    func buildGeosearchURL(languageCode: String,
        latitude: Double,
        longitude: Double,
        radius: Int,
        limit: Int) -> URL? {
        buildURL(languageCode: languageCode,
            action: "query",
            queries: ["list": "geosearch",
                "gscoord": "\(latitude)|\(longitude)",
                "gsradius": radius,
                "gslimit": limit
            ])
    }

    public func getArticlesNearby(latitude: Double, longitude: Double, completionHandler: @escaping ([Result]) -> Void) {
        let url = buildGeosearchURL(languageCode: "de", latitude: latitude, longitude: longitude, radius: 10000, limit: 125)
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let error = error {
                print("Error with fetching locations: \(error)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    print("Error with the response, unexpected status code: \(String(describing: response))")
                    return
            }

            if let data = data,
                let geoSearch = try? JSONDecoder().decode(SearchResult.self, from: data) {
                completionHandler(geoSearch.query.geosearch)
            }
        }
        task.resume()
    }
}
