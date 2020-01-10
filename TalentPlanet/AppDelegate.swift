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
    let fcmDataKey: String = "datas"
    let dbName = "/accepted.db"
    var window: UIWindow? = UIWindow()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // DB 테이블 설정
        let createDB0 = """
            CREATE TABLE IF NOT EXISTS TB_CHAT_LOG (
                MESSAGE_ID INTEGER PRIMARY KEY,
                ROOM_ID INTEGER,
                MASTER_ID TEXT,
                USER_ID TEXT,
                CONTENT TEXT,
                CREATION_DATE TEXT,
                READED_FLAG TEXT,
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
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self

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
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID2: \(messageID)")
      }

      // Print full message.
      print(userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)

        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID1: \(messageID)")
        }

//        if let notificationData = userInfo[fcmDataKey] as? NSString {
//            print(notificationData)
//            var dictionary : NSDictionary?
//            if let data = notificationData.data(using: String.Encoding.utf8.rawValue) {
//                do {
//                    dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
//                    print(dictionary)
//                    if let type = dictionary!["type"] as? String {
//                        if type == "Message" {
//                            print("isMessage")
//                        }
//                    }
//                } catch let error as NSError {
//                    print("Error: \(error)")
//                }
//            }
//        }
        
        if let type = userInfo["type"] as? String{
            if type == "Message" {
                if let dataString = userInfo["datas"] as? NSString {
                    do {
                        let datas = try JSONSerialization.jsonObject(with: dataString.data(using: String.Encoding.utf8.rawValue)!, options: []) as! [String:Any]
                        
                        let userID = datas["USER_ID"] as! String
                        let userName = datas["USER_NAME"] as! String
                        let sFilePath = datas["S_FILE_PATH"] as! String
                        let messageID = datas["MESSAGE_ID"] as! Int
                        let receiverID = datas["RECEIVER_ID"] as! String
                        let content = datas["CONTENT"] as! String
                        let creationDate = datas["CREATION_DATE_STRING"] as! String
                        let pointMsgFlag = datas["POINT_MSG_FLAG"] as! String
                        let roomID = CommonFunctions().makeChatRoom(userID: userID, userName: userName, filePath: sFilePath)
                        
                        if roomID > 0 {
                            let insertSql = """
                                                INSERT INTO TB_CHAT_LOG(MESSAGE_ID, ROOM_ID, MASTER_ID, USER_ID, CONTENT, CREATION_DATE, POINT_MSG_FLAG)
                                                VALUES (\(messageID), \(roomID), '\(receiverID)', '\(userID)', '\(content)', '\(creationDate)', '\(pointMsgFlag)')
                                            """
                            
                            print(insertSql)
                            
                            let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                            
                            let docsDir = dirPaths[0] as String
                            
                            let databasesPath = docsDir.appending(dbName)
                            let acceptedDB = FMDatabase(path: databasesPath)
                            
                            if acceptedDB.open() {
                                let result = acceptedDB.executeUpdate(insertSql, withArgumentsIn: [])
                                
                                if result {
                                    
                                    let rootVC = UIApplication.shared.windows.first!.rootViewController as? UINavigationController

                                    if let topViewController = rootVC?.visibleViewController as? MessengerViewController {
                                        topViewController.getChatList()
                                    }
                                } else {
                                    print("ERROR : INSERT MESSAGE")
                                }
                                
                                acceptedDB.close()
                            }
                        }
                        
                    } catch {
                        
                    }
                }
            }
        }

        // Print full message.
        print(userInfo)

        completionHandler(UIBackgroundFetchResult.newData)
    }
}

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)

        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID3: \(messageID)")
        }

        // Print full message.
        print(userInfo)

        // Change this to your preferred presentation option
        completionHandler([.alert])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        UserDefaults.standard.set("mkh9012@naver.co", forKey: "userID")
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID4: \(messageID)")
        }

        // Print full message.
        print(userInfo)

        completionHandler()
        
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            print("hello")
            
        }
    }
    
    func redirectToVC() {
        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "MessageListViewController") as UIViewController
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        //saveFcmToken(token: fcmToken)
        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
        
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
    
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
}
