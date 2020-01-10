//
//  TalentShareViewController.swift
//  TalentPlanet
//
//  Created by 민권홍 on 15/10/2019.
//  Copyright © 2019 민권홍. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class TalentShareViewController: UIViewController{
    
    // MARK: - Variables
    var datas:[TalentListData] = []
    var titleName = ""
    var cateCode = ""
    var isSearch: Bool = false
    var searchHashTag: String?
    var tfHashtag: UITextField?
    @IBOutlet var sharingTableView: UITableView!
    
    // 프로필로 전달할 변수
    var selectedTalentID: String = ""
    var selectedTalentFlag: String = ""
    var selectedUserID: String = ""
    
    var talentFlag: String = "Y"
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()

        sharingTableView.delegate = self
        sharingTableView.dataSource = self
        
        if isSearch {
            initNavigationItemTitleView()
            if searchHashTag != nil {
                tfHashtag!.text = searchHashTag
                getTalentList()
            }
        } else {
            getTalentList()
            self.title = titleName
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "segueProfile":
            let profileViewContorller = segue.destination as! ProfileViewController
            profileViewContorller.talentFlag = self.selectedTalentFlag
            profileViewContorller.userID = self.selectedUserID
            profileViewContorller.talentID = self.selectedTalentID
            profileViewContorller.cateCode = self.cateCode
            profileViewContorller.titleText = self.titleName
        default:
            return
        }
    }
    
    // MARK: - Functions
    func getTalentList(){
        var params: [String:Any]!
        var url: String!
        if isSearch {
            params = ["UserID":"mkh9012@naver.co", "Hashtag": self.tfHashtag!.text!, "TalentFlag":self.talentFlag]
            url = "searchTalentListByHashtag.do"
        } else {
            params = ["UserID":"mkh9012@naver.co", "CateCode":cateCode, "TalentFlag":self.talentFlag]
            url = "getTalentListNew.do"
        }
        AF.request("http://175.213.4.39/Accepted/TalentSharing/\(String(describing: url!))", method: .post,
                   parameters:params)
            .validate()
            .responseJSON {
                response in
                var message:String
                switch response.result {
                case .success(let value):
                    let jsonArray = value as! [[String:Any]]
                    
                    for json in jsonArray {
                        
                        let data :TalentListData = TalentListData()
                        data.profileImageUri = json["FILE_PATH"] as! String
                        data.userName = json["USER_NAME"] as! String
                        data.userGender = json["GENDER"] as! String
                        data.userBirth = json["USER_BIRTH"] as! String
                        data.userID = json["UserID"] as! String
                        data.talentID = String(json["TalentID"] as! Int)
                        if let lat = json["GP_LAT"] as? String {
                            
                            let lng = json["GP_LNG"] as! String
                            
                            let myLocation = CLLocation(latitude: 37.208374, longitude: 126.839717)
                            let userLocation = CLLocation(latitude: Double(lat)!, longitude: Double(lng)!)
                            let distance = round(myLocation.distance(from: userLocation) / 1000 * 100)
                            data.distance = String(distance / 100) + "Km"
                        }

                        data.tag = (json["HASHTAG"] != nil) ? json["HASHTAG"] as! String : ""
                        self.datas.append(data)
                    }
                    DispatchQueue.main.async {
                        self.sharingTableView.reloadData()
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
    
    // 타이틀 초기화
    private func initNavigationItemTitleView() {
        
        let searchBtn = UIBarButtonItem(image: UIImage(), style: .plain, target: self, action: #selector(searchHashtag))
        if talentFlag == "Y" {
            searchBtn.image = UIImage(named: "icon_search_teacher.png")
        } else {
            searchBtn.image = UIImage(named: "icon_search_student.png")
        }
        
        //let searchHashtagGesture = UITapGestureRecognizer(target: self, action: #selector(searchHashtag(_:)))
        //searchBtn.action = #selector(searchHashtag(_:))
        self.navigationItem.rightBarButtonItem = searchBtn
        let titleView = UITextField()
        titleView.placeholder = "해시태그 검색"
        titleView.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
        
        self.tfHashtag = titleView
        self.navigationItem.titleView = titleView
    }

    @objc func searchHashtag() {
        print(1212)
        getTalentList()
    }
}

extension TalentShareViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    // 행 정보 표시
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 행 가져오기
        let cell = tableView.dequeueReusableCell(withIdentifier: "TalentShareCell", for: indexPath) as! TalentShareCell
        
        // 프사 동그랗게 만들기
        cell.iv_user.layer.cornerRadius = cell.iv_user.frame.size.height / 2
        cell.iv_user.layer.masksToBounds = true
        cell.iv_user.layer.borderWidth = 0
        
        // 서버에서 가져온 데이터 하나씩 꺼내기
        let rowData:TalentListData = datas[indexPath.row]
        
        // 프사 있는지 없는지 확인
        if rowData.profileImageUri == "NODATA" {
            cell.iv_user.image = UIImage(named:"pic_profile.jpg")
        }
        else {
            let url = URL(string: "http://13.209.191.97/Accepted/" + rowData.profileImageUri)
            cell.iv_user.load(url: url!)
        }
        
        // 성별
        cell.iv_gender.image = (rowData.userGender == "남") ? UIImage(named: "icon_male.png") : UIImage(named:"icon_female.png")
        // 이름
        cell.lb_name.text = rowData.userName
        // 생년월일
        cell.lb_birth.text = rowData.userBirth
        // 거리
        cell.lb_distance.text = rowData.distance
        
        // 태그 관련 처리
        if !rowData.tag.isEmpty && rowData.tag != "" {
            let tags = rowData.tag.split(separator: "|")
            var tagStr:String = ""
            for tag in tags {
                tagStr.append("#\(tag)")
            }
            cell.lb_tag.text = tagStr
        } else {
          cell.lb_tag.text = ""
        }
        
        return cell
    }
}

extension TalentShareViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sharingTableView.deselectRow(at: indexPath, animated: true)
        let rowData:TalentListData = datas[indexPath.row]
        selectedUserID = rowData.userID
        selectedTalentID = rowData.talentID
        selectedTalentFlag = self.talentFlag
        self.performSegue(withIdentifier: "segueProfile", sender: nil)
    }
}

class TalentListData {
    
    var profileImageUri:String
    var userName:String
    var userBirth: String
    var userGender: String
    var distance: String
    var tag: String
    var talentID: String
    var userID: String
    
    init(){
        profileImageUri = "pic_profile.jpg"
        userName = ""
        userBirth = ""
        userGender = "비공개"
        distance = "위치정보 없음"
        tag = ""
        talentID = "0"
        userID = ""
    }
    
    init(profileImageUri:String, userName:String, userBirth:String, userGender:String, distance:String, tag:String, talentID:String, userID:String) {
        self.profileImageUri = profileImageUri
        self.userName = userName
        self.userBirth = userBirth
        self.userGender = userGender
        self.distance = distance
        self.tag = tag
        self.talentID = talentID
        self.userID = userID
    }
    
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async {
            [weak self] in
            if let data = try? Data(contentsOf:url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
