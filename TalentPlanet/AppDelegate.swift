//
//  AppDelegate.swift
//  TalentPlanet
//
//  Created by 민권홍 on 24/09/2019.
//  Copyright © 2019 민권홍. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let gcmMessageIDKey: String = "gcm.message_id"
    let dbName = "/accepted.db"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        // DB 테이블 설정
        let createDB0 = """
            CREATE TABLE IF NOT EXISTS TB_CHAT_LOG (
                MESSAGE_ID INTEGER PRIMARY KEY,
                ROOM_ID INTEGER,
                MASTER_ID TEXT,
                USER_ID TEXT,
                CONTENT TEXT,
                CREATION_DATE TEXT,
                READED_FLAG TEZT,
                POINT_MSG_FLAG TEXT DEFAULT 0,
                POINT_SEND_FLAG TEXT DEFAULT 0
            )
        """
        
        let createDB1 = """
            CREATE TABLE IF NOT EXISTS TB_CHAT_ROOM (
                ROOM_ID INTEGER,
                USER_ID TEXT,
                USER_NAME TEXT,
                MASTER_ID TEXT,
                START_MESSAGE_ID INTEGER,
                CREATION_DATE TEXT,
                LAST_UPDATE_DATE TEXT,
                ACTIVATE_FLAG TEXT,
                FILE_PATH TEXT,
                PRIMARY KEY(ROOM_ID, USER_ID, MASTER_ID)
            )
        """
        
        let createDB2 = """
            CREATE TABLE IF NOT EXISTS TB_FRIENT_LIST (
                MASTER_ID TEXT,
                FRIEND_ID TEXT,
                TALENT_TYPE TEXT,
                PRIMARY KEY(MASTER_ID, FRIEND_ID, TALENT_TYPE)
            )
        """
        
        let createDB3 = """
            CREATE TABLE IF NOT EXISTS TB_FCM_TOKEN (
                TOKEN TEXT
            )
        """
        
        let createDB4 = """
            CREATE TABLE IF NOT EXISTS TB_GRANT (
                USER_ID TEXT PRIMARY KEY,
                MESSAGE_GRANT TEXT,
                CONDITION_GRANT TEXT,
                ANSWER_GRANT TEXT
            )
        """
        
        let createDB5 = """
            CREATE TABLE IF NOT EXISTS TB_READED_INTEREST (
                USER_ID TEXT,
                TALENT_ID TEXT,
                PRIMARY KEY(USER_ID, USER_ID)
            )
        """
        
        let filemgr = FileManager.default
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        let docsDir = dirPaths[0] as String
        
        let databasesPath = docsDir.appending(dbName)
        
        if !filemgr.fileExists(atPath: databasesPath) {
            let acceptedDB = FMDatabase(path: databasesPath)
            
            if acceptedDB.open() {
                if !acceptedDB.executeStatements(createDB0) {
                    print("Error \(acceptedDB.lastErrorMessage())")
                }
                
                if !acceptedDB.executeStatements(createDB1) {
                    print("Error \(acceptedDB.lastErrorMessage())")
                }
                
                if !acceptedDB.executeStatements(createDB2) {
                    print("Error \(acceptedDB.lastErrorMessage())")
                }
                
                if !acceptedDB.executeStatements(createDB3) {
                    print("Error \(acceptedDB.lastErrorMessage())")
                }
                
                if !acceptedDB.executeStatements(createDB4) {
                    print("Error \(acceptedDB.lastErrorMessage())")
                }
                
                if !acceptedDB.executeStatements(createDB5) {
                    print("Error \(acceptedDB.lastErrorMessage())")
                }
                
                acceptedDB.close()
            }
        }
        Messaging.messaging().delegate = self
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in})
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        Messaging.messaging().apnsToken = deviceToken
    }

}

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("MessageID: \(messageID)")
        }
        
        completionHandler([])
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        saveFcmToken(token: fcmToken)
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
    func saveFcmToken(token: String){
        AF.request("http://175.213.4.39/Accepted/Login/saveFCMToken.do", method: .post, parameters:["userID":UserDefaults.standard.string(forKey: "userID")!, "fcmToken":token])
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
}
