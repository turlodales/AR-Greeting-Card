//
//  AppDelegate.swift
//  LoginGuide
//


import UIKit
import UserNotifications
import Firebase
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let foregroundNotification = ForegroundNotificationDelegete()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Firebase configuration
        FirebaseApp.configure()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        // Notification configuration
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
            if granted {
                
            }
        }
        center.delegate = foregroundNotification
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // dicide whether weclome page is entry point
        if UserDefaults.standard.bool(forKey: "HasLaunchedOnce") {
            // decide whether logged in or not
            let identifier = Auth.auth().currentUser != nil ? "galleryVC" : "welcomeAloneVC"
            let initialVC = storyboard.instantiateViewController(withIdentifier: identifier)
            self.window?.rootViewController = initialVC
        } else {
            let initialVC = storyboard.instantiateViewController(withIdentifier: "welcomeVC")
            self.window?.rootViewController = initialVC
        }
        self.window?.makeKeyAndVisible()
        return true
    }
    
    // Handle the user click the shared URL
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
//        print("URL : \(url)")
//        print("Host: \(String(describing: url.host!))")
//        print("Path: \(url.path)")
        // Facebook login configuration
        if url.host != "download" {
            let handle = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
            return handle
        }
        // Shared URL
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailARVC = storyboard.instantiateViewController(withIdentifier: "detailARVC") as! DetailARViewController
        self.window?.rootViewController = detailARVC
//        self.window?.rootViewController?.addChildViewController(detailARVC)
//        detailARVC.view.frame = (self.window?.rootViewController?.view.bounds)!
//        self.window?.rootViewController?.view.addSubview(detailARVC.view)
//        detailARVC.didMove(toParentViewController: self.window?.rootViewController)
        detailARVC.changeImages(from: url)
        detailARVC.hideShareButton()
        self.window?.makeKeyAndVisible()
        return true
    }
    
    // Make the application only has portrait mode
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
}

