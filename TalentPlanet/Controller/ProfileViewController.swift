//
//  ProfileViewController.swift
//  TalentPlanet
//
//  Created by 민권홍 on 31/10/2019.
//  Copyright © 2019 민권홍. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import DropDown

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Variables
    // 메인 이미지 뷰
    @IBOutlet var ivProfile: UIImageView!
    @IBOutlet var ivModify: UIImageView!
    @IBOutlet var ivDelete: UIImageView!
    @IBOutlet var ivMessage: UIImageView!
    @IBOutlet var ivMap: UIImageView!
    
    // 재능 관련 변수
    @IBOutlet var lbTag: UILabel!
    @IBOutlet var tvTalentDescription: UITextView!
    
    // 유저 관련 변수
    @IBOutlet var ivUser: UIImageView!
    @IBOutlet var lbName: UILabel!
    @IBOutlet var ivGender: UIImageView!
    @IBOutlet var lbBirth: UILabel!
    @IBOutlet var ivPublicCheck: UIImageView!
    @IBOutlet var lbAddress: UILabel!
    @IBOutlet var lbIntroduction: UILabel!
    @IBOutlet var userInfoView: UIView!
    var filePath: String!
    
    // 재능 프로필 관련 데이터
    var talentProfileList:[TalentData] = []
    
    // 재능 리스트에서 받아올 변수들
    var talentFlag: String = ""
    var userID: String = ""
    var talentID: String = ""
    var cateCode: String = ""
    var titleText: String!
    var chatRoomID: Int?
    // 정보수정 다이얼로그에서 보여줄 텍스트
    var mainDescription: String = ""
    
    // 맵뷰에 보낼 변수
    var mapViewLat: String = ""
    var mapViewLng: String = ""
    var mapViewAddress: String = ""
    
    // 사진 관련 변수
    let picker = UIImagePickerController()
    
    // 드롭다운
    var dropDown: DropDown?
    var dropDownTitles: [String]?
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserProfileData()
        getUserTalentData()
        ivUser.layer.cornerRadius = ivUser.frame.size.height / 2
        ivUser.layer.masksToBounds = true
        ivUser.layer.borderWidth = 0
        
        // 수정 버튼
        let modifyGesture = UITapGestureRecognizer(target: self, action: #selector(modifyDescription(_:)))
        ivModify.isUserInteractionEnabled = true
        ivModify.addGestureRecognizer(modifyGesture)
        
        // 삭제 버튼
        let delGesture = UITapGestureRecognizer(target: self, action: #selector(clickDelTalent(_:)))
        ivDelete.isUserInteractionEnabled = true
        ivDelete.addGestureRecognizer(delGesture)
        
        // 주소 클릭
        let mapGesture = UITapGestureRecognizer(target: self, action: #selector(showMapView(_:)))
        lbAddress.isUserInteractionEnabled = true
        lbAddress.addGestureRecognizer(mapGesture)
        
        // 프로필 사진
        let pictureTapGesture = UITapGestureRecognizer(target: self, action: #selector(getPicture(_:)))
        ivUser.isUserInteractionEnabled = true
        ivUser.addGestureRecognizer(pictureTapGesture)
        
        // 내 프로필인 경우만 변경 가능
        if self.userID == UserDefaults.standard.string(forKey: "userID") {
            // 생일 공개 여부
            let birthGesture = UITapGestureRecognizer(target: self, action: #selector(clickPublicFlag(_:)))
            ivPublicCheck.isUserInteractionEnabled = true
            ivPublicCheck.addGestureRecognizer(birthGesture)
            
            // 소개글 수정
            let introGesture = UITapGestureRecognizer(target: self, action: #selector(modifyIntro(_:)))
            lbIntroduction.isUserInteractionEnabled = true
            lbIntroduction.addGestureRecognizer(introGesture)
        }
        
        // 메신저 클릭
        let messageGesture = UITapGestureRecognizer(target: self, action: #selector(doChat(_:)))
        ivMessage.isUserInteractionEnabled = true
        ivMessage.addGestureRecognizer(messageGesture)
        
        self.navigationController?.navigationBar.topItem?.title = ""
        
        // 프사 관련 Delegate 설정
        picker.delegate = self
        
        // Talent Flag에 따른 View 변경
        if talentFlag == "Y" {
            userInfoView.backgroundColor = UIColor(red: 40.0/255.0, green: 54.0/255.0, blue: 74.0/255.0, alpha: 1.0)
            ivMessage.image = ivMessage.image?.maskWithColor(color: UIColor(red: 255.0/255.0, green: 195.0/255.0, blue: 94.0/255.0, alpha: 1.0))
            ivMap.image = ivMap.image?.maskWithColor(color: UIColor(red: 255.0/255.0, green: 195.0/255.0, blue: 94.0/255.0, alpha: 1.0))
            
            
        } else {
            userInfoView.backgroundColor = UIColor(red: 255.0/255.0, green: 195.0/255.0, blue: 94.0/255.0, alpha: 1.0)
            ivMessage.image = ivMessage.image?.maskWithColor(color: UIColor(red: 40.0/255.0, green: 54.0/255.0, blue: 74.0/255.0, alpha: 1.0))
            ivMap.image = ivMap.image?.maskWithColor(color: UIColor(red: 40.0/255.0, green: 54.0/255.0, blue: 74.0/255.0, alpha: 1.0))
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "segueMapView":
            let mapViewController = segue.destination as! MapViewController
            mapViewController.selLat = mapViewLat
            mapViewController.selLng = mapViewLng
            mapViewController.addressName = mapViewAddress
            mapViewController.userID = self.userID
            break
        case "segueMessenger":
            let messengerViewController = segue.destination as! MessengerViewController
            messengerViewController.receiverID = self.userID
            messengerViewController.roomID = String(self.chatRoomID!)
            messengerViewController.userName = self.lbName.text!
            break
        default:
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.titleText != nil {
            self.initNavigationItemTitleView(title: self.titleText)
        }
    }
    
    // MARK: - Functions
    // 유저 프로필 정보 가져오기
    func getUserProfileData(){
        AF.request("http://175.213.4.39/Accepted/Profile/getMyProfileInfo_new.do", method: .post, parameters:["userID":self.userID])
            .validate()
            .responseJSON {
                response in
                var message:String
                switch response.result {
                case .success(let value):
                    let json = value as! [String:Any]
                    self.lbName.text = json["USER_NAME"] as? String
                    self.filePath = json["S_FILE_PATH"] as? String
                    if json["S_FILE_PATH"] as! String != "NODATA" {
                        let path = json["S_FILE_PATH"] as! String
                        let url = URL(string: "http://13.209.191.97/Accepted/" + path)
                        self.ivUser.load(url: url!)
                    }
                    
                    if self.userID != UserDefaults.standard.string(forKey: "userID") {
                        self.ivModify.isHidden = true
                        self.ivDelete.isHidden = true
                    } else {
                        self.ivMessage.isHidden = true
                    }
                    
                    if json["GENDER"] as! String == "남" {
                        self.ivGender.image = UIImage(named: "icon_male.png")
                    } else {
                        self.ivGender.image = UIImage(named: "icon_female.png")
                    }
                    
                    if self.talentFlag == "Y" {
                        self.ivGender.image = self.ivGender.image?.maskWithColor(color: UIColor(red: 255.0/255.0, green: 195.0/255.0, blue: 94.0/255.0, alpha: 1.0))
                        
                    } else {
                        self.ivGender.image = self.ivGender.image?.maskWithColor(color: UIColor(red: 40.0/255.0, green: 54.0/255.0, blue: 74.0/255.0, alpha: 1.0))
                    }
                    self.lbBirth.text = json["USER_BIRTH"] as? String
                    self.lbIntroduction.text = json["PROFILE_DESCRIPTION"] as? String

                    if let lat = json["GP_LAT"] as? String {
                        
                        let lng = json["GP_LNG"] as! String
                        
                        let userLocation = CLLocation(latitude: Double(lat)!, longitude: Double(lng)!)
                        let geocoder = CLGeocoder()
                        let locale = Locale(identifier: "Ko-kr")
                        
                        self.mapViewLat = lat
                        self.mapViewLng = lng
                        
                        geocoder.reverseGeocodeLocation(userLocation, preferredLocale:locale, completionHandler: {
                            (placemarks, error) in
                            var placeMark: CLPlacemark!
                            placeMark = placemarks![0]
                            var locationName: String = ""
                            
                            if let city = placeMark.administrativeArea {
                                locationName += city
                            }
                            
                            if let locality = placeMark.locality {
                                locationName += " " + locality
                            }
                            
                            if let location = placeMark.name {
                                locationName += " " + location
                            }

                            if !locationName.isEmpty {
                                self.lbAddress.text = locationName
                                self.mapViewAddress = locationName
                            } else {
                                self.lbAddress.text = "위치정보없음"
                                self.mapViewAddress = "위치정보없음"
                            }
                            
                        })
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
    
    // 재능리스트 가져오기
    func getUserTalentData(){
        AF.request("http://175.213.4.39/Accepted/Profile/getAllMyTalent.do", method: .post, parameters:["UserID":self.userID, "CheckUserID":"mkh9012@naver.co", "TalentFlag":self.talentFlag])
            .validate()
            .responseJSON {
                response in
                var message:String
                switch response.result {
                case .success(let value):
                    self.dropDownTitles = []
                    let jsonArray = value as! [[String:Any]]
                    if jsonArray.count == 0 {
                        let alert :UIAlertController = UIAlertController(title: "프로필 없음", message: "등록된 재능이 없습니다. 재능을 등록해주세요.", preferredStyle: UIAlertController.Style.alert)
                        let registAction :UIAlertAction = UIAlertAction(title: "등록하기", style: UIAlertAction.Style.default, handler:
                        {(action: UIAlertAction!) in
                            self.performSegue(withIdentifier: "segueTalentRegist", sender: nil)
                        })
                        let cancelAction = UIAlertAction(title: "취소하기", style: UIAlertAction.Style.default, handler:
                        {(action:UIAlertAction!) in
                            _ = self.navigationController?.popToRootViewController(animated: true)
                        })
                        
                        alert.addAction(registAction)
                        alert.addAction(cancelAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    var index = 0
                    for json in jsonArray {
                        let data = TalentData(userName: json["Name"] as! String, backgroundID: json["BackgroundID"] as! String, iconID: json["IconID"] as! String, talentID: json["TalentID"] as! Int, cateCode: json["Code"] as! Int, userID: json["UserID"] as! String, talentDescription: json["TalentDescription"] as! String, talentFlag: json["TalentFlag"] as! String)
                        
                        self.talentProfileList.append(data)
                        
                        if self.talentID == String(json["TalentID"] as! Int) {
                            let splitText = data.talentDescription.split(separator: " ")
                            var hashStr = ""
                            for text in splitText {
                                if text.first == "#" {
                                    hashStr += text + " "
                                }
                            }
                            
                            self.lbTag.text = hashStr
                            self.tvTalentDescription.text = data.talentDescription
                            self.mainDescription = data.talentDescription
                            self.ivProfile.image = UIImage(named:data.backgroundID + ".png")
                            self.titleText = CommonFunctions().getTalentTitleByCateCode(cateCode: data.cateCode)
                            self.initNavigationItemTitleView(title: self.titleText)
                            
                        } else if index == 0 {
                            let splitText = data.talentDescription.split(separator: " ")
                            var hashStr = ""
                            for text in splitText {
                                if text.first == "#" {
                                    hashStr += text + " "
                                }
                            }
                            
                            self.lbTag.text = hashStr
                            self.tvTalentDescription.text = data.talentDescription
                            self.mainDescription = data.talentDescription
                            self.ivProfile.image = UIImage(named:data.backgroundID + ".png")
                            self.titleText = CommonFunctions().getTalentTitleByCateCode(cateCode: data.cateCode)
                            self.initNavigationItemTitleView(title: self.titleText)
                        }
                        
                        self.dropDownTitles!.append(CommonFunctions().getTalentTitleByCateCode(cateCode: data.cateCode))
                        index = index + 1
                    }


                    self.dropDown = DropDown()
                    self.dropDown?.dataSource = self.dropDownTitles!
                    self.dropDown?.selectionAction = { [unowned self] (index: Int, item: String) in
                        self.talentID = String(self.talentProfileList[index].talentID)
                        self.getUserTalentData()
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
    
    // 타이틀 클릭 시 드롭다운 보여주기
    @objc func dropDownButton(){
        dropDown?.show()
    }
    
    // 타이틀 초기화
    private func initNavigationItemTitleView(title: String) {
        let titleView = UILabel()
        titleView.text = title
        titleView.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
        
        dropDown?.anchorView = titleView // UIView or UIBarButtonItem
        dropDown?.bottomOffset = CGPoint(x: 0, y:(dropDown?.anchorView?.plainView.bounds.height)!)
        // The list of items to display. Can be changed dynamically
        
        self.navigationController?.navigationBar.topItem?.titleView = titleView
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(dropDownButton))
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)
    }
    
    // 수정 다이얼로그
    @objc func modifyDescription(_ sender: UITapGestureRecognizer){
        let dialog = UIAlertController(title: "정보수정", message: "내용을 입력해주세요.\n\n\n\n\n\n\n", preferredStyle: .alert)
        dialog.view.autoresizesSubviews = true
         
        let customView = UITextView(frame: CGRect.zero)
        customView.translatesAutoresizingMaskIntoConstraints = false
        
        let leadConstraint = NSLayoutConstraint(item: dialog.view!, attribute: .leading, relatedBy: .equal, toItem: customView, attribute: .leading, multiplier: 1.0, constant: -8.0)
        let trailConstraint = NSLayoutConstraint(item: dialog.view!, attribute: .trailing, relatedBy: .equal, toItem: customView, attribute: .trailing, multiplier: 1.0, constant: 8.0)
        let topConstraint = NSLayoutConstraint(item: dialog.view!, attribute: .top, relatedBy: .equal, toItem: customView, attribute: .top, multiplier: 1.0, constant: -64.0)
        let bottomConstraint = NSLayoutConstraint(item: dialog.view!, attribute: .bottom, relatedBy: .equal, toItem: customView, attribute: .bottom, multiplier: 1.0, constant: 64.0)
         
        customView.backgroundColor = UIColor.clear
        customView.font = UIFont(name: "Helvetica", size: 15)
        customView.layer.borderColor = UIColor.lightGray.cgColor
        customView.layer.borderWidth = 1.0
        customView.layer.cornerRadius = 5.0
        customView.layer.backgroundColor = UIColor.white.cgColor
        
        customView.text = tvTalentDescription.text
        
        dialog.view.addSubview(customView)
         
        NSLayoutConstraint.activate([leadConstraint, trailConstraint, topConstraint, bottomConstraint])
         
        let compAction = UIAlertAction(title: "완료", style: UIAlertAction.Style.default, handler:  {(action) -> Void in
            let description = customView.text
            self.saveProfileDescription(description: description!)
        })
        
        let cancelAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.default, handler: nil)
        
        dialog.addAction(compAction)
        dialog.addAction(cancelAction)
        
        self.present(dialog, animated: true, completion: nil)
    }
    
    // 소개글 수정
    @objc func modifyIntro(_ sender: UITapGestureRecognizer){
        let dialog = UIAlertController(title: "정보수정", message: "내용을 입력해주세요.\n\n\n\n\n\n\n", preferredStyle: .alert)
        dialog.view.autoresizesSubviews = true
        
        let customView = UITextView(frame: CGRect.zero)
        customView.translatesAutoresizingMaskIntoConstraints = false
        
        let leadConstraint = NSLayoutConstraint(item: dialog.view!, attribute: .leading, relatedBy: .equal, toItem: customView, attribute: .leading, multiplier: 1.0, constant: -8.0)
        let trailConstraint = NSLayoutConstraint(item: dialog.view!, attribute: .trailing, relatedBy: .equal, toItem: customView, attribute: .trailing, multiplier: 1.0, constant: 8.0)
        let topConstraint = NSLayoutConstraint(item: dialog.view!, attribute: .top, relatedBy: .equal, toItem: customView, attribute: .top, multiplier: 1.0, constant: -64.0)
        let bottomConstraint = NSLayoutConstraint(item: dialog.view!, attribute: .bottom, relatedBy: .equal, toItem: customView, attribute: .bottom, multiplier: 1.0, constant: 64.0)
        
        customView.backgroundColor = UIColor.clear
        customView.font = UIFont(name: "Helvetica", size: 15)
        customView.layer.borderColor = UIColor.lightGray.cgColor
        customView.layer.borderWidth = 1.0
        customView.layer.cornerRadius = 5.0
        customView.layer.backgroundColor = UIColor.white.cgColor
        
        customView.text = lbIntroduction.text
        
        dialog.view.addSubview(customView)
        
        NSLayoutConstraint.activate([leadConstraint, trailConstraint, topConstraint, bottomConstraint])
        
        let compAction = UIAlertAction(title: "완료", style: UIAlertAction.Style.default, handler:  {(action) -> Void in
            let description = customView.text
            self.saveProfileIntro(description: description!)
        })
        
        let cancelAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.default, handler: nil)
        
        dialog.addAction(compAction)
        dialog.addAction(cancelAction)
        
        self.present(dialog, animated: true, completion: nil)
    }

    // 지도 뷰 보기
    @objc func showMapView(_ sender: UITapGestureRecognizer){
        self.performSegue(withIdentifier: "segueMapView", sender: nil)
    }
    // 사용자 소개 내용 저장 로직
    func saveProfileIntro(description: String){
        AF.request("http://175.213.4.39/Accepted/Profile/updateMyProfileInfo.do", method: .post, parameters:["UserID":self.userID, "PROFILE_DESCRIPTION":description])
            .validate()
            .responseJSON {
                response in
                var message:String
                switch response.result {
                case .success(let value):
                    let json = value as! [String:Any]
                    if json["result"] as! String == "success" {
                        let regex = try? NSRegularExpression(pattern: "#[a-z0-9]+", options: .caseInsensitive)
                        
                        let textToNS = description as NSString?
                        
                        // text에서 해시태그 배열 뽑기
                        let hashtags = regex?.matches(in: description, options: [], range: NSRange(location: 0, length: textToNS!.length)).map {
                            textToNS?.substring(with: $0.range)
                        }
                        
                        if hashtags!.count > 0 {
                            var hashStr = ""
                            for tag: String in hashtags as! [String] {
                                print(tag)
                                hashStr += tag + " "
                            }
                            
                        }
                    } else {
                        print("저장 실패")
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
    
    // 재능 내용 저장 로직
    func saveProfileDescription(description: String){
        AF.request("http://175.213.4.39/Accepted/Hashtag/editUserTalent.do", method: .post, parameters:["UserID":self.userID, "TalentDescription":description, "TalentFlag": self.talentFlag, "TalentCateCode":self.cateCode])
            .validate()
            .responseJSON {
                response in
                var message:String
                switch response.result {
                case .success(let value):
                    let talentID = value as! Int
                    if talentID > 0 {
                        self.talentID = String(talentID)
                        let regex = try? NSRegularExpression(pattern: "#[a-z0-9]+", options: .caseInsensitive)
                        
                        let textToNS = description as NSString?
                        
                        // text에서 해시태그 배열 뽑기
                        let hashtags = regex?.matches(in: description, options: [], range: NSRange(location: 0, length: textToNS!.length)).map {
                            textToNS?.substring(with: $0.range)
                        }
                        var hashArr = ""
                        if hashtags!.count > 0 {
                            var hashStr = ""
                            for tag: String in hashtags as! [String] {
                                print(tag)
                                hashStr += tag + " "
                                hashArr += tag + "|"
                            }
                            hashArr = String(hashArr[hashArr.startIndex..<hashArr.index(before: hashArr.endIndex)])
                            self.insertHashValue(hashValue: hashArr)
                            
                        } else {
                            self.lbTag.text = ""
                        }
                        self.tvTalentDescription.text = description
                    } else {
                        print("저장 실패")
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
    
    // 해시태그 저장
    func insertHashValue(hashValue: String){
        AF.request("http://175.213.4.39/Accepted/Hashtag/insertHashValue.do", method: .post, parameters:["talentID":self.talentID, "hashvalues":hashValue])
            .validate()
            .responseJSON {
                response in
                var message:String
                switch response.result {
                case .success(let value):
                    let json = value as! [String:Any]
                    if json["result"] as! String == "success" {
                        self.lbTag.text = hashValue.replacingOccurrences(of: "|", with: " ")
                    } else {
                        print("저장 실패")
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
    
    
    // 사진 가져오기
    @objc func getPicture(_ sender:UITapGestureRecognizer){
        let alert = UIAlertController(title: "사진 선택", message: "사진을 가져올 경로를 선택해주세요.", preferredStyle: .actionSheet)
        
        let library = UIAlertAction(title: "사진앨범", style: .default, handler: {
            (action) in
            self.openLibrary()
        })
        
        let camera = UIAlertAction(title: "카메라", style: .default, handler: {
            (action) in
            self.openCamera()
        })
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(library)
        alert.addAction(camera)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    // 사진첩 열기
    func openLibrary() {
        picker.sourceType = .photoLibrary
        present(picker, animated: false, completion: nil)
    }
    
    // 카메라 열기
    func openCamera() {
        if(UIImagePickerController.isSourceTypeAvailable(.camera)) {
            picker.sourceType = .camera
            present(picker, animated: false, completion: nil)
        } else {
         print("Camera is Not Available")
        }
    }

    // 사진 가져오기
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.ivUser.image = image
            let params = ["userID":self.userID, "tags":"UserProfilePicture"]
            
            self.uploadImage(image: image.pngData()!, to: "http://175.213.4.39/Accepted/Profile/savePicture.do", params: params)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // 이미지 서버 업로드
    func uploadImage(image: Data, to urlString: String, params: [String:Any]){
        let url = try! URLRequest.init(url: urlString, method: .post, headers: ["Content-type":"multipart/form-data"])
        AF.upload(multipartFormData: {
            multipartFromData in
            for (key, value) in params {
                if let temp = value as? String {
                    multipartFromData.append(temp.data(using: .utf8)!, withName: key)
                }
                if let temp = value as? Int {
                    multipartFromData.append("\(temp)".data(using: .utf8)!, withName: key)
                }
                if let temp = value as? NSArray {
                    temp.forEach({
                        element in
                        let keyObj = key + "[]"
                        if let string = element as? String {
                            multipartFromData.append(string.data(using: .utf8)!, withName: keyObj)
                        } else {
                            if let num = element as? Int {
                                let value = "\(num)"
                                multipartFromData.append(value.data(using: .utf8)!, withName: keyObj)
                            }
                        }
                    })
                }
            }
            multipartFromData.append(image, withName: "pic", fileName: "file.png", mimeType: "image/png")
        }, with: url)
            .uploadProgress(queue: .main, closure: {
                progress in
                print("Upload Progress: \(progress.fractionCompleted)")
            })
            .responseJSON(completionHandler: {
                response in
                var message:String
                switch response.result {
                case .success(let value):
                    let json = value as! [String:Any]
                    if json["result"] as! String == "success" {
                        print("저장 성공")
                    } else {
                        print("저장 실패")
                    }
                    
                case .failure(let error):
                    print("Error in network \(error)")
                    message = "서버 통신에 실패하였습니다. 관리자에게 문의해주시기 바랍니다."
                    let alert = UIAlertController(title: "아이디 중복확인", message: message, preferredStyle: UIAlertController.Style.alert)
                    let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                    alert.addAction(alertAction)
                    self.present(alert, animated: true, completion: nil)
                }
                
            })
    }
    
    // 삭제 버튼
    @objc func clickDelTalent(_ sender: UITapGestureRecognizer){
        let dialog = UIAlertController(title: "재능 삭제", message: "정말 삭제하시겠습니까?", preferredStyle: .alert)
        
        let compAction = UIAlertAction(title: "삭제", style: UIAlertAction.Style.default, handler:  {(action) -> Void in
            self.delTalent()
        })
        
        let cancelAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.default, handler: nil)
        
        dialog.addAction(compAction)
        dialog.addAction(cancelAction)
        
        self.present(dialog, animated: true, completion: nil)
    }
    
    // 재능 삭제 함수
    func delTalent(){
        AF.request("http://175.213.4.39/Accepted/Hashtag/deleteTalent.do", method: .post, parameters:["UserID":self.userID, "TalentFlag":talentFlag, "TalentCateCode": self.cateCode])
            .validate()
            .responseJSON {
                response in
                var message:String
                switch response.result {
                case .success(let value):
                    let json = value as! [String:Any]
                    if json["result"] as! String == "success" {
                        self.navigationController?.popViewController(animated: true)
                        print("삭제 성공")
                    } else {
                        print("삭제 실패")
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
    
    // 정보 공개 클릭 함수
    @objc func clickPublicFlag(_ sender: UITapGestureRecognizer){
        let dialog = UIAlertController(title: "공개 여부", message: "공개 여부를 변경하시겠습니까?", preferredStyle: .alert)
        
        let compAction = UIAlertAction(title: "삭제", style: UIAlertAction.Style.default, handler:  {(action) -> Void in
            self.chgPublicFlag(birthFlag: "Y")
        })
        
        let cancelAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.default, handler: nil)
        
        dialog.addAction(compAction)
        dialog.addAction(cancelAction)
        
        self.present(dialog, animated: true, completion: nil)
    }
    
    // 정보 공개 함수
    func chgPublicFlag(birthFlag: String){
        AF.request("http://175.213.4.39/Accepted/Hashtag/deleteTalent.do", method: .post, parameters:["userID":self.userID, "birthFlag":birthFlag, "addrFlag": ""])
            .validate()
            .responseJSON {
                response in
                var message:String
                switch response.result {
                case .success(let value):
                    let json = value as! [String:Any]
                    if json["result"] as! String == "success" {
                        print("변경 성공")
                    } else {
                        print("변경 실패")
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
    
    // 메신저 열기
    @objc func doChat(_ sender: UITapGestureRecognizer) {
        let roomID = CommonFunctions().makeChatRoom(userID: self.userID, userName: self.lbName.text!, filePath: self.filePath!)
        print(roomID)
        if roomID < 0 {
            return
        } else {
            self.chatRoomID = roomID
            self.performSegue(withIdentifier: "segueMessenger", sender: nil)
        }
    }
}

// MARK: - Object
// 재능 프로필 데이터 관련 객체
class TalentData {
    var userName :String
    var backgroundID :String
    var iconID :String
    var talentID :Int
    var cateCode :Int
    var userID :String
    var talentDescription :String
    var talentFlag :String
    
    init () {
        userName = ""
        backgroundID = ""
        iconID = ""
        talentID = 0
        cateCode = 0
        userID = ""
        talentDescription = ""
        talentFlag = ""
    }
    
    init(userName :String, backgroundID :String, iconID :String, talentID :Int, cateCode :Int, userID :String, talentDescription :String, talentFlag :String) {
        self.userName = userName
        self.backgroundID = backgroundID
        self.iconID = iconID
        self.talentID = talentID
        self.cateCode = cateCode
        self.userID = userID
        self.talentDescription = talentDescription
        self.talentFlag = talentFlag
    }
}
