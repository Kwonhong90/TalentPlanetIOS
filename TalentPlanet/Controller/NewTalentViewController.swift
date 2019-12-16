//
//  NewTalentViewController.swift
//  TalentPlanet
//
//  Created by 민권홍 on 15/11/2019.
//  Copyright © 2019 민권홍. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class NewTalentViewController: UIViewController {

    // MARK: - Variables
    // 기본 변수
    let userID = UserDefaults.standard.string(forKey: "userID")!
    var talentFlag: String!
    var cateCode: Int!
    var talentID: Int!
    var titleText: String!
    
    @IBOutlet var lbTitle: UILabel!
    @IBOutlet var ivAddBackground: UIImageView!
    
    @IBOutlet var ivAdd: UIImageView!
    @IBOutlet var ivUser: UIImageView!
    @IBOutlet var lbName: UILabel!
    @IBOutlet var lbBirth: UILabel!
    @IBOutlet var ivGender: UIImageView!
    @IBOutlet var ivPublicCheck: UIImageView!
    @IBOutlet var lbAddress: UILabel!
    @IBOutlet var lbIntroduction: UILabel!
    @IBOutlet var userInfoView: UIView!
    
    // 맵뷰에 보낼 변수
    var mapViewLat: String = ""
    var mapViewLng: String = ""
    var mapViewAddress: String = ""
    
    // 사진 관련 변수
    let picker = UIImagePickerController()
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserProfileData()
        ivUser.layer.cornerRadius = ivUser.frame.size.height / 2
        ivUser.layer.masksToBounds = true
        ivUser.layer.borderWidth = 0
        
        // 주소 클릭
        let mapGesture = UITapGestureRecognizer(target: self, action: #selector(showMapView(_:)))
        lbAddress.isUserInteractionEnabled = true
        lbAddress.addGestureRecognizer(mapGesture)
        
        // 프로필 사진
        let pictureTapGesture = UITapGestureRecognizer(target: self, action: #selector(getPicture(_:)))
        ivUser.isUserInteractionEnabled = true
        ivUser.addGestureRecognizer(pictureTapGesture)
        
        // 생일 공개 여부
        let birthGesture = UITapGestureRecognizer(target: self, action: #selector(clickPublicFlag(_:)))
        ivPublicCheck.isUserInteractionEnabled = true
        ivPublicCheck.addGestureRecognizer(birthGesture)
        
        // 추가 버튼
        let addGesture = UITapGestureRecognizer(target: self, action: #selector(addDescription(_:)))
        ivAdd.isUserInteractionEnabled = true
        ivAdd.addGestureRecognizer(addGesture)
        
        // 소개글 수정
        let introGesture = UITapGestureRecognizer(target: self, action: #selector(modifyIntro(_:)))
        lbIntroduction.isUserInteractionEnabled = true
        lbIntroduction.addGestureRecognizer(introGesture)
        
        changeTalentFlag(talentFlag: self.talentFlag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "segueMapView":
            let mapViewController = segue.destination as! MapViewController
            mapViewController.selLat = mapViewLat
            mapViewController.selLng = mapViewLng
            mapViewController.addressName = mapViewAddress
        default:
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = titleText
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
                    if json["S_FILE_PATH"] as! String != "NODATA" {
                        let path = json["S_FILE_PATH"] as! String
                        let url = URL(string: "http://13.209.191.97/Accepted/" + path)
                        self.ivUser.load(url: url!)
                    }
                    
                    if json["GENDER"] as! String == "남" {
                        self.ivGender.image = UIImage(named: "icon_male.png")
                    } else {
                        self.ivGender.image = UIImage(named: "icon_female.png")
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

    // 수정 다이얼로그
    @objc func addDescription(_ sender: UITapGestureRecognizer){
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
        AF.request("http://175.213.4.39/Accepted/Hashtag/editUserTalent.do", method: .post, parameters:["UserID":self.userID, "TalentDescription":description, "TalentFlag": self.talentFlag!, "TalentCateCode":self.cateCode!])
            .validate()
            .responseJSON {
                response in
                var message:String
                switch response.result {
                case .success(let value):
                    let talentID = value as! Int
                    if talentID > 0 {
                        print("talent id = \(talentID)")
                        self.talentID = talentID
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
                        }
                        self.navigationController?.popViewController(animated: true)
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
        AF.request("http://175.213.4.39/Accepted/Hashtag/insertHashValue.do", method: .post, parameters:["talentID":self.talentID!, "hashvalues":hashValue])
            .validate()
            .responseJSON {
                response in
                var message:String
                switch response.result {
                case .success(let value):
                    let json = value as! [String:Any]
                    if json["result"] as! String == "success" {
                        
                        print("1q2w3e4r")
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
    
    // 재능 Flag 에 따라 뷰 변경
    func changeTalentFlag(talentFlag: String) {

        if talentFlag == "Y" {
            ivAddBackground.image = UIImage(named: "pic_notalent_teacher.png")
            userInfoView.backgroundColor = UIColor(red: 40.0/255.0, green: 54.0/255.0, blue: 74.0/255.0, alpha: 1.0)
            lbTitle.text = "당신의 재능을 나누어주세요."
        } else {
            ivAddBackground.image = UIImage(named: "pic_notalent_student.png")
            userInfoView.backgroundColor = UIColor(red: 255.0/255.0, green: 195.0/255.0, blue: 94.0/255.0, alpha: 1.0)
            lbTitle.text = "당신의 배움을 응원합니다."
        }
    }
}
