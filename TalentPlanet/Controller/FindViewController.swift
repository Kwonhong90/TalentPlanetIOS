//
//  FindViewController.swift
//  TalentPlanet
//
//  Created by 민권홍 on 24/09/2019.
//  Copyright © 2019 민권홍. All rights reserved.
//

import UIKit
import Alamofire

class FindViewController: UIViewController, UITextFieldDelegate {
    // MARK: - Variables
    var activeField: UITextField!
    @IBOutlet var tfPhoneID: UITextField!
    @IBOutlet var tfCertID: UITextField!
    @IBOutlet var tfIDPW: UITextField!
    @IBOutlet var tfPhonePW: UITextField!
    @IBOutlet var tfCertPW: UITextField!
    
    var certNumID: String?
    var certNumPW: String?
    var memInfo: [String:Any]?
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tfIDPW.delegate = self
        self.tfPhonePW.delegate = self
        self.tfCertPW.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
          self.view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    func textFieldDidBeginEditing(_ textField: UITextField){
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.frame.origin.y = -210
        })
    }

    func textFieldDidEndEditing(_ textField: UITextField){
        UIView.animate(withDuration: 0.2, animations: {
            self.view.frame.origin.y = 0
        })
        
    }
    
    // MARK: - Functions
    func sendSMS(isFindID: Bool) {
        var sReceiveNum: String
        var params: [String:Any] = [:]
        if isFindID {
            sReceiveNum = self.tfPhoneID.text!
        } else {
            sReceiveNum = self.tfPhonePW.text!
            params["UserID"] = tfIDPW.text!
            
            if tfIDPW.text!.count < 6 || validateEmail(candidate: tfIDPW.text!) {
                let message = "아이디를 확인해주시기 바랍니다."
                let alert = UIAlertController(title: "아이디 형식 확인", message: message, preferredStyle: UIAlertController.Style.alert)
                let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        
        if !validatePhone(candidate: sReceiveNum) {
            let message = "핸드폰 번호 형식을 확인해주시기 바랍니다."
            let alert = UIAlertController(title: "핸드폰 번호 확인", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        params["sRecieveNum"] = sReceiveNum
        AF.request("http://175.213.4.39/Accepted/Member/findSMS.do", method: .post, parameters:params)
            .validate()
            .responseJSON {
                response in
                var message:String
                switch response.result {
                case .success(let value):
                    if let JSON = value as? [String: Any] {
                        let status = JSON["result"] as! String
                        if status == "fail" {
                            let message = "해당 정보로 조회되는 회원정보가 없습니다."
                            let alert = UIAlertController(title: "조회 실패", message: message, preferredStyle: UIAlertController.Style.alert)
                            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                            alert.addAction(alertAction)
                            self.present(alert, animated: true, completion: nil)
                            return
                        }
                        else {
                            self.memInfo = JSON["MemInfo"] as! [String:Any]
                            if isFindID {
                                self.certNumID = String(JSON["certNum"] as! Int)
                            } else {
                                self.certNumPW = String(JSON["certNum"] as! Int)
                            }
                        }
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
    
    // 핸드폰 번호 확인 정규식
    func validatePhone(candidate: String) -> Bool {
        let regex = "^01([0|1|6|7|8|9]?)-?([0-9]{3,4})-?([0-9]{4})$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: candidate)
    }
    
    // 이메일 확인 정규식
    func validateEmail(candidate: String) -> Bool {
        let regex = "^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*.[a-zA-Z]{2,3}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: candidate)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func sendSmsID(_ sender: Any) {
        sendSMS(isFindID: true)
    }
    
    @IBAction func sendSmsPW(_ sender: Any) {
        sendSMS(isFindID: false)
    }
    
    @IBAction func compCertID(_ sender: Any) {
        if certNumID == nil {
            let message = "인증번호를 발급해주세요."
            let alert = UIAlertController(title: "인증번호 발급", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            return
        } else if tfCertID.text!.count < 1 {
            let message = "인증번호를 입력해주세요."
            let alert = UIAlertController(title: "인증번호 미입력", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            return
        } else if tfCertID.text! != certNumID! {
            let message = "인증번호를 다시 확인해주세요."
            let alert = UIAlertController(title: "인증번호 오류", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            return
        } else if tfCertID.text! == certNumID! {
            let message = "회원님의 아이디는 \(self.memInfo!["USER_ID"]!) 입니다."
            let alert = UIAlertController(title: "아이디 안내", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    @IBAction func compCertPW(_ sender: Any) {
        if certNumPW == nil {
            let message = "인증번호를 발급해주세요."
            let alert = UIAlertController(title: "인증번호 발급", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            return
        } else if tfCertPW.text!.count < 1 {
            let message = "인증번호를 입력해주세요."
            let alert = UIAlertController(title: "인증번호 미입력", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            return
        } else if tfCertPW.text! != certNumPW! {
            let message = "인증번호를 다시 확인해주세요."
            let alert = UIAlertController(title: "인증번호 오류", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            return
        } else if tfCertPW.text! == certNumPW! {
            let message = "회원님의 비밀번호는 \(self.memInfo!["PASSWORD"]!) 입니다."
            let alert = UIAlertController(title: "비밀번호 안내", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
}
