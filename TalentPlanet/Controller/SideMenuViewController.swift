//
//  SideMenuViewController.swift
//  TalentPlanet
//
//  Created by 민권홍 on 17/10/2019.
//  Copyright © 2019 민권홍. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController {
    
    // MARK: - Variables
    var images = ["icon_dl_profile.png", "icon_dl_condition.png", "icon_dl_friend.png", "icon_claim.png", "icon_dl_logout.png"]
    var titles = ["내 프로필", "재능등록", "친구목록", "신고하기", "로그아웃"]
    @IBOutlet var tableView: UITableView!
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Functions
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
}

// MARK: - Table View
extension SideMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableCell", for: indexPath) as! MenuTableCell
        cell.ivIcon.layer.cornerRadius = cell.ivIcon.frame.size.height / 2
        cell.ivIcon.layer.masksToBounds = true
        cell.ivIcon.layer.borderWidth = 0

        cell.ivIcon.image = UIImage(named:images[indexPath.row])
        cell.lbMenuName.text = titles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
            case 0: self.performSegue(withIdentifier: "segueProfile", sender: nil)
            case 1: self.performSegue(withIdentifier: "segueTalentCate", sender: nil)
            case 2: self.performSegue(withIdentifier: "segueFriend", sender: nil)
            case 3: self.performSegue(withIdentifier: "segueClaim", sender: nil)
            case 4: self.performSegue(withIdentifier: "segueLogout", sender: nil)
        default:
            return
        }
    }
}

extension SideMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
