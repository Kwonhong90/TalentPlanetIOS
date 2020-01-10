//
//  SideMenuViewController.swift
//  TalentPlanet
//
//  Created by 민권홍 on 17/10/2019.
//  Copyright © 2019 민권홍. All rights reserved.
//

import UIKit
import Alamofire

class SideMenuViewController: UIViewController {
        
    // MARK: - Variables
    var talentFlag = ""
//    var images = ["icon_dl_profile.png", "icon_dl_condition.png", "icon_dl_friend.png", "icon_claim.png", "icon_dl_logout.png"]
//    var titles = ["내 프로필", "재능등록", "친구목록", "신고하기", "로그아웃"]
    var images = ["icon_dl_profile.png", "icon_dl_condition.png", "icon_claim.png", "icon_dl_logout.png"]
    var titles = ["내 프로필", "재능등록", "신고하기", "로그아웃"]

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var lbName: UILabel!
    @IBOutlet var lbID: UILabel!
    @IBOutlet var lbPoint: UILabel!
    @IBOutlet var ivUser: UIImageView!
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(self.talentFlag)
        tableView.delegate = self
        tableView.dataSource = self
        lbID.text = UserDefaults.standard.string(forKey: "userID")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tabbar = self.tabBarController as! BaseTabBarController
        self.talentFlag = tabbar.talentFlag
        getUserInfo()
    }
    // MARK: - Functions

    func getUserInfo() {
        AF.request("http://175.213.4.39/Accepted/Profile/getMyProfileInfo_new.do", method: .post, parameters:["userID":UserDefaults.standard.string(forKey: "userID")!])
            .validate()
            .responseJSON {
                response in
                var message:String
                switch response.result {
                case .success(let value):
                    let data = value as! [String:Any]
                    self.lbName.text = data["USER_NAME"] as! String
                    self.lbPoint.text = "사용가능 포인트 \(data["TALENT_POINT"]!)P"
                    
                    if data["FILE_PATH"] as! String != "NODATA" {
                        let url = URL(string: "http://13.209.191.97/Accepted/" + (data["FILE_PATH"] as! String))
                        self.ivUser.load(url: url!)
                    } else {
                        self.ivUser.image = UIImage(named: "pic_profile.png")
                    }
                    
                    
                    
                case .failure(let error):
                    print("Error in network \(error)")
                    message = "서버 통신에 실패하였습니다. 관리자에게 문의해주시기 바랍니다."
                    let alert = UIAlertController(title: "아이디 중복확인", message: message, preferredStyle: UIAlertController.Style.alert)
                    let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                    alert.addAction(alertAction)
                    self.present(alert, animated: true, completion: nil)
                }
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "segueTalentCate":
            let talentRegistViewController = segue.destination as! TalentRegistViewController
            talentRegistViewController.talentFlag = self.talentFlag
            break
        case "segueProfile":
            let profileViewController = segue.destination as! ProfileViewController
            profileViewController.userID = UserDefaults.standard.string(forKey: "userID")!
            profileViewController.talentFlag = self.talentFlag
        case "segueLogout":
            let joinViewController = segue.destination as! JoinViewController
            
        default:
            break
        }
    }
    
}

// MARK: - Table View
extension SideMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableCell", for: indexPath) as! MenuTableCell
        //cell.ivIcon.layer.cornerRadius = cell.ivIcon.frame.size.height / 2
        //cell.ivIcon.layer.masksToBounds = true
        //cell.ivIcon.layer.borderWidth = 0

        cell.ivIcon.image = UIImage(named:images[indexPath.row])
        cell.lbMenuName.text = titles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
//            case 0:
//                self.performSegue(withIdentifier: "segueProfile", sender: nil)
//                break
//            case 1:
//                self.performSegue(withIdentifier: "segueTalentCate", sender: nil)
//                break
//            case 2:
//                self.performSegue(withIdentifier: "segueFriend", sender: nil)
//                break
//            case 3:
//                self.performSegue(withIdentifier: "segueClaim", sender: nil)
//                break
//            case 4:
//                self.navigationController?.popToRootViewController(animated: true)
//                UserDefaults.standard.removeObject(forKey: "userID")
//                break
            case 0:
                self.performSegue(withIdentifier: "segueProfile", sender: nil)
                break
            case 1:
                self.performSegue(withIdentifier: "segueTalentCate", sender: nil)
                break
            case 2:
                self.performSegue(withIdentifier: "segueClaim", sender: nil)
                break
            case 3:
                self.navigationController?.popToRootViewController(animated: true)
                UserDefaults.standard.removeObject(forKey: "userID")
                break
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
