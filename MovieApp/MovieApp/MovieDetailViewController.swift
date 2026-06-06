//
//  MovieDetailViewController.swift
//  MovieApp
//
//  Created by 박제형 on 6/6/26.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movie: Movie?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI() {
        
        guard let movie = movie else { return }
        
        self.navigationItem.title = movie.title
        titleLabel.text = movie.title
        dateLabel.text = movie.releaseDate
        overviewLabel.text = movie.overview
        
        if let posterPath = movie.posterPath {
            if let url = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)") {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.posterImageView.image = image
                        }
                    }
                }
            }
        }
    }

}
