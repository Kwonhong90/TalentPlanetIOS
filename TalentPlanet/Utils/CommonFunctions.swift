//
//  CommonFunctions.swift
//  TalentPlanet
//
//  Created by 민권홍 on 05/11/2019.
//  Copyright © 2019 민권홍. All rights reserved.
//

import Foundation
class CommonFunctions {
    func getTalentTitleByCateCode(cateCode: Int) -> String {
        switch cateCode {
        case 1:
            return "취업"
        case 2:
            return "학습"
        case 3:
            return "재테크"
        case 4:
            return "IT"
        case 5:
            return "사진"
        case 6:
            return "음악"
        case 7:
            return "미술"
        case 8:
            return "운동"
        case 9:
            return "생활"
        case 10:
            return "뷰티"
        case 11:
            return "봉사활동"
        case 12:
            return "여행"
        case 13:
            return "문화"
        case 14:
            return "게임"
        default:
            return "검색"
        }
    }
    
    func getTalentImageNameArr() -> [String] {
        return ["pic_career.png", "pic_study.png", "pic_money.png", "pic_it.png", "pic_camera.png", "pic_music.png", "pic_design.png", "pic_sports.png", "pic_living.png", "pic_beauty.png", "pic_volunteer.png", "pic_travel.png", "pic_culture.png", "pic_game.png"]
    }
    
    func getTalentIconNameArr() -> [String] {
        return ["icon_career.png", "icon_study.png", "icon_money.png", "icon_it.png", "icon_camera.png", "icon_music.png", "icon_design.png", "icon_sports.png", "icon_living.png", "icon_beauty.png", "icon_volunteer.png", "icon_travel.png", "icon_culture.png", "icon_game.png"]
    }
    
    func makeChatRoom(userID: String, userName: String, filePath: String) -> Int {
        let dbName = "/accepted.db"
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        let docsDir = dirPaths[0] as String
        
        let databasesPath = docsDir.appending(dbName)
        print(databasesPath)
            let acceptedDB = FMDatabase(path: databasesPath)

            if acceptedDB.open() {
                let selectMaxMessageIdSql = "SELECT IFNULL(MAX(A.START_MESSAGE_ID), 0) AS START_MESSAGE_ID FROM TB_CHAT_ROOM A WHERE A.USER_ID = '\(userID)'"
                let result = acceptedDB.executeQuery(selectMaxMessageIdSql, withArgumentsIn: [])

                if result == nil {
                    print("error : SELECT MAX MESSAGE ID")
                    return -1
                } else {

                    let startMessageID = NSNumber(value: (result?.int(forColumnIndex: 0))!).intValue
                    
                    let selectMaxIdSql = "SELECT IFNULL(MAX(B.ROOM_ID), (SELECT IFNULL(MAX(C.ROOM_ID) + 1, 1) FROM TB_CHAT_ROOM C)) AS MESSAGE_ID FROM TB_CHAT_ROOM B WHERE B.USER_ID = '\(userID)' AND B.ACTIVATE_FLAG = 'Y'"

                    let result2 = acceptedDB.executeQuery(selectMaxIdSql, withArgumentsIn: [])
                    
                    if result2 == nil {
                        print("error : SELECT MAX ROOM ID")
                        return -1
                    } else {
                        var roomID: Int!
                        while result2!.next() {
                            roomID = NSNumber(value: (result2?.int(forColumnIndex: 0))!).intValue
                        }
                        let today = Date()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"

                        let todayStr = dateFormatter.string(from: today)
                        let selectCreationDateSql = "SELECT IFNULL(MAX(CREATION_DATE), '\(todayStr)') AS CREATION_DATE FROM TB_CHAT_ROOM D WHERE D.USER_ID = '\(userID)'"
                        let result3 = acceptedDB.executeQuery(selectCreationDateSql, withArgumentsIn: [])
                        
                        if result3 == nil {
                            print("error : SELECT CREATION DATE")
                            return -1
                        } else {
                            var creationDate: String!
                            while result3!.next() {
                                creationDate = result3?.string(forColumn: "CREATION_DATE")!
                            }
                            
                            let insertRoomSql = "INSERT OR REPLACE INTO TB_CHAT_ROOM(ROOM_ID, USER_ID, USER_NAME, MASTER_ID, START_MESSAGE_ID, CREATION_DATE, LAST_UPDATE_DATE, ACTIVATE_FLAG, FILE_PATH) VALUES (\(String(describing: roomID!)), '\(userID)', '\(userName)', '\(String(describing: UserDefaults.standard.string(forKey: "userID")!))', '\(String(describing: startMessageID))', '\(String(describing: creationDate!))', '\(todayStr)', 'Y', '\(filePath)')"

                            let result4 = acceptedDB.executeUpdate(insertRoomSql, withArgumentsIn: [])
                            
                            if !result4 {
                                print("error : INSERT ROOM")
                            } else {
                                return roomID
                            }
                        }
                    }
                }
            }
        
        return -1
    }
}
