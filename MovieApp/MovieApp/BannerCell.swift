//
//  BannerCell.swift
//  MovieApp
//
//  Created by 박제형 on 6/14/26.
//

import UIKit

class BannerCell: UITableViewCell {
    
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var wishlistButton: UIButton!
    
    @IBAction func playButtonClicked(_ sender: UIButton) {
        print("재생 버튼 클릭")
    }
    
    @IBAction func wishlistButtonClicked(_ sender: UIButton) {
        print("위시리스트 클릭")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        playButton.layer.cornerRadius = 4
        wishlistButton.layer.cornerRadius = 4
    }
    
}
