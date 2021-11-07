//
//  EatLogCollectionViewCell.swift
//  diEAT
//
//  Created by 문다 on 2021/11/04.
//

import UIKit

class EatLogCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var eatImage: UIImageView!
    @IBOutlet weak var eatLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        eatImage.image = nil
        eatLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
