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
    
    // MARK: - Variables
    let images = CommonFunctions().getTalentImageNameArr()
    let icons = CommonFunctions().getTalentIconNameArr()
    var talentFlag = ""
    var talentArr: [Int] = [Int](repeating: 0, count: 14)
    @IBOutlet var collectionView: UICollectionView!
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    var selectedTalentID: String!
    var selectedCateCode: Int!
    var selectedTitle: String!
    let userID = UserDefaults.standard.string(forKey: "userID")!
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var btnTeacher: UIButton!
    @IBOutlet var btnStudent: UIButton!
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.talentFlag)
        changeTalent(talentFlag: self.talentFlag)
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "segueProfile":
            let profileController = segue.destination as! ProfileViewController
            profileController.talentID = selectedTalentID
            profileController.userID = self.userID
            profileController.talentFlag = self.talentFlag
            profileController.cateCode = String(selectedCateCode!)
            profileController.titleText = self.selectedTitle
            break;
        case "segueNewProfile":
            let newTalentController = segue.destination as! NewTalentViewController
            newTalentController.cateCode = selectedCateCode
            newTalentController.talentFlag = self.talentFlag
            newTalentController.titleText = self.selectedTitle
            print(self.talentFlag)
            break;
        default:
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        changeTalent(talentFlag: self.talentFlag)
    }
    
    // MARK: - Collection View
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
        selectedTitle = CommonFunctions().getTalentTitleByCateCode(cateCode: indexPath.row + 1)
        selectedCateCode = indexPath.row + 1
        
        if talentArr[indexPath.row] > 0 {
            self.performSegue(withIdentifier: "segueProfile", sender: nil)
        }
        else {
            self.performSegue(withIdentifier: "segueNewProfile", sender: nil)
        }
    }
     
    // MARK: - Functions
    func getAllMyTalent(){
        talentArr = [Int](repeating: 0, count: 14)
        AF.request("http://175.213.4.39/Accepted/Profile/getAllMyTalent.do", method: .post, parameters:["UserID":self.userID, "CheckUserID":self.userID, "TalentFlag":self.talentFlag])
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
    
    func changeTalent(talentFlag: String){
        self.talentFlag = talentFlag
        if talentFlag == "Y" {
            btnStudent.backgroundColor = UIColor(red: 24.0/255.0, green: 33.0/255.0, blue: 45.0/255, alpha: 1.0)
            btnStudent.setTitleColor(.white, for: .normal)
            btnTeacher.backgroundColor = .white
            btnTeacher.setTitleColor(UIColor(red: 40.0/255.0, green: 54.0/255.0, blue: 74.0/255.0, alpha: 1.0), for: .normal)
            
            headerView.backgroundColor = UIColor(red: 40.0/255.0, green: 54.0/255.0, blue: 74.0/255.0, alpha: 1.0)
        } else {
            btnTeacher.backgroundColor = UIColor(red: 143.0/255.0, green: 109.0/255.0, blue: 53.0/255, alpha: 1.0)
            btnTeacher.setTitleColor(.white, for: .normal)
            btnStudent.backgroundColor = .white
            btnStudent.setTitleColor(UIColor(red: 255.0/255.0, green: 195.0/255.0, blue: 94.0/255.0, alpha: 1.0), for: .normal)
            
            headerView.backgroundColor = UIColor(red: 255.0/255.0, green: 195.0/255.0, blue: 94.0/255.0, alpha: 1.0)
        }
        
        getAllMyTalent()
    }
    
    @IBAction func clickTeacherBtn(_ sender: Any) {
        changeTalent(talentFlag: "Y")
    }
    @IBAction func clickStudentBtn(_ sender: Any) {
        print("student clicked")
        changeTalent(talentFlag: "N")
    }
}
