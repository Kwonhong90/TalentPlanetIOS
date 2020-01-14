//
//  ClaimListViewController.swift
//  TalentPlanet
//
//  Created by 민권홍 on 13/01/2020.
//  Copyright © 2020 민권홍. All rights reserved.
//

import UIKit
import Alamofire

class ClaimListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Variables
    @IBOutlet var claimListView: UITableView!
    var datas: [ClaimData] = []
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()

        claimListView.delegate = self
        claimListView.dataSource = self
        getClaimList()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClaimListCell", for: indexPath) as! ClaimListCell
        let rowData = datas[indexPath.row]
        
        cell.lbTitle.text = rowData.title
        cell.lbRegDate.text = "등록일시: \(rowData.regDate)"
        cell.lbStatus.text = (rowData.status == "Y") ? "완료" : "조치 중"
        
        var type: String!
        switch rowData.type {
        case "1":
            type = "금품 요구"
            break
        case "2":
            type = "폭언 및 욕설"
            break
        case "3":
            type = "No-Show"
            break
        case "4":
            type = "허위 광고"
            break
        default:
            type = "기타"
        }
        
        cell.lbClaimUser.text = rowData.user
        cell.lbClaimType.text = type
        cell.lbClaimDate.text = rowData.claimDate
        cell.lbClaimContent.text = rowData.content
        
        cell.lbBottomComment.text = rowData.answer
        
        cell.detailView.isHidden = rowData.isDetailHidden
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClaimListCell", for: indexPath) as! ClaimListCell
        let rowData = datas[indexPath.row]
        
        rowData.isDetailHidden = !rowData.isDetailHidden
        datas[indexPath.row] = rowData
        
        cell.detailView.isHidden = rowData.isDetailHidden
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowData = datas[indexPath.row]
        
        if rowData.isDetailHidden {
            return 80
        } else {
            return 220
        }
    }
    
    // MARK: - Functions
    func getClaimList() {
        AF.request("http://175.213.4.39/Accepted/Customer/getClaimList_new.do", method: .post, parameters: ["userID": UserDefaults.standard.string(forKey: "userID")])
            .validate()
            .responseJSON {
                response in
                var message:String
                switch response.result {
                case .success(let value):
                    if let jsonArray = value as? [[String: Any]] {
                        self.datas = []
                        for json in jsonArray {
                            let date = Date(timeIntervalSince1970: Double(json["CREATION_DATE"] as! Int) / 1000)
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            
                            var answer: String!
                            if json["ANSWER_FLAG"] as! String == "Y" {
                                answer = json["ANSWER_SUMMARY"] as! String
                            } else {
                                answer = "해당 신고에 대해 확인 중에 있습니다. 조속히 처리하도록 하겠습니다."
                            }
                            
                            self.datas.append(ClaimData(title: json["CLAIM_SUMMARY"] as! String, regDate: dateFormatter.string(from: date), status: json["ANSWER_FLAG"] as! String, user: json["TARGET_USER_ID"] as! String, type: json["CLAIM_TYPE"] as! String, claimDate: dateFormatter.string(from: date), content: json["CLAIM_SUMMARY"] as! String, answer: answer))
                            
                        }
                        
                        self.claimListView.reloadData()
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

class ClaimData {
    var title: String
    var regDate: String
    var status: String
    var user: String
    var type: String
    var claimDate: String
    var content: String
    var answer: String
    var isDetailHidden: Bool
    
    init(title: String, regDate: String, status: String, user: String, type: String, claimDate: String, content: String, answer: String) {
        self.title = title
        self.regDate = regDate
        self.status = status
        self.user = user
        self.type = type
        self.claimDate = claimDate
        self.content = content
        self.answer = answer
        self.isDetailHidden = true
    }
}
