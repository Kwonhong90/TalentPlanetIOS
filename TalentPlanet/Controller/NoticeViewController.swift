//
//  NoticeViewController.swift
//  TalentPlanet
//
//  Created by 민권홍 on 13/01/2020.
//  Copyright © 2020 민권홍. All rights reserved.
//

import UIKit

class NoticeViewController: UIViewController {

    // MARK: - Variables
    @IBOutlet var lbTitle: UILabel!
    @IBOutlet var lbDate: UILabel!
    @IBOutlet var tvContent: UITextView!
    var noticeTitle: String!
    var noticeDate: String!
    var noticeContent: String!
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()

        lbTitle.text = noticeTitle
        lbDate.text = noticeDate
        tvContent.text = noticeContent
    }
    
    // MARK: - Functions

}
