//
//  TalentRegistViewController.swift
//  TalentPlanet
//
//  Created by 민권홍 on 11/11/2019.
//  Copyright © 2019 민권홍. All rights reserved.
//

import UIKit
import Alamofire

class TalentRegistViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let images = CommonFunctions().getTalentImageNameArr()
    let icons = CommonFunctions().getTalentIconNameArr()
    var talentArr: [Int] = [Int](repeating: 0, count: 13)
    @IBOutlet var collectionView: UICollectionView!
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    var selectedTalentID: String!
    var selectedCateCode: Int!
    let userID = UserDefaults.standard.string(forKey: "userID")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllMyTalent(talentFlag: "Y")
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TalentRegistCell", for: indexPath) as! TalentRegistCell
        cell.ivMain.image = UIImage(named: images[indexPath.row])
        if talentArr[indexPath.row] != 0 {
            cell.ivIcon.image = UIImage(named: icons[indexPath.row])
            cell.ivIcon.image = cell.ivIcon.image?.withRenderingMode(.alwaysTemplate)
            
            cell.ivCircleBackground.layer.cornerRadius = cell.ivCircleBackground.frame.size.height / 2
            cell.ivCircleBackground.layer.masksToBounds = true
            cell.ivCircleBackground.layer.borderWidth = 0
            cell.ivCircleBackground.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            
            cell.ivIcon.tintColor = UIColor.black
            cell.lbTitle.textColor = UIColor.black
            
            cell.ivCircleBackground.bringSubviewToFront(cell.ivIcon)
            cell.ivCircleBackground.bringSubviewToFront(cell.lbTitle)
            cell.ivBackground.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        } else {
            cell.ivIcon.image = UIImage(named: "icon_add.png")
            cell.ivCircleBackground.backgroundColor = UIColor.black.withAlphaComponent(0)
        }
        
        cell.lbTitle.text = CommonFunctions().getTalentTitleByCateCode(cateCode: indexPath.row + 1)
        return cell
    }
    
    
    // 높이 조절
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowlayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = (flowlayout?.minimumInteritemSpacing ?? 0.0) + (flowlayout?.sectionInset.left ?? 0.0) + (flowlayout?.sectionInset.right ?? 0.0)
        let size: CGFloat = (self.collectionView.frame.size.width - space) / 2.0

        
        return CGSize(width: size, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedTalentID = String(talentArr[indexPath.row])
        
        if talentArr[indexPath.row] > 0 {
            self.performSegue(withIdentifier: "segueProfile", sender: nil)
        }
        else {
            selectedCateCode = indexPath.row + 1
            self.performSegue(withIdentifier: "segueNewProfile", sender: nil)
        }
    }
     
    func getAllMyTalent(talentFlag: String){
        AF.request("http://175.213.4.39/Accepted/Profile/getAllMyTalent.do", method: .post, parameters:["UserID":self.userID, "CheckUserID":self.userID, "TalentFlag":talentFlag])
            .validate()
            .responseJSON {
                response in
                var message:String
                switch response.result {
                case .success(let value):
                    let jsonArray = value as! [[String:Any]]
                        
                    for json in jsonArray {
                        self.talentArr[json["Code"] as! Int - 1] = json["TalentID"] as! Int
                    }

                    self.collectionView.reloadData()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "segueProfile":
            let profileController = segue.destination as! ProfileViewController
            profileController.talentID = selectedTalentID
            profileController.userID = self.userID
            profileController.talentFlag = "Y"
            break;
        case "segueNewTalent":
            let newTalentController = segue.destination as! NewTalentViewController
            newTalentController.cateCode = selectedCateCode
            newTalentController.talentFlag = "Y"
            break;
        default:
            return
        }
    }
}
