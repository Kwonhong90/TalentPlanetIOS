//
//  QnAViewController.swift
//  TalentPlanet
//
//  Created by 민권홍 on 13/01/2020.
//  Copyright © 2020 민권홍. All rights reserved.
//

import UIKit
import Alamofire

class QnAViewController: UIViewController, UITextViewDelegate {

    // MARK: - Variables
    @IBOutlet var tfTitle: UITextField!
    @IBOutlet var tvContent: UITextView!
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()

        tvContent.layer.borderWidth = 1.0
        tvContent.layer.borderColor = UIColor.lightGray.cgColor
        tvContent.layer.cornerRadius = 5.0
        tvContent.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
          self.view.endEditing(true)
    }

    func textViewShouldReturn(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    

    func textViewDidBeginEditing(_ textView: UITextView){
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.frame.origin.y = -150
        })
    }

    func textViewDidEndEditing(_ textView: UITextView){
        UIView.animate(withDuration: 0.2, animations: {
            self.view.frame.origin.y = 0
        })
        
    }
    
    // MARK: - Functions
    @IBAction func requestQuestion(_ sender: Any) {
        
        if tfTitle.text == nil || tfTitle.text!.count < 1 {
            let message = "문의 제목을 입력해주세요."
            let alert = UIAlertController(title: "문의 제목 없음", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            return
        } else if tvContent.text == nil || tvContent.text.count < 1 {
            let message = "문의 내용을 입력해주세요."
            let alert = UIAlertController(title: "문의 내용 없음", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        let parameters = [
            "userID": UserDefaults.standard.string(forKey: "userID"),
            "questionTitle": tfTitle.text!,
            "questionSummary":tvContent.text!
        ]
        
        AF.request("http://175.213.4.39/Accepted/Customer/requestQuestion.do", method: .post, parameters:parameters)
            .validate()
            .responseJSON {
                response in
                var message:String
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        if json["result"] as! String == "success" {
                            print("신고완료")
                            message = "문의가 완료되었습니다."
                            let alert = UIAlertController(title: "문의 완료", message: message, preferredStyle: UIAlertController.Style.alert)
                            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: {
                               (action) in
                                self.dismiss(animated: true, completion: nil)
                                self.dismiss(animated: true, completion: nil)
                            })
                            alert.addAction(alertAction)
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            message = "문의하기가 실패하였습니다. 관리자에게 문의해주시기 바랍니다."
                            let alert = UIAlertController(title: "문의 실패", message: message, preferredStyle: UIAlertController.Style.alert)
                            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                            alert.addAction(alertAction)
                            self.present(alert, animated: true, completion: nil)
                        }
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
