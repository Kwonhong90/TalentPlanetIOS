//
//  TalentRegistCell.swift
//  TalentPlanet
//
//  Created by 민권홍 on 11/11/2019.
//  Copyright © 2019 민권홍. All rights reserved.
//

import UIKit

class TalentRegistCell: UICollectionViewCell {
    
    @IBOutlet var ivMain: UIImageView!
    @IBOutlet var ivIcon: UIImageView!
    @IBOutlet var ivCircleBackground: UIImageView!
    @IBOutlet var ivBackground: UIImageView!
    @IBOutlet var lbTitle: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lbTitle.textColor = UIColor.white
        ivBackground.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        ivCircleBackground.backgroundColor = UIColor.black.withAlphaComponent(0)
    }
}
