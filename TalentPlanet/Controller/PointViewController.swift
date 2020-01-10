//
//  PointViewController.swift
//  TalentPlanet
//
//  Created by 민권홍 on 06/01/2020.
//  Copyright © 2020 민권홍. All rights reserved.
//

import UIKit
import Alamofire

class PointViewController: UIViewController {
    // MARK: -Variable
    // 공통
    var mentorID: String?
    var menteeID: String?
    var isMentor: Bool?
    // 메세지에서 받아오는 변수
    var messageID: Int?
    // 프로필에서 받아오는 변수
    var userName: String?
    var sFilePath: String?
    
    var score: Int!
    
    @IBOutlet var lbTitleTop: UILabel!
    @IBOutlet var lbTitleBottom: UILabel!
    @IBOutlet var ivUser: UIImageView!
    @IBOutlet var ivTalent: UIImageView!
    @IBOutlet var lbName: UILabel!
    @IBOutlet var ivGender: UIImageView!
    @IBOutlet var lbBirth: UILabel!
    @IBOutlet var sdScore: UISlider!
    @IBOutlet var buttonView: UIView!
    @IBOutlet var backView: UIView!
    @IBOutlet var lbButtonTitle: UILabel!
    
    let dbName = "/accepted.db"
    var databasesPath: String!
    var filemgr: FileManager!
    
    // MARK: -Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        score = 0
        // DB 설정
        filemgr = FileManager.default
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        let docsDir = dirPaths[0] as String
        
        databasesPath = docsDir.appending(dbName)
        
        // 프사 동그랗게
        self.ivUser.layer.cornerRadius = self.ivUser.frame.size.height / 2
        self.ivUser.layer.masksToBounds = true
        self.ivUser.layer.borderWidth = 0
        
        // 멘토 멘티 나누기
        if isMentor! {
            self.backView.backgroundColor = UIColor(red: 40.0/255.0, green: 54.0/255.0, blue: 74.0/255.0, alpha: 1.0)
            getUserInfo(userID: menteeID!)
            self.ivTalent.image = UIImage(named: "icon_mentee.png")
            self.ivTalent.image = self.ivTalent.image?.withTintColor(.white)
            self.lbTitleTop.text = "Student에게 포인트를 받습니다."
            self.lbButtonTitle.text = "포인트 받기"
        } else {
            self.backView.backgroundColor = UIColor(red: 255.0/255.0, green: 195.0/255.0, blue: 94.0/255.0, alpha: 1.0)
            getUserInfo(userID: mentorID!)
            self.ivTalent.image = UIImage(named: "icon_mentor.png")
            self.ivTalent.image = self.ivTalent.image?.withTintColor(.black)
            self.lbTitleTop.text = "Teacher에게 포인트를 보냅니다."
            self.lbButtonTitle.text = "포인트 보내기"
        }
        
        // slider 설정
        sdScore.maximumValue = 10
        sdScore.minimumValue = 0
        sdScore.value = 10
        sdScore.addTarget(self, action: #selector(roundValue(_:)), for: .valueChanged)
        
        // button 설정
        let pointButtonGesture = UITapGestureRecognizer(target: self, action: #selector(sendPoint(_:)))
        self.buttonView.isUserInteractionEnabled = true
        self.buttonView.addGestureRecognizer(pointButtonGesture)
    }
    
    // MARK: -Functions
    func getUserInfo(userID: String) {
        AF.request("http://175.213.4.39/Accepted/Profile/getMyProfileInfo_new.do", method: .post, parameters:["userID":userID])
            .validate()
            .responseJSON {
                response in
                var message:String
                switch response.result {
                case .success(let value):
                    let data = value as! [String:Any]
                    self.lbName.text = data["USER_NAME"] as! String
                    
                    if data["BIRTH_FLAG"] as! String == "Y" {
                        self.lbBirth.text = data["USER_BIRTH"] as! String
                    } else {
                        self.lbBirth.text = "비공개"
                    }
                    
                    if data["GENDER_FLAG"] as! String == "Y" {
                        self.ivGender.image = UIImage(named: "icon_male.png")
                    } else {
                        if data["GENDER"] as! String == "남" {
                            self.ivGender.image = UIImage(named: "icon_male.png")
                            
                        } else {
                            self.ivGender.image = UIImage(named: "icon_female.png")
                        }
                    }
                    
                    if self.isMentor! {
                        self.ivGender.image = self.ivGender.image?.withTintColor(.white)
                    } else {
                        self.ivGender.image = self.ivGender.image?.withTintColor(.black)
                    }
                    self.sFilePath = data["S_FILE_PATH"] as! String
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
    
    // MARK: -Functions
    @objc func sendPoint(_ sender: UITapGestureRecognizer) {
        self.score = Int(sdScore!.value)
        var params: [String:Any] = [:]
        params["MentorID"] = mentorID!
        params["MenteeID"] = menteeID!
        params["isMentor"] = isMentor! ? "Y" : "N"
        params["user"] = UserDefaults.standard.string(forKey: "userID")
        params["Score"] = score
        
        AF.request("http://175.213.4.39/Accepted/TalentSharing/newSendInterest.do", method: .post, parameters:params)
            .validate()
            .responseJSON {
                response in
                var message:String
                switch response.result {
                case .success(let value):
                    let json = value as! [String:Any]
                    if json["result"] as! String == "success" {
                        if self.isMentor! {
                            let updateSql = """
                                                UPDATE TB_CHAT_LOG SET POINT_SEND_FLAG = '1' WHERE MESSAGE_ID = \(self.messageID!)
                                            """
                            
                            print(updateSql)
                            let acceptedDB = FMDatabase(path: self.databasesPath)
                            
                            if acceptedDB.open() {
                                let result = acceptedDB.executeUpdate(updateSql, withArgumentsIn: [])
                                
                                if result {
                                    let message = "포인트를 수령하였습니다."
                                    let alert = UIAlertController(title: "포인트 받기", message: message, preferredStyle: UIAlertController.Style.alert)
                                    let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler:   {(action) -> Void in
                                        self.dismiss(animated: true, completion: nil)
                                    })
                                    alert.addAction(alertAction)
                                    self.present(alert, animated: true, completion: nil)
                                } else {
                                    print("ERROR : INSERT MESSAGE")
                                }
                            }
                        } else {
                            let today = Date()
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy/MM/dd,a hh:mm:ss"
                            let nowDate = dateFormatter.string(from: today)
                            
                            let roomID = CommonFunctions().makeChatRoom(userID: self.mentorID!, userName: self.userName!, filePath: self.sFilePath!)
                            self.messageID = json["MESSAGE_ID"] as? Int
                            let insertSql = """
                                                INSERT INTO TB_CHAT_LOG(MESSAGE_ID, ROOM_ID, MASTER_ID, USER_ID, CONTENT, CREATION_DATE, POINT_MSG_FLAG)
                                                VALUES (\(self.messageID!), \(roomID), '\(UserDefaults.standard.string(forKey: "userID")!)', '\(UserDefaults.standard.string(forKey: "userID")!)', '포인트 전송', '\(nowDate)', '1')
                                            """
                            
                            print(insertSql)
                            let acceptedDB = FMDatabase(path: self.databasesPath)
                            
                            if acceptedDB.open() {
                                let result = acceptedDB.executeUpdate(insertSql, withArgumentsIn: [])

                                if result {
                                    let message = "포인트 전송이 완료되었습니다."
                                    let alert = UIAlertController(title: "포인트 전송", message: message, preferredStyle: UIAlertController.Style.alert)
                                    let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler:   {(action) -> Void in
                                        self.dismiss(animated: true, completion: nil)
                                    })
                                    alert.addAction(alertAction)
                                    self.present(alert, animated: true, completion: nil)
                                } else {
                                    print("ERROR : INSERT MESSAGE")
                                }
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
    
    @objc func roundValue(_ sender: UISlider) {
        sender.value = round(sender.value)
    }
}
