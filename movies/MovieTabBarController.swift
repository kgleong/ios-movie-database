//
//  MovieTabBarController.swift
//  movies
//
//  Created by Kevin Leong on 10/11/16.
//  Copyright © 2016 Kevin Leong. All rights reserved.
//

import UIKit

class MovieTabBarController: UITabBarController {
    let tabBarPadding: CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - View Setup
    
    func setupView() {
        // Create separate navigation controllers for each tab
        let nowPlayingNavigationController = createNavigationController()
        let topRatedNavigationController = createNavigationController()
        
        // Only 1 view controller associated with the IB configured navigation controller,
        // so get a reference to it.
        let nowPlayingViewController = nowPlayingNavigationController.viewControllers.first as! MovieListViewController
        
        // The moviePath allows specific configuration of the view controller.
        nowPlayingViewController.moviePath = MovieDatabaseClient.nowPlayingPath
        
        // Places the correct text and image in the tab bar item.
        nowPlayingViewController.setTabBarItem()
        
        let topRatedViewController = topRatedNavigationController.viewControllers.first as! MovieListViewController
        topRatedViewController.moviePath = MovieDatabaseClient.topRatedPath
        topRatedViewController.setTabBarItem()
        
        // Add both view controllers to the tab bar controller.
        viewControllers = [
            nowPlayingNavigationController,
            topRatedNavigationController,
        ]
    }
    
    func createNavigationController() -> MovieListNavigationController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        return storyboard
            .instantiateViewControllerWithIdentifier(
                MovieListNavigationController.identifier
            ) as! MovieListNavigationController
    }
}
