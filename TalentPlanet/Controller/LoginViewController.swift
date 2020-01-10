//
//  LoginViewController.swift
//  TalentPlanet
//
//  Created by 민권홍 on 24/09/2019.
//  Copyright © 2019 민권홍. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {
    

    // MARK: - Variables
    let gradientLayer = CAGradientLayer()
    
    @IBOutlet var mainView: UIView!
    @IBOutlet var btnJoinUs: UIButton!
    @IBOutlet var btnLogin: UIButton!
    @IBOutlet var tfID: UITextField!
    @IBOutlet var tfPW: UITextField!
    
    var talentFlag = "Y"
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //mainView.backgroundColor = UIColor(red: 77.0/255.0, green: 88.0/255.0, blue: 104.0/255.0, alpha: 1)
        
        btnJoinUs.backgroundColor = UIColor.white
        tfID.text = "mkh9012@naver.co"
        tfPW.text = "rnjsghd"
    }
    
    // MARK: - Init
    override func viewDidAppear(_ animated: Bool) {
        // 로그인 정보 있을 시 자동 로그인
        if UserDefaults.standard.string(forKey: "userID") != nil {
            performSegue(withIdentifier: "segueLogin", sender: nil)
        }
        
        // 버튼 그라데이션
        btnLogin.backgroundColor = UIColor.green

        gradientLayer.frame = btnLogin.bounds

        let middleColor = UIColor(red: 255.0/255.0, green: 149.0/255.0, blue: 98.0/255.0, alpha: 1.0).cgColor
        let startColor = UIColor(red: 255.0/255.0, green: 102.0/255.0, blue: 102.0/255.0, alpha: 1.0).cgColor
        let endColor = UIColor(red: 255.0/255.0, green: 195.0/255.0, blue: 94.0/255.0, alpha: 1.0).cgColor
        gradientLayer.colors = [startColor, middleColor, endColor]

        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.cornerRadius = 5;

        btnLogin.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
          self.view.endEditing(true)
    }
    
    // MARK: - Functions
    @IBAction func btnLogin(_ sender: Any) {
       // self.performSegue(withIdentifier: "segueLogin", sender:self)
        // 아이디 확인
        let userID = tfID.text!
        if userID.count < 1 {
            let message = "아이디를 정확히 입력해주세요."

            let alert = UIAlertController(title: "아이디 확인", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            return
        } else if (!validateEmail(candidate: userID)) {
            let message = "아이디는 이메일 형식으로 입력해주세요."
            let alert = UIAlertController(title: "아이디 확인", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            present(alert, animated: true, completion: nil)
            return
        }
        
        // 비밀번호 확인
        let userPW = tfPW.text!
        if userPW.count < 1 {
            let message = "비밀번호를 정확히 입력해주세요."

            let alert = UIAlertController(title: "비밀번호 확인", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        AF.request("http://175.213.4.39/Accepted/Login/checkLoginInfo.do", method: .post, parameters:["userID":userID, "userPW":userPW])
            .validate()
            .responseJSON {
                response in
                var message:String
                switch response.result {
                case .success(let value):
                    if let JSON = value as? [String: Any] {
                        if JSON["result"] as! String == "success" {
                            print("로그인 성공")
                            UserDefaults.standard.set(userID, forKey: "userID")
                            self.performSegue(withIdentifier: "segueLogin", sender: nil)
                            self.saveFcmToken(token: UserDefaults.standard.string(forKey: "fcmToken")!)
                        } else {
                            message = "아이디/패스워드를 확인해주세요."
                            print(JSON)
                            let alert = UIAlertController(title: "로그인 실패", message: message, preferredStyle: UIAlertController.Style.alert)
                            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                            alert.addAction(alertAction)
                            self.present(alert, animated: true, completion: nil)
                        }
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
    
    // 이메일 확인 정규식
    func validateEmail(candidate: String) -> Bool {
        let regex = "^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*.[a-zA-Z]{2,3}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: candidate)
    }
    
    // 토큰 저장
    func saveFcmToken(token: String){
        AF.request("http://175.213.4.39/Accepted/Login/saveFCMToken.do", method: .post, parameters:["userID":UserDefaults.standard.string(forKey: "userID")!, "fcmToken":token, "deviceType":"iOS"])
            .validate()
            .responseJSON {
                response in
                switch response.result {
                case .success(let value):
                    print("토큰 저장 성공")
                    
                case .failure(let error):
                    print("Error in network \(error)")
                }
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//    }
    

}
