//
//  PictureViewController.swift
//  TalentPlanet
//
//  Created by 민권홍 on 07/01/2020.
//  Copyright © 2020 민권홍. All rights reserved.
//

import UIKit

class PictureViewController: UIViewController {

    @IBOutlet var ivUser: UIImageView!
    var filePath: String?
    var userName: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if filePath! == "NODATA" {
            ivUser.image = UIImage(named: "pic_profile.png")
        } else {
            let url = URL(string: "http://13.209.191.97/Accepted/" + filePath!)
            self.ivUser.load(url: url!)
        }
        
        self.title = userName
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
