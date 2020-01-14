//
//  CustomerCenterViewController.swift
//  TalentPlanet
//
//  Created by 민권홍 on 10/01/2020.
//  Copyright © 2020 민권홍. All rights reserved.
//

import UIKit

class CustomerCenterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Variables
    let menu = ["공지사항", "개인정보 이용동의", "정보 이용동의", "신고리스트", "질문과 답변", "회원탈퇴"]
    @IBOutlet var tableView: UITableView!
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerCenterCell", for: indexPath) as! CustomerCenterCell
        cell.lbTitle.text = menu[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.performSegue(withIdentifier: "segueNoticeList", sender: nil)
            return
        case 1:
            UIApplication.shared.open(URL(string: "http://13.209.191.97/Accepted/Privacy")!, options: [:], completionHandler: nil)
            return
        case 2:
            UIApplication.shared.open(URL(string: "http://13.209.191.97/Accepted/Service")!, options: [:], completionHandler: nil)
            return
        case 3:
            self.performSegue(withIdentifier: "segueClaimList", sender: nil)
            return
        case 4:
            self.performSegue(withIdentifier: "segueQna", sender: nil)
            return
        case 5:
            self.performSegue(withIdentifier: "segueWithdrawal", sender: nil)
            return
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // MARK: - Functions


}
