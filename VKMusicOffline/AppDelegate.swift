//
//  AppDelegate.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 20.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit
import VKSdkFramework
import Fabric
import Crashlytics


let kVKApplicationID = "4557517"
let kVKApplicationSecretKey = "284RSWeVjNwxMwk5nX5w"

let kVKAuthScopeFriends = "friends"
let kVKAuthScopeAudio = "audio"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, VKSdkDelegate, VKSdkUIDelegate, UISplitViewControllerDelegate {
    
    // MARK: - View Controllers
    var window: UIWindow?
    var splitViewController: UISplitViewController? {
        return self.window?.rootViewController as? UISplitViewController
    }

    // MARK: - UIApplicationDelegate

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        Fabric.with([Crashlytics()])
        
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController

        splitViewController.delegate = self
        splitViewController.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
        
        self.vkInitialize()
        
        // Background fetch interval
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)    // 1 hour
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        VMAudioListManager.sharedInstance.saveOfflineAudioLists()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        VKSdk.wakeUpSession(self.vkScope) { (state: VKAuthorizationState, error: NSError!) -> Void in
            switch state {
            case .Initialized: // SDK initialized and ready to authorize
                VMLog("Succesfully authorized user")
                self.vkAuthorize()
            case .Authorized: // User authorized
                VMLog("Succesfully authorized user")
                self.vkGetUserInfo()
            case .Error: // An error occured, try to wake up session later
                fallthrough
            default:
                self.splitViewController?.presentViewController(UIAlertController(error: error), animated: true, completion: nil)
            }
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        VMAudioListManager.sharedInstance.saveOfflineAudioLists()
    }
    
    @available(iOS 9.0, *)
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        VKSdk.processOpenURL(url, fromApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as! String)
        return true
    }
    
    @available(iOS 8.0, *)
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        VKSdk.processOpenURL(url, fromApplication:sourceApplication)
        return true
    }
    
    // MARK: Background fetch
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        VMLog("Background fetch begins...")
        self.vkInitialize()
        VKSdk.wakeUpSession(self.vkScope) { (state: VKAuthorizationState, error: NSError!) -> Void in
            guard state == .Authorized else {
                VMLog("Background fetch end: VK user is not authorized")
                completionHandler(.Failed)
                return
            }
            
            VMUserManager.sharedInstance.loadCurrentUser(completionBlock: { (user: VKUser) -> Void in
                VMAudioListManager.sharedInstance.user = user
                VMAudioListManager.sharedInstance.syncAudioList.synchronize { (change, error) -> Void in
                    if let error = error {
                        completionHandler(.Failed)
                        VMLog("Background fetch end: sync failed with error \(error)")
                        return
                    }
                    
                    if let changeInfo = change where (changeInfo.insertedAudios.count > 0 ||
                        changeInfo.movedAudios.count > 0 || changeInfo.removedAudios.count > 0) {                            
                            VMLog("Background fetch end; have new data: \(changeInfo)")
                            completionHandler(.NewData)
                    } else {
                        VMLog("Background fetch end: no new data")
                        completionHandler(.NoData)
                    }
                }
                })
            { (error: NSError!) -> Void in
                VMLog("Background fetch end: VKUser data loading failed: \(error)")
                completionHandler(.Failed)
            }
        }
    }
    
    
    // MARK: NSURLSession
    
    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        let downloadManager = VMAudioListManager.sharedInstance.downloadManager
        if (identifier == downloadManager.URLSession?.configuration.identifier) {
            downloadManager.backgroundURLSessionCompletionHandler = completionHandler
        }
    }

    // MARK: - Split view
    
    func splitViewControllerSupportedInterfaceOrientations(splitViewController: UISplitViewController) -> UIInterfaceOrientationMask {
        var orientations: UIInterfaceOrientationMask = UIInterfaceOrientationMask.All
        switch UIDevice.currentDevice().userInterfaceIdiom {
        case .Phone:
            orientations = UIInterfaceOrientationMask.Portrait
        default:
            orientations = UIInterfaceOrientationMask.All
        }
        return orientations;
    }
    
    func splitViewControllerPreferredInterfaceOrientationForPresentation(splitViewController: UISplitViewController) -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
    

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            if let topAsDetailController = secondaryAsNavController.topViewController as? VMAudioListViewController {
                if topAsDetailController.audioList == nil {
                    // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
                    return true
                }
            }
        }
        return false
    }
    
    
    // MARK: - VKSDK Delegate
    
    /**
    Notifies delegate about authorization was completed, and returns authorization result which presents new token or error.
    @param result contains new token or error, retrieved after VK authorization
    */
    func vkSdkAccessAuthorizationFinishedWithResult(result: VKAuthorizationResult!) {
        if let _ = result.token {
            self.vkGetUserInfo()
        } else if let error = result.error {
            self.splitViewController?.presentViewController(UIAlertController(error: error), animated: true, completion: nil)
        }
    }
    
    /**
     Notifies delegate about access error, mostly connected with user deauthorized application
     */
    func vkSdkUserAuthorizationFailed() {
        
    }
    
    /**
     Notifies delegate about access token changed
     @param newToken new token for API requests
     @param oldToken previous used token
     */
    func vkSdkAccessTokenUpdated(newToken: VKAccessToken!, oldToken: VKAccessToken!) {
        
    }
    
    /**
     Notifies delegate about existing token has expired
     @param expiredToken old token that has expired
     */
    func vkSdkTokenHasExpired(expiredToken: VKAccessToken!) {
        self.vkAuthorize()
    }
    
    // MARK - VK UI Delegate
    
    /**
    Pass view controller that should be presented to user. Usually, it's an authorization window
    @param controller view controller that must be shown to user
    */
    func vkSdkShouldPresentViewController(controller: UIViewController!) {
        self.splitViewController?.presentViewController(controller, animated: true, completion: nil)
    }
    
    /**
     Calls when user must perform captcha-check
     @param captchaError error returned from API. You can load captcha image from <b>captchaImg</b> property.
     After user answered current captcha, call answerCaptcha: method with user entered answer.
     */
    func vkSdkNeedCaptchaEnter(captchaError: VKError!) {
        let vc = VKCaptchaViewController.captchaControllerWithError(captchaError)
        self.window?.rootViewController?.presentViewController(vc, animated: true, completion:nil)
    }
    
    /**
     * Called when a controller presented by SDK will be dismissed
     */
    func vkSdkWillDismissViewController(controller: UIViewController!) {
        
    }
    
    /**
     * Called when a controller presented by SDK did dismiss
     */
    func vkSdkDidDismissViewController(controller: UIViewController!) {
        
    }
    
    // MARK - VK 
    
    func vkInitialize() {
        let vkSDK = VKSdk.initializeWithAppId(kVKApplicationID)
        vkSDK.registerDelegate(self)
        vkSDK.uiDelegate = self
    }
    
    func vkAuthorize() {
        VKSdk.authorize([kVKAuthScopeFriends, kVKAuthScopeAudio])
    }
    
    func vkGetUserInfo() {
        VMUserManager.sharedInstance.loadCurrentUser(completionBlock: { (user: VKUser) -> Void in
            VMAudioListManager.sharedInstance.user = user
            
        }) { (error: NSError!) -> Void in
            if error.domain == VKSdkErrorDomain &&
                error.code == Int(VK_API_ERROR) {
                    self.vkAuthorize()
            }
        }
    }
    
    var vkScope: [String] {
        return [kVKAuthScopeFriends, kVKAuthScopeAudio]
    }
    
    // MARK: - Crashlytics
    
    func logUserToCrashlytics(user: VKUser) {
        // You can call any combination of these three methods
//        Crashlytics.sharedInstance().setUserEmail(user.id)
        Crashlytics.sharedInstance().setUserIdentifier("\(user.id)")
        Crashlytics.sharedInstance().setUserName("\(user.first_name) \(user.last_name)")
    }


}


extension UIAlertController {
    
    convenience init(error: NSError) {
        var message: String? = nil
        if let vkMessage = error.userInfo[VkErrorDescriptionKey] as? String {
            message = vkMessage
        } else {
            message = error.userInfo[NSLocalizedDescriptionKey] as? String
        }
        self.init(title: "Error", message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default) { (action: UIAlertAction) -> Void in
            self.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
        self.addAction(okAction)
    }
    
}
