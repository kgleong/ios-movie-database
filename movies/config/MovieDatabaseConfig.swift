//
//  MovieDatabaseConfig.swift
//  movies
//
//  Created by Kevin Leong on 9/7/16.
//  Copyright © 2016 Kevin Leong. All rights reserved.
//

import Foundation

class MovieDatabaseConfig {
    static let configPath = "/3/configuration"
    
    static var secureBaseImageUrl: String?
    static var posterSizes: [String]?
    
    // MARK: - Class Methods
    class func loadConfig(performAsync: Bool = true, onComplete: () -> Void) {
        var isComplete = false
        let url = MovieDatabaseClient.createUrl(configPath, queryParams: nil)
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.dataTaskWithRequest(NSURLRequest(URL: url!)) {
            (data, response, responseError) in
            if let rawData = data {
                do {
                    let jsonResponse = try NSJSONSerialization.JSONObjectWithData(rawData, options: [])
                    
                    if let rawImageConfig = jsonResponse["images"] as? [String: AnyObject] {
                        loadImageConfig(rawImageConfig)
                    }
                    onComplete()
                }
                catch let error as NSError {
                    // Handle JSON parsing error
                    print("\(error.localizedDescription)")
                }
            }
            else {
                // No data present
            }
            isComplete = true
        }
        task.resume()
        
        if(!performAsync) {
            while(!isComplete){}
        }
    }
    
    class func loadImageConfig(rawConfig: [String: AnyObject]) {
        secureBaseImageUrl = rawConfig["secure_base_url"] as? String
        posterSizes = rawConfig["poster_sizes"] as? [String]
        
        if let posterSizesUnwrapped = posterSizes {
            print("Poster sizes: \(posterSizesUnwrapped)")
        }
    }
}
