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
    
    static let separatorWeight: CGFloat = 1
    static let cellIdentifier = "com.orangemako.movieCellView"
    
    override func awakeFromNib() {
        setupView()
    }
    
    override func layoutSubviews() {
        addSeparatorToBottom()
    }
    
    // MARK: - Setup View
    
    private func setupView() {
        titleLabel.font = UIFont.boldSystemFontOfSize(titleLabel.font.pointSize)
    }
    
    private func addSeparatorToBottom() {
        let separator = UIView(
            frame: CGRectMake(
                0, bounds.size.height - MovieCellView.separatorWeight,
                bounds.size.width,
                MovieCellView.separatorWeight
            )
        )
        
        separator.backgroundColor = UIColor.lightGrayColor()
        addSubview(separator)
    }
}
