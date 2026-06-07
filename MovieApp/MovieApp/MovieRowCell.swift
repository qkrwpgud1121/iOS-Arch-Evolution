//
//  MovieRowCell.swift
//  MovieApp
//
//  Created by 박제형 on 6/7/26.
//

import UIKit

class MovieRowCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
