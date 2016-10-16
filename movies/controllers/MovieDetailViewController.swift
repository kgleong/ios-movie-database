//
//  MovieDetailViewController.swift
//  movies
//
//  Created by Kevin Leong on 9/15/16.
//  Copyright © 2016 Kevin Leong. All rights reserved.
//

import UIKit
import AFNetworking
import OMAKOView

class MovieDetailViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var movieDescriptionLabel: UILabel!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var movieSpecsParentView: OMAKOPartiallyVisibleSwipeableView!
    
    var movie: Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let loadedMovie = movie {
            if let posterUrl = loadedMovie.posterUrl("original") {
                posterImageView.setImageWithURL(posterUrl)
            }
            movieDescriptionLabel.text = loadedMovie.overview
            
            releaseDateLabel.text = loadedMovie.formattedReleaseDate()
            releaseDateLabel.font = UIFont.boldSystemFontOfSize(releaseDateLabel.font.pointSize)
            
            scoreLabel.text = loadedMovie.formattedScore()
            scoreLabel.font = UIFont.boldSystemFontOfSize(scoreLabel.font.pointSize)
            
            movieTitleLabel.text = loadedMovie.title
            movieTitleLabel.font = UIFont.boldSystemFontOfSize(movieTitleLabel.font.pointSize)
            
            movieSpecsParentView.setupView(bottomLayoutGuide: bottomLayoutGuide)
            
            if let title = loadedMovie.title {
                self.title = title
            }
        }
        edgesForExtendedLayout = UIRectEdge.None
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        movieSpecsParentView.onRotate()
    }
}
