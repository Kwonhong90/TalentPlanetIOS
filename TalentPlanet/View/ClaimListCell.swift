//
//  ClaimListCell.swift
//  TalentPlanet
//
//  Created by 민권홍 on 13/01/2020.
//  Copyright © 2020 민권홍. All rights reserved.
//

import UIKit

class ClaimListCell: UITableViewCell {

    @IBOutlet var lbTitle: UILabel!
    @IBOutlet var lbRegDate: UILabel!
    @IBOutlet var lbStatus: UILabel!
    
    @IBOutlet var detailView: UIView!
    @IBOutlet var lbClaimUser: UILabel!
    @IBOutlet var lbClaimType: UILabel!
    @IBOutlet var lbClaimDate: UILabel!
    @IBOutlet var lbClaimContent: UILabel!
    
    @IBOutlet var bottomView: UIView!
    @IBOutlet var lbBottomComment: UILabel!
}
