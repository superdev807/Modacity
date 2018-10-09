//
//  AppDelegate.swift
//  Modacity
//
//  Created by Benjamin Chris on 1/8/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn
import Amplitude_iOS
import SwiftMessages
import Intercom
import SplunkMint
import UserNotifications
import StoreKit
import Reachability

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    let reachability = Reachability()!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Mint.sharedInstance().disableNetworkMonitoring()
        Mint.sharedInstance().initAndStartSession(withAPIKey: AppConfig.ThirdParty.appMintApiKey)
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        
        Fabric.sharedSDK().debug = true
        Fabric.with([Crashlytics.self])
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        PracticeItemLocalManager.manager.syncWithOlderVersions()
        PlaylistLocalManager.manager.syncWithOlderVersion()
        
        Amplitude.instance().initializeApiKey(AppConfig.ThirdParty.appAmplitudeApiKey)
        
        if (!UserDefaults.standard.bool(forKey: "launchedbefore")) {
            UserDefaults.standard.set(true, forKey: "launchedbefore")
            ModacityAnalytics.LogStringEvent("FIRST LAUNCH")
        }
        
        Intercom.setApiKey(AppConfig.ThirdParty.appIntercomApiKey, forAppId:AppConfig.ThirdParty.appIntercomAppId)
        Intercom.registerUnidentifiedUser()
        
        ModacityAnalytics.LogEvent(.Launch)
        ModacityAudioEngine.engine.initEngine()
        
        configureReachability()
        
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
//        AppOveralDataManager.manager.saveStreak()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        ModacityAnalytics.LogEvent(.Terminate)
        reachability.stopNotifier()
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        if "timesup" != notification.alertAction {
            self.showNotificationView(title:notification.alertTitle ?? "", body: notification.alertBody ?? "")
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String ?? "", annotation: options[UIApplicationOpenURLOptionsKey.annotation]) || GIDSignIn.sharedInstance().handle(url,                                                                                                                                                                                                                                                                                         sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,                                                                                                                                          annotation: [:])
    }
    
    func registerNotifications(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: {(granted,error) in
                if granted {
                    ModacityAnalytics.LogStringEvent("User Enabled Push Notifications")
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                } else {
                    ModacityAnalytics.LogStringEvent("User Refused Push Notifications")
                }
            })
        } else {
            let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
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
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        ModacityDebugger.debug("did fail to register for remote notifications")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if (Intercom.isIntercomPushNotification(userInfo)) {
            Intercom.handlePushNotification(userInfo)
        }
        completionHandler(.noData);
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return [.portrait, .portraitUpsideDown]
    }
    
    func configureReachability() {
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                ModacityDebugger.debug("NETWORK STATUS - connected via WiFi")
            } else {
                ModacityDebugger.debug("NETWORK STATUS - connected via Cellular")
            }
            MyProfileRemoteManager.manager.processResumeOnline()
            PremiumDataManager.manager.processResumeOnline()
        }
        
        reachability.whenUnreachable = { _ in
            ModacityDebugger.debug("NETWORK STATUS - Offline")
            MyProfileRemoteManager.manager.processOffline()
            PremiumDataManager.manager.processOffline()
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            ModacityDebugger.debug("NETWORK STATUS - Unable to start notifier")
        }
    }
}

