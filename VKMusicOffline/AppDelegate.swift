//
//  AppDelegate.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 20.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit
import VK

let kVKApplicationID = "4557517"
let kVKApplicationSecretKey = "284RSWeVjNwxMwk5nX5w"

let kVKAuthScopeFriends = "friends"
let kVKAuthScopeAudio = "audio"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, VKSdkDelegate, UISplitViewControllerDelegate {
    
    // MARK: - View Controllers
    var window: UIWindow?
    var splitViewController: UISplitViewController {
        get {
            return self.window!.rootViewController as UISplitViewController
        }
    }
    var menuViewController: VMMenuViewController {
        get {
            let navigationController = self.splitViewController.viewControllers.last as UINavigationController
            return navigationController.viewControllers.first as VMMenuViewController
        }
    }
    var audioListViewController: VMAudioListViewController {
        get {
            let navigationController = self.splitViewController.viewControllers.first as UINavigationController
            return navigationController.viewControllers.first as VMAudioListViewController
        }
    }
    

    // MARK: - UIApplicationDelegate

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as UINavigationController
        navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self
        splitViewController.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
        
        VKSdk.initializeWithDelegate(self, andAppId:kVKApplicationID)
        if (VKSdk.wakeUpSession() == false) {
            self.vkAuthorize()
        } else if (VKSdk.isLoggedIn() == true) {
            self.vkGetUserInfo()
        } else {
            self.vkAuthorize()
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication!) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication!) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        VMAudioListManager.sharedInstance.saveOfflineAudioLists()
    }

    func applicationWillEnterForeground(application: UIApplication!) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication!) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication!) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        VMAudioListManager.sharedInstance.saveOfflineAudioLists()
    }
    
    // MARK: - NSURLSession
    
    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        if (identifier == VMAudioListManager.sharedInstance.URLSession?.configuration.identifier) {
            VMAudioListManager.sharedInstance.backgroundURLSessionCompletionHandler = completionHandler
        }
    }

    // MARK: - Split view

//    func splitViewController(splitViewController: UISplitViewController!, collapseSecondaryViewController secondaryViewController:UIViewController!, ontoPrimaryViewController primaryViewController:UIViewController!) -> Bool {
//        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
//            if let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController {
//                if !topAsDetailController.detailItem {
//                    // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
//                    return true
//                }
//            }
//        }
//        return false
//    }
    
    func application(application: UIApplication!, openURL url: NSURL!, sourceApplication: String!, annotation: AnyObject!) -> Bool {
        VKSdk.processOpenURL(url, fromApplication:sourceApplication)
        return true
    }
    
    // MARK: - VKSDK Delegate
    
    /**
    Calls when user must perform captcha-check
    @param captchaError error returned from API. You can load captcha image from <b>captchaImg</b> property.
    After user answered current captcha, call answerCaptcha: method with user entered answer.
    */
    func vkSdkNeedCaptchaEnter(captchaError: VKError!) {
        var vc : VKCaptchaViewController = VKCaptchaViewController.captchaControllerWithError(captchaError)
        self.window?.rootViewController?.presentViewController(vc, animated: true, completion:nil)
    }
    
    /**
    Notifies delegate about existing token has expired
    @param expiredToken old token that has expired
    */
    func vkSdkTokenHasExpired(expiredToken: VKAccessToken!) {
        self.vkAuthorize()
    }
    
    /**
    Notifies delegate about user authorization cancelation
    @param authorizationError error that describes authorization error
    */
    func vkSdkUserDeniedAccess(authorizationError: VKError!) {
        
    }
    
    /**
    Pass view controller that should be presented to user. Usually, it's an authorization window
    @param controller view controller that must be shown to user
    */
    func vkSdkShouldPresentViewController(controller: UIViewController!) {
        self.window?.rootViewController?.presentViewController(controller, animated: true, completion: nil)
    }
    
    /**
    Notifies delegate about receiving new access token
    @param newToken new token for API requests
    */
    func vkSdkReceivedNewToken(newToken: VKAccessToken!) {
        self.vkGetUserInfo()
    }
    
    // MARK - VK User
    
    func vkAuthorize() {
        VKSdk.authorize([kVKAuthScopeFriends, kVKAuthScopeAudio], revokeAccess:false, forceOAuth:false, inApp:false)
    }
    
    func vkGetUserInfo() {
        VMUserManager.sharedInstance.loadCurrentUser(completionBlock: { (user: VKUser) -> Void in
            VMAudioListManager.sharedInstance.user = user
        }) { (error: NSError!) -> Void in
            
        }
    }
}

