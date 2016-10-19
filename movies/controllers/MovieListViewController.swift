//
//  HomeViewController.swift
//  movies
//
//  Created by Kevin Leong on 8/31/16.
//  Copyright © 2016 Kevin Leong. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MovieListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var moviesTableView: UITableView!
    
    var movieTitleSearchBar = UISearchBar()
    var refreshControl = UIRefreshControl()
    
    let movieDetailSegueId = "movieCellSelected"
    var moviePath: String?

    var allMovies = [Movie]()
    var movies = [Movie]()
    var page: Int?
    var totalPages: Int?
    var lastFetched = 0
    var haveAllMoviesBeenFetched = false
    var isFetchingMovies = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        fetchMovies()
    }
    
    // MARK: - View Configuration
    
    func setupView() {
        setupSearchBar()
        setupTableView()
        
        if let navigationController = self.navigationController {
            if let topItem = navigationController.navigationBar.topItem {
                topItem.titleView = movieTitleSearchBar
            }
        }
        
        edgesForExtendedLayout = UIRectEdge.None
    }
    
    func setupTableView() {
        // Refresh control
        refreshControl.attributedTitle = NSAttributedString(string: "Loading")
        refreshControl.addTarget(self, action: #selector(refreshMovies), forControlEvents: UIControlEvents.ValueChanged)
        moviesTableView.insertSubview(refreshControl, atIndex: 0)
        
        moviesTableView.delegate = self
        moviesTableView.dataSource = self
        moviesTableView.allowsSelection = true
        moviesTableView.separatorColor = UIColor.clearColor()
    }
    
    func setupSearchBar() {
        movieTitleSearchBar.placeholder = "Search movies"
        movieTitleSearchBar.delegate = self
    }
    
    func setTabBarItem() {
        if let navController = navigationController {
            if let path = moviePath {
                var tabBarItem: UITabBarItem?
                
                switch path {
                case MovieDatabaseClient.nowPlayingPath:
                    tabBarItem = UITabBarItem(
                        title: "Now Playing",
                        image: UIImage(named: "now-playing-tab-bar-icon"),
                        selectedImage: UIImage(named: "now-playing-tab-bar-icon")
                    )
                case MovieDatabaseClient.topRatedPath:
                    tabBarItem = UITabBarItem(
                        title: "Top Rated",
                        image: UIImage(named: "top-rated-tab-bar-icon"),
                        selectedImage: UIImage(named: "top-rated-tab-bar-icon")
                    )
                default:
                    print("Invalid path")
                }
                
                if let tabBarItem = tabBarItem {
                    navController.tabBarItem = tabBarItem
                    self.title = tabBarItem.title
                }
            }
        }
    }
    
    // MARK: - Fetching Movies
    
    func refreshMovies() {
        allMovies = [Movie]()
        
        resetPageState()
        fetchMovies()
    }
    
    func resetPageState() {
        page = nil
        totalPages = nil
        lastFetched = 0
        haveAllMoviesBeenFetched = false
    }
    
    // Cannot be private since it needs to be exposed to Obj-C for the
    // UIRefreshControl.addTarget(_:action:forControlEvents:) method
    func fetchMovies() {
        if haveAllMoviesBeenFetched || isFetchingMovies {
            return
        }

        MBProgressHUD.showHUDAddedTo(self.view, animated: true)

        if let page = page {
            if let totalPages = totalPages {
                if page < totalPages {
                    self.page = page + 1
                }
                else {
                    haveAllMoviesBeenFetched = true
                }
            }
        }
        
        isFetchingMovies = true
        
        Movie.getMovies(moviePath!, page: page) {
            (data, response, error) in
            self.onFetchMoviesComplete(data, response: response, error: error)
        }
    }
    
    private func onFetchMoviesComplete(data: NSData?, response: NSURLResponse?, error: NSError?) {
        isFetchingMovies = false
        
        // Print out response information
        if let httpResponse = response as? NSHTTPURLResponse {
            print("status code: \(httpResponse.statusCode)")
            print("url: \(httpResponse.URL!)")
            print("headers:")
            for (key, value) in httpResponse.allHeaderFields {
                print("\t\(key): \(value)")
            }
        }
        
        if error != nil {
            // Handle HTTP request error
            print("An error occurred while loading now playing list: \(error?.localizedDescription)")
        }
        else {
            if let rawData = data {
                do {
                    // jsonResponse is either an NSArray or NSDictionary with String keys
                    let jsonResponse = try NSJSONSerialization.JSONObjectWithData(rawData, options: [])

                    self.page = jsonResponse["page"] as? Int
                    self.totalPages = jsonResponse["total_pages"] as? Int
                    
                    // Conditionally
                    if let moviesJson = jsonResponse["results"] as? [[String: AnyObject]] {
                        for movieJson in moviesJson {
                            self.allMovies.append(Movie(parsedJson: movieJson))
                        }
                        self.movies = allMovies
                    }
                    else {
                        // Handle casting error
                    }

                }
                catch let error as NSError {
                    // Handle JSON parsing error
                    print("\(error.localizedDescription)")
                }
            }
            else {
                // Handle nil data object
            }
        }
        
        lastFetched = self.allMovies.count - 1
        
        // Refresh table view on the main UI thread
        dispatch_async(dispatch_get_main_queue()) {
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            self.refreshControl.endRefreshing()
            self.moviesTableView.reloadData()
        }
    }
    
    // MARK: - Search Bar Delegate functions
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.characters.count > 0) {
            movies = allMovies.filter() {
                (movie: Movie) -> Bool in
                
                if let title = movie.title {
                    do {
                        let regex = try NSRegularExpression(pattern: "\(searchText)", options: NSRegularExpressionOptions.CaseInsensitive)
                        
                        return regex.numberOfMatchesInString(title, options: [], range: NSMakeRange(0, title.characters.count)) > 0
                    }
                    catch {
                        // If there's a regex error, return the entire array
                        return true
                    }
                }
                else {
                    return false
                }
            }
        }
        else {
            movies = allMovies
        }
        moviesTableView.reloadData()
    }
    
    // Called when search bar obtains focus.  I.e., user taps on the search bar to enter text.
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.showsCancelButton = false
        
        // Removes focus from the search bar
        searchBar.endEditing(true)
        
        movies = allMovies
        moviesTableView.reloadData()
    }
    
    // MARK: - TableView Delegate Functions
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = moviesTableView.dequeueReusableCellWithIdentifier(MovieCellView.cellIdentifier) as! MovieCellView
        
        let movie = movies[indexPath.row]
        
        cell.descriptionLabel.text = movie.overview
        cell.titleLabel.text = movie.title
        
        if let posterUrl = movie.posterUrl() {
            cell.thumbnailImage.setImageWithURL(posterUrl)
        }
        
        if(indexPath.row >= lastFetched && !haveAllMoviesBeenFetched){
            fetchMovies()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Deselect row when coming back to this controller in a navigation controller context
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == movieDetailSegueId {
            if let movieDetailViewController = segue.destinationViewController as? MovieDetailViewController {
                if let indexPath = moviesTableView.indexPathForSelectedRow {
                    movieDetailViewController.movie = movies[indexPath.row]
                }
            }
        }
    }
}