//
//  MovieCellView.swift
//  movies
//
//  Created by Kevin Leong on 8/31/16.
//  Copyright © 2016 Kevin Leong. All rights reserved.
//

import UIKit

class MovieCellView: UITableViewCell {
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    static let cellIdentifier = "com.orangemako.movieCellView"
    
    override func awakeFromNib() {
        setupView()
    }
    
    // MARK: - Setup View
    
    private func setupView() {
        titleLabel.font = UIFont.boldSystemFontOfSize(titleLabel.font.pointSize)
    }
}
