import Foundation

class MovieDatabaseClient {
    static let scheme = "https"
    static let host = "api.themoviedb.org"
    static let apiKeyParam = "api_key"
    static var apiKey: String?
    
    // Movie paths
    static let nowPlayingPath = "/now_playing"
    static let topRatedPath = "/top_rated"
    
    // MARK: - Class Methods
    
    class func createUrl(path: String, queryParams: [NSURLQueryItem]?) -> NSURL? {
        let urlComponent = NSURLComponents()
        
        urlComponent.scheme = scheme
        urlComponent.host = host
        urlComponent.path = path
        urlComponent.queryItems = [apiKeyQueryParam()]
        
        if let queryParams = queryParams {
            urlComponent.queryItems?.appendContentsOf(queryParams)
        }
        
        return urlComponent.URL
    }
    
    class func apiKeyQueryParam() -> NSURLQueryItem {
        return NSURLQueryItem(name: apiKeyParam, value: apiKey!)
    }
    
    class func logRequest(url: NSURL) {
        print("Making request to: \(url)")
    }
}