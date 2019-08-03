//
//  MainTabBarController.swift
//  MyPatient
//
//  Created by Serhii Khomych on 06.07.19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher

class MainTabBarController: UITabBarController, GIDSignInDelegate, GIDSignInUIDelegate, UITabBarControllerDelegate {
    var patient: Patient! = Patient()
    
    let googleDriveService = GTLRDriveService()
    var googleUser: GIDGoogleUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        /***** Configure Google Sign In *****/
        
        GIDSignIn.sharedInstance()?.delegate = self
        
        // GIDSignIn.sharedInstance()?.signIn() will throw an exception if not set.
        GIDSignIn.sharedInstance()?.uiDelegate = self
        
        GIDSignIn.sharedInstance()?.scopes = [kGTLRAuthScopeDrive]
        
        // Attempt to renew a previously authenticated session without forcing the
        // user to go through the OAuth authentication flow.
        // Will notify GIDSignInDelegate of results via sign(_:didSignInFor:withError:)
        GIDSignIn.sharedInstance()?.signInSilently()
        
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil {
            // Include authorization headers/values with each Drive API request.
            self.googleDriveService.authorizer = user.authentication.fetcherAuthorizer()
            self.googleUser = user
        } else {
            self.googleDriveService.authorizer = nil
            self.googleUser = nil
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {        
        if viewController is CameraViewController {
            return !isPatientEmpty()
        } else {
            return true
        }
    }
    
    func isPatientEmpty() -> Bool {
        if patient.fullName == nil || patient.fullName == "" {
            return true
        }
        return false
    }
}
