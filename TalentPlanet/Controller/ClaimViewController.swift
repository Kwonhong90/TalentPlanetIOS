//
//  ClaimViewController.swift
//  TalentPlanet
//
//  Created by 민권홍 on 10/01/2020.
//  Copyright © 2020 민권홍. All rights reserved.
//

import UIKit
import Alamofire

class ClaimViewController: UIViewController, UITextViewDelegate {

    // MARK: - Variables
    @IBOutlet var ivUser: UIImageView!
    @IBOutlet var btnSearch: UIButton!
    @IBOutlet var scClaimType: UISegmentedControl!
    @IBOutlet var tvDescription: UITextView!
    @IBOutlet var btnConfirm: UIButton!
    
    var tUserID: String?
    var isConf: Bool = false
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        tvDescription.layer.borderWidth = 1.0
        tvDescription.layer.borderColor = UIColor.lightGray.cgColor
        tvDescription.layer.cornerRadius = 5.0
        tvDescription.delegate = self
        
        ivUser.layer.cornerRadius = ivUser.frame.size.height / 2
        ivUser.layer.masksToBounds = true
        ivUser.layer.borderWidth = 0

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
    @IBAction func searchTarget(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "MessageListViewController") as? MessageListViewController else {
            return
        }
        vc.didSelectClaimUser = { [weak self](tarUserID, tarUserName, filePath) in
            if let vc = self {
                self?.tUserID = tarUserID
                self?.btnSearch.setTitle(tarUserName, for: .normal)
                if filePath == "NODATA" {
                    self?.ivUser.image = UIImage(named:"pic_profile.jpg")
                }
                else {
                    let url = URL(string: "http://13.209.191.97/Accepted/" + filePath)
                    self?.ivUser.load(url: url!)
                }
            }
        }
        vc.isClaim = true
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func checkConfirm(_ sender: Any) {
        isConf = !isConf
        if isConf {
            btnConfirm.setImage(UIImage(named: "icon_checkbox_selected.png"), for: .normal)
        } else {
            btnConfirm.setImage(UIImage(named: "icon_checkbox_unselected.png"), for: .normal)
        }
    }
    
    @IBAction func requestClaim(_ sender: UIButton) {
        let claimType = scClaimType.selectedSegmentIndex + 1
        if tUserID == nil {
            let message = "신고대상을 선택해주세요."
            let alert = UIAlertController(title: "신고대상 없음", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            return
        } else if(tvDescription.text == nil || tvDescription.text.count < 1) {
            let message = "신고내용을 입력해주세요."
            let alert = UIAlertController(title: "신고내용 없음", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            return
        } else if !isConf {
            let message = "사실 내용 확인을 눌러해주세요."
            let alert = UIAlertController(title: "사실내용 확인", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let parameters = ["tarUserID": tUserID!
                        , "userID": UserDefaults.standard.string(forKey: "userID")!
                        , "claimType": claimType
                        , "claimSummary": tvDescription.text!] as [String:Any]
        AF.request("http://175.213.4.39/Accepted/Customer/requestClaim_new.do", method: .post, parameters:parameters)
            .validate()
            .responseJSON {
                response in
                var message:String
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        if json["result"] as! String == "success" {
                            print("신고완료")
                            message = "신고가 완료되었습니다."
                            let alert = UIAlertController(title: "신고 완료", message: message, preferredStyle: UIAlertController.Style.alert)
                            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: {
                               (action) in
                                self.dismiss(animated: true, completion: nil)
                                self.dismiss(animated: true, completion: nil)
                            })
                            alert.addAction(alertAction)
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            message = "신고하기가 실패하였습니다. 관리자에게 문의해주시기 바랍니다."
                            let alert = UIAlertController(title: "신고 실패", message: message, preferredStyle: UIAlertController.Style.alert)
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
