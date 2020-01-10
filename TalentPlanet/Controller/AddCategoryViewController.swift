//
//  AddCategoryViewController.swift
//  TalentPlanet
//
//  Created by 민권홍 on 09/01/2020.
//  Copyright © 2020 민권홍. All rights reserved.
//

import UIKit
import Alamofire

class AddCategoryViewController: UIViewController, UITextViewDelegate {

    // MARK: - Variables
    @IBOutlet var btnTeacher: UIButton!
    @IBOutlet var btnStudent: UIButton!
    @IBOutlet var tfCateTitle: UITextField!
    @IBOutlet var tvCateDescription: UITextView!
    
    var isTeacher: Bool = false
    var isStudent: Bool = false
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        tvCateDescription.layer.borderWidth = 1.0
        tvCateDescription.layer.borderColor = UIColor.lightGray.cgColor
        tvCateDescription.layer.cornerRadius = 5.0
        tvCateDescription.delegate = self
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
    @IBAction func clickTeacher(_ sender: UIButton) {
        isTeacher = !isTeacher
        if isTeacher {
            btnTeacher.setImage(UIImage(named: "icon_check1on.png"), for: .normal)
        } else {
            btnTeacher.setImage(UIImage(named: "icon_check1off.png"), for: .normal)
        }
    }
    
    @IBAction func clickStudent(_ sender: UIButton) {
        isStudent = !isStudent
        if isStudent {
            btnStudent.setImage(UIImage(named: "icon_check1on.png"), for: .normal)
        } else {
            btnStudent.setImage(UIImage(named: "icon_check1off.png"), for: .normal)
        }
    }

    @IBAction func addCate(_ sender: UIButton) {
        if !(isTeacher || isStudent) {
            let message = "카테고리 구분을 선택해주세요."
            let alert = UIAlertController(title: "카테고리 구분", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            return
        } else if(tfCateTitle.text == nil || tfCateTitle.text!.count < 1) {
            let message = "카테고리명을 입력해주세요."
            let alert = UIAlertController(title: "카테고리명 없음", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            return
        } else if(tvCateDescription.text == nil || tvCateDescription.text.count < 1) {
            let message = "카테고리 설명을 입력해주세요."
            let alert = UIAlertController(title: "카테고리 설명 없음", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        var talentFlag: String!
        if isTeacher && isStudent {
            talentFlag = "Y|N"
        } else if isTeacher {
            talentFlag = "Y"
        } else {
            talentFlag = "N"
        }
        
        let parameters = ["USER_ID": UserDefaults.standard.string(forKey: "userID")!
                        , "TALENT_FLAG": talentFlag
                        , "CATEGORY_NAME": tfCateTitle.text!
                        , "CATEGORY_CONTENT": tvCateDescription.text!]
        AF.request("http://175.213.4.39/Accepted/Customer/requestNewCategory.do", method: .post, parameters:parameters)
            .validate()
            .responseJSON {
                response in
                var message:String
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        if json["result"] as! String == "success" {
                            print("카테고리 등록 신청 성공")
                            message = "카테고리 신청이 완료되었습니다."
                            let alert = UIAlertController(title: "신청 완료", message: message, preferredStyle: UIAlertController.Style.alert)
                            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: {
                               (action) in
                                self.dismiss(animated: true, completion: nil)
                            })
                            alert.addAction(alertAction)
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            message = "카테고리 신청 실패하였습니다. 관리자에게 문의해주시기 바랍니다."
                            let alert = UIAlertController(title: "신청 실패", message: message, preferredStyle: UIAlertController.Style.alert)
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
