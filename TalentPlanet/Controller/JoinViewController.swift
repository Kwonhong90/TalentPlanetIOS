//
//  JoinViewController.swift
//  TalentPlanet
//
//  Created by 민권홍 on 24/09/2019.
//  Copyright © 2019 민권홍. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class JoinViewController: UIViewController {
    
    // MARK: - Variables
    let gradientLayer = CAGradientLayer()
    
    // 메인 뷰
    @IBOutlet var mainView: UIView!
    
    // 계정정보
    @IBOutlet var tfID: UITextField!
    @IBOutlet var tfPW: UITextField!
    @IBOutlet var tfPWConf: UITextField!
    @IBOutlet var btnCheckID: UIButton!
    var isCheckDup = false
    
    // 본인인증
    @IBOutlet var tfName: UITextField!
    @IBOutlet var tfPhone: UITextField!
    @IBOutlet var tfPhoneCert: UITextField!
    @IBOutlet var btnSendCert: UIButton!
    @IBOutlet var btnCompCert: UIButton!
    var certNum: String?
    var isCheckPhone = true
    
    // 부가정보
    @IBOutlet var tfBirth: UITextField!
    @IBOutlet var sgGender: UISegmentedControl!
    var publicFlag : Bool = false
    
    // 이용약관
    @IBOutlet var lbService: UILabel!
    @IBOutlet var lbPrivacy: UILabel!
    @IBOutlet var ivService: UIImageView!
    @IBOutlet var ivPrivacy: UIImageView!
    var checkService: Bool = false
    var checkPrivacy: Bool = false
    let checkedImage = UIImage(named: "icon_check1on.png")
    let uncheckedImage = UIImage(named: "icon_check1off.png")
    
    // 시작하기 버튼
    @IBOutlet var btnJoin: UIButton!
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()

        // 내비 바 색상 조절
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor(red: 77.0/255.0, green: 88.0/255.0, blue: 104.0/255.0, alpha: 1)
        
        // 이용약관 라벨 클릭 이벤트
        let serviceTap = UITapGestureRecognizer(target: self, action: #selector(JoinViewController.btnCheckService))
        let privacyTap = UITapGestureRecognizer(target: self, action: #selector(JoinViewController.btnCheckPrivacy))
        
        lbService.isUserInteractionEnabled = true
        lbPrivacy.isUserInteractionEnabled = true
        
        lbService.addGestureRecognizer(serviceTap)
        lbPrivacy.addGestureRecognizer(privacyTap)
        
        // 아이디 textfield 변경 감지
        tfID.addTarget(self, action: #selector(JoinViewController.chgIDTextField(_:)), for: UIControl.Event.editingChanged)
        
        // 핸드폰인증 textfield 변경 감지
        tfPhoneCert.addTarget(self, action: #selector(JoinViewController.chgPhoneCertTextField(_:)), for: UIControl.Event.editingChanged)
    }
    
    // 뷰 보여질때
    override func viewDidAppear(_ animated: Bool) {
        
        // 버튼 그라데이션
        gradientLayer.frame = btnJoin.bounds
        
        let middleColor = UIColor(red: 255.0/255.0, green: 149.0/255.0, blue: 98.0/255.0, alpha: 1.0).cgColor
        let startColor = UIColor(red: 255.0/255.0, green: 102.0/255.0, blue: 102.0/255.0, alpha: 1.0).cgColor
        let endColor = UIColor(red: 255.0/255.0, green: 195.0/255.0, blue: 94.0/255.0, alpha: 1.0).cgColor
           gradientLayer.colors = [startColor, middleColor, endColor]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.cornerRadius = 5;

        btnJoin.layer.insertSublayer(gradientLayer, at: 0)

    }
    
    // MARK: - Functions
    // 아이디 중복 확인
    @IBAction func btnCheckID(_ sender: UIButton) {
        
        if let id = tfID.text {
            if id.count < 6 {
                var message:String
                message = "아이디는 6자 이상으로 입력해주세요."
                let alert = UIAlertController(title: "아이디 중복확인", message: message, preferredStyle: UIAlertController.Style.alert)
                let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                alert.addAction(alertAction)
                present(alert, animated: true, completion: nil)
            } else if (!validateEmail(candidate: id)) {
                var message:String
                message = "아이디는 이메일 형식으로 입력해주세요."
                let alert = UIAlertController(title: "아이디 중복확인", message: message, preferredStyle: UIAlertController.Style.alert)
                let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                alert.addAction(alertAction)
                present(alert, animated: true, completion: nil)
            } else {
                AF.request("http://175.213.4.39/Accepted/Regist/checkDupID.do", method: .post, parameters:["userID":id])
                    .validate()
                    .responseJSON {
                        response in
                        var message:String
                        switch response.result {
                        case .success(let value):
                            if let JSON = value as? [String: Any] {
                                let status = JSON["result"] as! String
                                if status == "success" {
                                    message = "사용하실 수 있는 아이디 입니다."
                                    self.isCheckDup = true
                                }
                                else {
                                    message = "이미 사용중인 아이디 입니다."
                                    self.isCheckDup = false
                                }
                                                                
                                let alert = UIAlertController(title: "아이디 중복확인", message: message, preferredStyle: UIAlertController.Style.alert)
                                let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                                alert.addAction(alertAction)
                                self.present(alert, animated: true, completion: nil)
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
        } else {
            var message:String
            message = "아이디를 입력해주세요."
            let alert = UIAlertController(title: "아이디 중복확인", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            present(alert, animated: true, completion: nil)
        }

    }
    
    // 아이디 textfield 값 변경 감지
    @objc func chgIDTextField(_ sender: UITextField){
        isCheckDup = false
    }
    
    // 핸드폰 번호 확인 정규식
    func validatePhone(candidate: String) -> Bool {
        let regex = "^01([0|1|6|7|8|9]?)-?([0-9]{3,4})-?([0-9]{4})$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: candidate)
    }
    
    // 인증번호 전송
    @IBAction func btnSendCert(_ sender: UIButton) {
        let phone = tfPhone.text!
        if (!validatePhone(candidate: phone)){
            var message:String
            message = "핸드폰 번호를 확인해주세요."
            let alert = UIAlertController(title: "인증번호 발송", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            present(alert, animated: true, completion: nil)
        }else{
            AF.request("http://175.213.4.39/Accepted/Member/sendJoinSMS.do", method: .post, parameters:["sRecieveNum":phone])
                .validate()
                .responseJSON {
                    response in
                    var message:String
                    switch response.result {
                    case .success(let value):
                        if let JSON = value as? [String: Any] {
                            self.certNum = String(JSON["certNum"] as! Int)
                            message = "핸드폰에서 인증번호를 확인해주세요."
                            print(JSON)
                            let alert = UIAlertController(title: "인증번호 발송", message: message, preferredStyle: UIAlertController.Style.alert)
                            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                            alert.addAction(alertAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                    case .failure(let error):
                        print("Error in network \(error)")
                        message = "서버 통신에 실패하였습니다. 관리자에게 문의해주시기 바랍니다."
                        let alert = UIAlertController(title: "인증번호 발송", message: message, preferredStyle: UIAlertController.Style.alert)
                        let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                        alert.addAction(alertAction)
                        self.present(alert, animated: true, completion: nil)
                    }
            }
        }
    }
    
    // 인증완료
    @IBAction func btnCompCert(_ sender: UIButton) {
        var message:String!
        if(self.certNum == nil || self.certNum!.isEmpty){
            message = "인증번호를 발급해주세요."
        } else {
            if(self.certNum == tfPhoneCert.text){
                message = "핸드폰 인증이 완료되었습니다."
                isCheckPhone = true
            }else{
                message = "인증번호를 확인해주세요."
                isCheckPhone = false
            }
        }
        
        let alert = UIAlertController(title: "인증번호 확인", message: message, preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // 아이디 textfield 값 변경 감지
    @objc func chgPhoneCertTextField(_ sender: UITextField){
        isCheckPhone = false
    }
    
    // 부가정보 공개여부 스위치
    @IBAction func switchPublicFlag(sender: UISwitch) {
        publicFlag = sender.isOn
    }

    // 서비스 이용약관 전체보기
    @IBAction func btnViewService(_ sender: UIButton) {
    }
    
    // 개인정보 전체보기
    @IBAction func btnViewPrivacy(_ sender: UIButton) {
    }
    
    // 서비스 이용약관 동의
    @objc func btnCheckService(_ sender: UITapGestureRecognizer){
        if (checkService) {
            ivService.image = uncheckedImage
        } else {
            ivService.image = checkedImage
        }
        
        checkService = !checkService
    }
    
    // 개인정보 수집이용 동의
    @objc func btnCheckPrivacy(_ sender: UITapGestureRecognizer){
        if (checkPrivacy) {
            ivPrivacy.image = uncheckedImage
        } else {
            ivPrivacy.image = checkedImage
        }
        
        checkPrivacy = !checkPrivacy
    }
    
    // 생년월일 확인 정규식
    func validateBirth(candidate: String) -> Bool {
        let regex = "^(19[0-9][0-9]|20[0-9]{2})(0[0-9]|1[0-2])(0[1-9]|[1-2][0-9]|3[0-1])$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: candidate)
    }
    
    // 생년월일 확인 정규식
    func validateEmail(candidate: String) -> Bool {
        let regex = "^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*.[a-zA-Z]{2,3}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: candidate)
    }
    
    // 가입하기
    @IBAction func btnJoin(_ sender: UIButton) {
        
        // 아이디 중복 체크 여부
        if !isCheckDup {
            var message:String
            message = "아이디 중복체크를 해주세요."
            let alert = UIAlertController(title: "회원가입", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            
        // 비밀번호 확인 (함수 내에서 Alert)
        } else if !validatePW(password: tfPW.text!, passwordConf: tfPWConf.text!) {
            
        // 이름 확인
        } else if tfName.text!.isEmpty {
            var message:String
            message = "이름을 입력해주세요."
            let alert = UIAlertController(title: "회원가입", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            
        // 핸드폰 인증 확인
        } else if !isCheckPhone {
            var message:String
            message = "핸드폰 인증을 해주세요."
            let alert = UIAlertController(title: "회원가입", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            
        // 생년월일 형식 확인
        } else if validateBirth(candidate: tfBirth.text!) {
            var message:String
            message = "생년월일을 확인해주세요."
            let alert = UIAlertController(title: "회원가입", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            
        // 서비스 이용약관 동의 확인
        } else if checkService {
            var message:String
            message = "서비스 이용약관에 동의해주세요."
            let alert = UIAlertController(title: "회원가입", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            
        // 개인정보 수집이용동의 확인
        } else if checkPrivacy {
            var message:String
            message = "개인정보 수집이용에 동의해주세요."
            let alert = UIAlertController(title: "회원가입", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            
        // 회원가입
        } else {
            let parameters = ["userID":tfID.text!
                            , "userPW":tfPW.text!
                            , "userName":tfName.text!
                            , "userGender":sgGender.selectedSegmentIndex == 0 ? "남자" : "여자"
                            , "userBirth":tfBirth.text!
                            , "phone":tfPhone.text!
                            , "genderFlag": publicFlag ? "Y" : "N"
                            , "userBirth": publicFlag ? "Y" : "N"]
            AF.request("http://175.213.4.39/Accepted/Regist/goRegist.do", method: .post, parameters:parameters)
                .validate()
                .responseJSON {
                    response in
                    var message:String
                    switch response.result {
                    case .success(let value):
                        if let JSON = value as? [String: Any] {
                            let status = JSON["result"] as! String
                            if status == "success" {
                                message = "회원가읿이 완료되었습니다."
                            }
                            else {
                                message = "회원가입이 실패하였습니다. 관리자에게 문의하여 주시기 바랍니다."
                            }
                                                            
                            let alert = UIAlertController(title: "회원가입", message: message, preferredStyle: UIAlertController.Style.alert)
                            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                            alert.addAction(alertAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                    case .failure(let error):
                        print("Error in network \(error)")
                        message = "서버 통신에 실패하였습니다. 관리자에게 문의해주시기 바랍니다."
                        let alert = UIAlertController(title: "회원가입", message: message, preferredStyle: UIAlertController.Style.alert)
                        let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                        alert.addAction(alertAction)
                        self.present(alert, animated: true, completion: nil)
                    }
            }
        }
    }
    
    // 비밀번호 확인
    func validatePW(password: String, passwordConf: String) -> Bool {
        
        // 비밀번호 길이
        if password.count < 6 || password.count > 13{
            var message: String
            message = "비밀번호는 6자 이상 12자 이하로 입력해주세요."
            let alert = UIAlertController(title: "회원가입", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            return false
            
        // 비밀번호 확인이랑 일치 여부
        } else if password != passwordConf {
            var message: String
            message = "비밀번호와 비밀번호 확인이 일치하지 않습니다."
            let alert = UIAlertController(title: "회원가입", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            return false
            
        // 영문, 숫자, 특수 문자 중 2개 이상 혼합 여부
        } else {
            var charCount = 0;
            
            let pattern1 = "^[0-9]"
            let pattern2 = "^[a-Z]"
            let pattern3 = "^[!@#$%^&*()?_~]"
            
            let regex1 = try! NSRegularExpression(pattern: pattern1, options: [])
            let regex2 = try! NSRegularExpression(pattern: pattern2, options: [])
            let regex3 = try! NSRegularExpression(pattern: pattern3, options: [])
            
            let passwordRange = NSRange(location: 0, length: password.count)
            
            let n1 = regex1.rangeOfFirstMatch(in: password, options: [], range: passwordRange)
            if n1.location != NSNotFound {
                charCount = charCount + 1
            }
            
            let n2 = regex2.rangeOfFirstMatch(in: password, options: [], range: passwordRange)
            if n2.location != NSNotFound {
                charCount = charCount + 1
            }
            
            let n3 = regex3.rangeOfFirstMatch(in: password, options: [], range: passwordRange)
            if n3.location != NSNotFound {
                charCount = charCount + 1
            }
            
            if(charCount < 2){
                var message: String
                message = "비밀번호는 영문, 숫자, 특수문자 중 2가지 이상을 혼합해주세요."
                let alert = UIAlertController(title: "회원가입", message: message, preferredStyle: UIAlertController.Style.alert)
                let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
                return false
            } else {
                return true
            }
        }
    }
}
