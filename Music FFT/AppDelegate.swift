//
//  AppDelegate.swift
//  Music FFT
//
//  Created by Mateo Olaya Bernal on 11/21/16.
//  Copyright © 2016 Mateo Olaya Bernal. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SPTAudioStreamingDelegate, SPTCoreAudioControllerDelegate, AudioDeviceDelegate {

    let BARS = 8
    
    var window: UIWindow?
    var auth:SPTAuth!
    var player:SPTAudioStreamingController!
    var authViewController:UIViewController!
    var views:[UIView] = []
    
    var canRender:Bool = true
    
    var viewController:UIViewController!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.auth = SPTAuth.defaultInstance()
        self.player = SPTAudioStreamingController.sharedInstance()
        
        self.auth.clientID = "1729c0362ca74b099a29122de0114bcf"
        self.auth.redirectURL = URL(string: "molayab-music://callback")
        self.auth.sessionUserDefaultsKey = "current session";
        
        self.auth.requestedScopes = [SPTAuthStreamingScope];
        
        self.player.delegate = self;
        
        let audio = AudioDevice()
        try! player.start(withClientId: self.auth.clientID, audioController: audio, allowCaching: true)
        
        audio.delegate = self
        audio.audioDelegate = self
        
        DispatchQueue.main.async {
            self.loginFlow()
        }
        return true
    }
    
    func coreAudioController(_ controller: SPTCoreAudioController!, didOutputAudioOfDuration audioDuration: TimeInterval) {
        //print(controller.clearAudioBuffers())
    }
    
    func next() {
        player.skipNext(nil);
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print(url)
        
        if self.auth.canHandle(url) {
            authViewController.presentingViewController?.dismiss(animated: true, completion: {
                self.viewController = UIViewController()
                self.viewController.view.backgroundColor = UIColor.white
                
                
                
                let width = (self.window?.bounds.width)! / CGFloat(self.BARS)
                let y = self.window?.bounds.height
                
                var post = 0
                
                var new = self.window?.frame
                new?.origin.x = (new?.size.width)! / 2
                new?.origin.y = (new?.size.height)! / 2
                new?.size.width = 100
                new?.size.height = 30
                
                let btn = UIButton(frame: CGRect(x: (new?.size.width)! / 2, y: 200, width: 100, height: 30))
                btn.setTitle("Next", for: .normal)
                btn.titleLabel?.text = "Next"
                btn.setTitleColor(UIColor.black, for: .normal)
                
                btn.addTarget(self, action: #selector(AppDelegate.next as (AppDelegate) -> () -> ()), for: .touchUpInside)
                
                for _ in 0...self.BARS {
                    let view = UIView(frame: CGRect(x: Int(post), y: 0, width: Int(width), height: 30))
                    view.backgroundColor = UIColor.gray
                    
                    post += Int(width) + 2
                    
                    self.viewController.view.addSubview(view)
                }
                
                self.viewController.view.addSubview(btn)
                
                self.window?.rootViewController?.present(self.viewController, animated: true, completion: nil)
            })
                
            
            
            
            self.auth.handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, session) in
                if let s = session {
                    self.player.login(withAccessToken: s.accessToken)
                }
            })
            return true
        }
        
        return false
    }
    
    func loginFlow() {
        if false {
            player.login(withAccessToken: auth.session.accessToken)
        } else {
            let url = auth.spotifyWebAuthenticationURL()
            
            authViewController = SFSafariViewController(url: url!)
            self.window?.rootViewController?.present(authViewController, animated: true, completion: nil)
        }
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        player.setShuffle(true, callback: nil)
        player.playSpotifyURI("spotify:user:molayab:playlist:5nOlUs1zwctAa2talWYiwf", startingWith: 0, startingWithPosition: 0, callback: { (error) in
            
        })
        player.setShuffle(true, callback: nil)
    }
    
    func coreAudioController(_ controller: SPTCoreAudioController!, didReceivedFrecuenciesData frecuencies: UnsafeMutablePointer<Float>!) {
        
        DispatchQueue.main.async {
            
        
            if self.canRender {

                
                UIView.animate(withDuration: 0.15, animations: {
                    var i = 0
                    for ii in [3, 12, 25, 50, 115, 200, 200, 255]{
                        let f = (frecuencies[ii].isNaN) ? 1.0 : frecuencies[ii]
                        
                        if f.isInfinite {
                            print("Frec \(ii): \(f.isInfinite)")
                        }
                        
                        self.viewController.view.subviews[i].frame = CGRect(
                            x: self.viewController.view.subviews[i].frame.origin.x,
                            y: 0,
                            width: self.viewController.view.subviews[i].frame.size.width,
                            height: (f.isInfinite) ? 1 : CGFloat(f))
                        
                        i += 1
                        
                    }
                }, completion: { (success) in
                    self.canRender = true
                })
            }
        }
        
        
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

