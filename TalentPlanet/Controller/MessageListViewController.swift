//
//  MessageListViewController.swift
//  TalentPlanet
//
//  Created by 민권홍 on 27/11/2019.
//  Copyright © 2019 민권홍. All rights reserved.
//

import UIKit

class MessageListViewController: UIViewController {

    // MARK: - Variables
    var datas:[MessengerData]!
    let dbName = "/accepted.db"
    var databasesPath: String!
    var filemgr: FileManager!
    
    var selectedRoomID: String?
    var selectedReceiverID: String?
    var selectedUserName: String?
    var nowDate: String!
    @IBOutlet var messengerListView: UITableView!
    var isClaim: Bool = false
    var didSelectClaimUser: ((_ tarUserID: String, _ tarUserName: String, _ sFilePath: String) -> Void)?
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        filemgr = FileManager.default
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        let docsDir = dirPaths[0] as String
        
        databasesPath = docsDir.appending(dbName)
        
        messengerListView.delegate = self
        messengerListView.dataSource = self
        
        // 현재 시간 구하기
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        nowDate = dateFormatter.string(from: today)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "segueChat":
            let messengerViewController = segue.destination as! MessengerViewController
            messengerViewController.roomID = self.selectedRoomID!
            messengerViewController.receiverID = self.selectedReceiverID!
            messengerViewController.userName = self.selectedUserName!
            break;
        default:
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getMessengerList()
    }
    
    // MARK: - Functions
    func getMessengerList(){
        let acceptedDB = FMDatabase(path: databasesPath)
        datas = []
        if acceptedDB.open() {
            let sql = """
                        SELECT D01.ROOM_ID,
                               D01.USER_NAME,
                               IFNULL(D03.UNREADED_COUNT, 0) as UNREADED_COUNT,
                               IFNULL(D06.CONTENT, '') as CONTENT,
                               IFNULL(D06.CREATION_DATE, D01.CREATION_DATE) as CREATION_DATE,
                               D01.USER_ID,
                               D01.START_MESSAGE_ID,
                               D01.FILE_PATH
                        FROM   TB_CHAT_ROOM D01
                        LEFT OUTER JOIN (SELECT D02.ROOM_ID,
                                                COUNT(D02.ROOM_ID) AS UNREADED_COUNT
                                         FROM   TB_CHAT_LOG D02
                                         WHERE  D02.READED_FLAG = 'N'
                                         GROUP BY D02.ROOM_ID) D03 ON D01.ROOM_ID = D03.ROOM_ID
                        LEFT OUTER JOIN (SELECT D04.ROOM_ID,
                                                D04.CONTENT,
                                                D04.CREATION_DATE
                                         FROM   TB_CHAT_LOG D04
                                         WHERE  D04.MESSAGE_ID IN (SELECT MAX(D05.MESSAGE_ID)
                                                                   FROM   TB_CHAT_LOG D05
                                                                   GROUP BY D05.ROOM_ID)) D06 ON D01.ROOM_ID = D06.ROOM_ID
                        WHERE  D01.ACTIVATE_FLAG = 'Y'
                        AND    D01.MASTER_ID = '\(UserDefaults.standard.string(forKey: "userID")!)'
                        ORDER BY D06.CREATION_DATE ASC
                      """

            let result = acceptedDB.executeQuery(sql, withArgumentsIn: [])
            if result == nil {
                print("Error : \(acceptedDB.lastErrorMessage())")
            } else {
                while (result!.next()) {
                    datas.append(MessengerData(userID: (result?.string(forColumn: "USER_ID"))!, userName: (result?.string(forColumn: "USER_NAME"))!, content: (result?.string(forColumn: "CONTENT"))!, sendDate: (result?.string(forColumn: "CREATION_DATE"))!, profileImageUri: (result?.string(forColumn: "FILE_PATH"))!, roomID: (result?.string(forColumn: "ROOM_ID"))!))
                }
                
                messengerListView.reloadData()
            }

        }
        
    }
}

extension MessageListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    // 행 정보 표시
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 행 가져오기
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessengerListCell", for: indexPath) as! MessengerListCell
        
        // 프사 동그랗게 만들기
        cell.ivUser.layer.cornerRadius = cell.ivUser.frame.size.height / 2
        cell.ivUser.layer.masksToBounds = true
        cell.ivUser.layer.borderWidth = 0
        
        // 서버에서 가져온 데이터 하나씩 꺼내기
        let rowData:MessengerData = datas[indexPath.row]
        
        // 프사 있는지 없는지 확인
        if rowData.profileImageUri == "NODATA" {
            cell.ivUser.image = UIImage(named:"pic_profile.jpg")
        }
        else {
            let url = URL(string: "http://13.209.191.97/Accepted/" + rowData.profileImageUri)
            cell.ivUser.load(url: url!)
        }
        
        cell.lbContent.text = rowData.content
        let splitDate = rowData.sendDate.components(separatedBy: ",")
        
        if splitDate[0] == nowDate {
            if splitDate.count > 2 {
                let timeIndex = splitDate[1].index(splitDate[1].endIndex, offsetBy: -3)
                let time = String(splitDate[1][..<timeIndex])
                cell.lbDate.text = time
            } else {
                cell.lbDate.text = ""
            }
        } else {
            cell.lbDate.text = splitDate[0]
        }
        
        cell.lbName.text = rowData.userName
        
        return cell
    }
}

extension MessageListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        messengerListView.deselectRow(at: indexPath, animated: true)
        let rowData:MessengerData = datas[indexPath.row]
        if isClaim {
            self.didSelectClaimUser!(rowData.userID, rowData.userName, rowData.profileImageUri)
            self.dismiss(animated: true, completion: nil)
        } else {
            selectedRoomID = rowData.roomID
            selectedReceiverID = rowData.userID
            selectedUserName = rowData.userName
            
            self.performSegue(withIdentifier: "segueChat", sender: nil)
        }
    }
}

class MessengerData {
    var userID:String
    var userName:String
    var content:String
    var sendDate:String
    var profileImageUri:String
    var roomID:String
    
    init(userID: String, userName: String, content: String, sendDate: String, profileImageUri: String, roomID: String) {
        self.userID = userID
        self.userName = userName
        self.content = content
        self.sendDate = sendDate
        self.profileImageUri = profileImageUri
        self.roomID = roomID
    }
}
