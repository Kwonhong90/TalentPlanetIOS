//
//  NoticeListViewController.swift
//  TalentPlanet
//
//  Created by 민권홍 on 13/01/2020.
//  Copyright © 2020 민권홍. All rights reserved.
//

import UIKit
import Alamofire

class NoticeListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Variables
    @IBOutlet var noticeTableView: UITableView!
    var datas: [NoticeData] = []
    var selectedIndex: Int!
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noticeTableView.delegate = self
        self.noticeTableView.dataSource = self
        getNoticeList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "segueNoticeView":
            let noticeViewController = segue.destination as! NoticeViewController
            let rowData = self.datas[selectedIndex]
            noticeViewController.noticeTitle = rowData.title
            noticeViewController.noticeContent = rowData.content
            noticeViewController.noticeDate = rowData.date
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeListCell", for: indexPath) as! NoticeListCell
        
        cell.lbTitle.text = datas[indexPath.row].title

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        self.performSegue(withIdentifier: "segueNoticeView", sender: nil)
    }

    // MARK: - Functions
    func getNoticeList() {
        AF.request("http://175.213.4.39/Accepted/Customer/getNoticeList.do", method: .post)
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
                            
                            self.datas.append(NoticeData(title: json["NOTICE_TITLE"] as! String, content: json["NOTICE_SUMMARY"] as! String, date: dateFormatter.string(from: date)))
                            print(json["NOTICE_TITLE"] as! String)
                            print(json["NOTICE_SUMMARY"] as! String)
                            print(dateFormatter.string(from: date))
                        }
                        
                        self.noticeTableView.reloadData()
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

class NoticeData {
    var title: String
    var content: String
    var date: String
    
    init(title: String, content: String, date: String) {
        self.title = title
        self.content = content
        self.date = date
    }
}
