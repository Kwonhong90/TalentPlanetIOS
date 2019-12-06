//
//  MessengerController.swift
//  TalentPlanet
//
//  Created by 민권홍 on 28/11/2019.
//  Copyright © 2019 민권홍. All rights reserved.
//

import UIKit

class MessengerViewController: UIViewController {
    // MARK: - Variables
    var datas: [ChatData]!
    @IBOutlet var messengerTableView: UITableView!
    let dbName = "/accepted.db"
    var databasesPath: String!
    var filemgr: FileManager!
    var roomID = ""
    var lastMessageID = 0
    
    var receiverID = ""
    var userName = ""
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        filemgr = FileManager.default
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        let docsDir = dirPaths[0] as String
        
        databasesPath = docsDir.appending(dbName)
        getChatList()
    }
    
    // MARK: - Functions
    func getChatList(){
        if !filemgr.fileExists(atPath: databasesPath) {
            let acceptedDB = FMDatabase(path: databasesPath)
            
            if acceptedDB.open() {
                let sql = """
                            SELECT USER_ID,
                                   CONTENT,
                                   CREATION_DATE,
                                   POINT_MSG_FLAG,
                                   POINST_SEND_FLAG,
                                   MESSAGE_ID
                            FROM   TB_CHAT_LOG
                            WHERE  ROOM_ID = \(roomID)
                            AND    MASTER_ID = '\(UserDefaults.standard.string(forKey: "userID")!)'
                            AND    MESSAGE_ID > \(lastMessageID)
                          """

                let result = acceptedDB.executeQuery(sql, withArgumentsIn: [])
                if result == nil {
                    print("Error : \(acceptedDB.lastErrorMessage())")
                } else {
                    while (result!.next()) {
                        let sender = result?.string(forColumn: "USER_ID")!
                        let content = result?.string(forColumn: "CONTENT")!
                        let creationDate = result?.string(forColumn: "CREATION_DATE")!
                        let messageID = Int((result?.string(forColumn: "MESSAGE_ID"))!)
                        var isPoint: Bool
                        var isCompleted: Bool
                        var isPicture: Bool = true
                        
                        if let temp = Int((result?.string(forColumn: "POINT_MSG_FLAG"))!) {
                            isPoint = temp > 0
                        } else {
                            isPoint = false
                        }
                        
                        if let temp = Int((result?.string(forColumn: "POINST_SEND_FLAG"))!) {
                            isCompleted = temp > 0
                        } else {
                            isCompleted = false
                        }
                        let splitDate = creationDate?.components(separatedBy: ",")
                        let date = splitDate![0]
                        let timeIndex = splitDate![1].index(splitDate![1].startIndex, offsetBy: 8)
                        let time = splitDate![1][..<timeIndex]
                        let picture = UIImage(named: "pic_profile.png")
                        var messageType = 0
                        var isTimeChanged = false
                        var isDateChanged = false
                        
                        var item: ChatData
                        
                        if receiverID == sender {
                            messageType = 2
                            isPicture = true
                        } else {
                            messageType = 1
                            isPicture = false
                        }
                        
                        if datas.count == 0 {
                            isTimeChanged = true
                            isDateChanged = true
                            
                            item = ChatData(messageID: messageID!, picture: picture!, message: content!, date: creationDate!, targetName: userName, targetID: receiverID, messageType: messageType, isTimeChanged: isTimeChanged, isDateChanged: isDateChanged, isPointSend: isPoint, isCompleted: isCompleted, isPicture: isPicture)
                        } else {
                            let prePosition = datas.count - 1
                            let preItem = datas[prePosition]
                            
                            var preDate = preItem.date
                            let splitPreDate = preDate.components(separatedBy: ",")
                            preDate = splitPreDate[0]
                            let preTimeIndex = splitPreDate[1].index(splitPreDate[1].startIndex, offsetBy: 8)
                            let preTime = splitPreDate[1][..<preTimeIndex]
                            
                            if preDate == date {
                                isDateChanged = false
                                if preItem.messageType != messageType {
                                    isTimeChanged = true
                                } else {
                                    if preTime == time {
                                        if messageType == 2 {
                                            isPicture = false;
                                        }
                                        preItem.isTimeChanged = false
                                        datas[prePosition] = preItem
                                    }
                                }
                            } else {
                                isDateChanged = true
                                isTimeChanged = true
                            }
                            item = ChatData(messageID: messageID!, picture: picture!, message: content!, date: creationDate!, targetName: userName, targetID: receiverID, messageType: messageType, isTimeChanged: isTimeChanged, isDateChanged: isDateChanged, isPointSend: isPoint, isCompleted: isCompleted, isPicture: isPicture)
                        }
                        
                        datas.append(item)
                    }
                }

            }
        }
        makeTimeLine()
    }
    
    func makeTimeLine() {
        var idxArr: [Int] = []
        
        for dataIdx in 0..<datas.count {
            let item = datas[dataIdx]
            
            if item.isDateChanged {
                idxArr[idxArr.count] = dataIdx + idxArr.count
            }
        }
        
        for idx in 0..<idxArr.count {
            var temp: [ChatData] = []
            
            for dataIdx in 0..<idxArr[idx]-1 {
                temp[dataIdx] = datas[dataIdx]
            }
            
            for dataIdx in idxArr[idx]..<datas.count {
                temp[dataIdx + 1] = datas[dataIdx]
            }
            
            temp[idxArr[idx]] = ChatData(isDateView: true, date: datas[idxArr[idx]].date)
            datas = temp
        }
    }

}


extension MessengerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    // 행 정보 표시
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 데이터 가져오기
        let rowData:ChatData = datas[indexPath.row]

        if rowData.isDateView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessengerDateCell", for: indexPath) as! MessengerDateCell
            cell.lbDate.text = rowData.date
            
            return cell
        } else {
            if rowData.messageType == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MessengerSendCell", for: indexPath) as! MessengerSendCell
                
                cell.lbContent.text = rowData.message
                
                if rowData.isTimeChanged {
                    cell.lbDate.text = rowData.date
                } else {
                    cell.lbDate.text = ""
                }
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MessengerRecvCell", for: indexPath) as! MessengerRecvCell
                
                // 프사 동그랗게 만들기
                cell.ivUser.layer.cornerRadius = cell.ivUser.frame.size.height / 2
                cell.ivUser.layer.masksToBounds = true
                cell.ivUser.layer.borderWidth = 0
                
                // 프사 있는지 없는지 확인
                cell.ivUser.image = rowData.picture
                cell.lbName.text = rowData.targetName
                
                if rowData.isPicture {
                    cell.ivUser.isHidden = false
                    cell.lbName.isHidden = false
                } else {
                    cell.ivUser.isHidden = true
                    cell.lbName.isHidden = true
                }
                
                cell.lbContent.text = rowData.message
                
                if rowData.isTimeChanged {
                    cell.lbDate.text = rowData.date
                } else {
                    cell.lbDate.text = ""
                }
                
                return cell
            }
        }
    }
}

extension MessengerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        messengerTableView.deselectRow(at: indexPath, animated: true)
//        let rowData:ChatData = datas[indexPath.row]

//        self.performSegue(withIdentifier: "segueProfile", sender: nil)
    }
}

class ChatData {
    var messageID: Int
    var picture: UIImage
    var message: String
    var date: String
    var targetName: String
    var targetID: String
    var messageType: Int
    var isTimeChanged: Bool
    var isDateChanged: Bool
    var isPointSend: Bool
    var isCompleted: Bool
    var isPicture: Bool
    var isDateView: Bool
    
    init(){
        self.messageID = 0
        self.picture = UIImage(named: "pic_profile.png")!
        self.message = ""
        self.date = ""
        self.targetName = ""
        self.targetID = ""
        self.messageType = 1
        self.isTimeChanged = false
        self.isDateChanged = false
        self.isPointSend = false
        self.isCompleted = false
        self.isPicture = false
        self.isDateView = false
    }
    
    init(isDateView: Bool, date: String) {
        self.isDateView = isDateView
        self.date = date
        self.messageID = 0
        self.picture = UIImage(named: "pic_profile.png")!
        self.message = ""
        self.targetName = ""
        self.targetID = ""
        self.messageType = 1
        self.isTimeChanged = false
        self.isDateChanged = false
        self.isPointSend = false
        self.isCompleted = false
        self.isPicture = false
    }
    
    init(messageID: Int, picture: UIImage, message: String, date: String, targetName: String, targetID: String, messageType: Int, isTimeChanged: Bool, isDateChanged: Bool, isPointSend: Bool, isCompleted: Bool, isPicture: Bool) {
        self.messageID = messageID
        self.picture = picture
        self.message = message
        self.date = date
        self.targetName = targetName
        self.targetID = targetID
        self.messageType = messageType
        self.isTimeChanged = isTimeChanged
        self.isDateChanged = isDateChanged
        self.isPointSend = isPointSend
        self.isCompleted = isCompleted
        self.isPicture = isPicture
        self.isDateView = false
    }
}
