//
//  Movie.swift
//  movies
//
//  Created by Kevin Leong on 8/31/16.
//  Copyright © 2016 Kevin Leong. All rights reserved.
//

import Foundation

class Movie {
    static let moviesPath = "/3/movie"
    static let nowPlayingPath = "/now_playing"
    
    var overview: String?
    var popularity: Double?
    var posterPath: String?
    var title: String?
    var voteAverage: Double?
    var releaseDate: NSDate?

    init(parsedJson: [String: AnyObject]) {
        if let overview = parsedJson["overview"] as? String {
            self.overview = overview
        }
        
        if let popularity = parsedJson["popularity"] as? Double {
            self.popularity = popularity
        }
        
        if let posterPath = parsedJson["poster_path"] as? String {
            self.posterPath = posterPath
        }
        
        if let title = parsedJson["title"] as? String {
            self.title = title
        }
        
        if let voteAverage = parsedJson["vote_average"] as? Double {
            self.voteAverage = voteAverage
        }
        
        if let releaseDate = parsedJson["release_date"] as? String {
            let toDateFormatter = NSDateFormatter()
            toDateFormatter.dateFormat = "yyyy-MM-dd"

            self.releaseDate = toDateFormatter.dateFromString(releaseDate)
        }
    }
    
    func formattedReleaseDate() -> String? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        var formattedString: String?
        
        if let releaseDate = self.releaseDate {
            formattedString = dateFormatter.stringFromDate(releaseDate)
        }
        
        return formattedString
    }
    
    func formattedScore() -> String? {
        var formattedScore: String?
        
        if let score = voteAverage {
            formattedScore = String(format: "%.1f", score)
        }
        
        return formattedScore
    }
    
    func posterUrl(size: String = "w500") -> NSURL? {
        if let unwrappedPosterPath = posterPath {
            let url = "\(MovieDatabaseConfig.secureBaseImageUrl!)\(size)\(unwrappedPosterPath)"
            
            if let urlComponent = NSURLComponents(string: url) {
                urlComponent.queryItems = [MovieDatabaseClient.apiKeyQueryParam()]
                
                return urlComponent.URL
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    // MARK: - Class Methods
    
    class func getMovies(path: String, page: Int?, onComplete: (NSData?, NSURLResponse?, NSError?) -> Void) {
        var queryParams = [NSURLQueryItem]()
        
        if let page = page {
            queryParams.append(NSURLQueryItem(name: "page", value: "\(page)"))
        }
        
        let url = MovieDatabaseClient.createUrl("\(moviesPath)\(path)", queryParams: queryParams)!
        MovieDatabaseClient.logRequest(url)

        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.dataTaskWithRequest(NSURLRequest(URL: url), completionHandler: onComplete)
        task.resume()
    }
}
