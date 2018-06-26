//
//  AppDelegate.swift
//  Modacity
//
//  Created by Perfect Engineer on 1/8/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn
import Amplitude_iOS
import SwiftMessages
import Intercom
import SplunkMint

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Intercom.setApiKey(AppConfig.appIntercomApiKey, forAppId:AppConfig.appIntercomAppId)
        Mint.sharedInstance().disableNetworkMonitoring()
        Mint.sharedInstance().initAndStartSession(withAPIKey: "b2ee2ef2")
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        FirebaseApp.configure()
        Fabric.sharedSDK().debug = true
        Fabric.with([Crashlytics.self])
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        PracticeItemLocalManager.manager.syncWithOlderVersions()
        PlaylistLocalManager.manager.syncWithOlderVersion()
        Amplitude.instance().initializeApiKey(AppConfig.appAmplitudeApiKey)
        
        if (!UserDefaults.standard.bool(forKey: "launchedbefore")) {
            UserDefaults.standard.set(true, forKey: "launchedbefore")
            ModacityAnalytics.LogStringEvent("FIRST LAUNCH")
        }
        
        Intercom.registerUnidentifiedUser()
        ModacityAnalytics.LogEvent(.Launch)
        ModacityAudioEngine.engine.initEngine()
        
        return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        ModacityAnalytics.LogEvent(.Background)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        ModacityAnalytics.LogEvent(.ResumeActive)
        let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
        //application.registerUserNotificationSettings()
        application.registerForRemoteNotifications()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        ModacityAnalytics.LogEvent(.Terminate)
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        if "timesup" != notification.alertAction {
            self.showNotificationView(title:notification.alertTitle ?? "", body: notification.alertBody ?? "")
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String ?? "", annotation: options[UIApplicationOpenURLOptionsKey.annotation]) || GIDSignIn.sharedInstance().handle(url,                                                                                                                                                                                                                                                                                         sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,                                                                                                                                          annotation: [:])
    }
    
    func showNotificationView(title: String, body: String) {
        
        let view = MessageView.viewFromNib(layout: .cardView)
        
        var config = SwiftMessages.Config()
        config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        config.duration = .seconds(seconds: 10)
        config.dimMode = .gray(interactive: true)
        config.interactiveHide = true
        
        view.configureTheme(.warning)
        view.configureDropShadow()
        view.backgroundView.backgroundColor = Color(hexString:"#5756E6")
        view.button?.setTitle("Close", for: .normal)
        view.button?.setTitleColor(Color.white, for: .normal)
        view.button?.backgroundColor = Color(hexString:"#51BE38")
        view.buttonTapHandler = { _ in
            SwiftMessages.hide()
        }
        view.configureContent(title: title, body: body)
        SwiftMessages.show(config: config, view: view)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Intercom.setDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if (Intercom.isIntercomPushNotification(userInfo)) {
            Intercom.handlePushNotification(userInfo)
        }
        completionHandler(.noData);
    }
}

