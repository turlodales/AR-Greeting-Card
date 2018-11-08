//
//  LogInViewController.swift
//  LoginGuide
//
//  This file implement the login page view. Login by username and password and facebook auth are both implemented.

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class LogInViewController: UIViewController, FBSDKLoginButtonDelegate {

    // UI properties
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet var swipeDownGestureRecognizer: UISwipeGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Set swipe down gesture for back action
    @IBAction func swipeDown(_ sender: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: {})
    }
    
    // Make the keyboard goes away when user touches other place
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Prepare the main page after user loggin from welcome page
    func presentGalleryScreen() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let galleryVC = storyboard.instantiateViewController(withIdentifier: "galleryVC") as! SWRevealViewController
        present(galleryVC, animated: true, completion: nil)
    }
    
    // Handle the action when user tapped login button
    @IBAction func logInTapped(_ sender: UIButton) {
        if let username = usernameTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: username, password: password, completion: { (User, Error) in
                if let firebaseError = Error {
                    print(firebaseError.localizedDescription)
                    self.showWrong(firebaseError.localizedDescription)
                    return
                }
                UserDefaults.standard.set(true, forKey: "HasLaunchedOnce")
                self.presentGalleryScreen()
            })
        }
    }
    
    // Log in with facebook login feed back
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        print("Successfully logged in with facebook account.")
    }
    
    // log out with facebook feed back
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of app with facebook account")
    }
    
    // Using facebook API to log in
    func facebookLogIn() {
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else {return}
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        Auth.auth().signIn(with: credentials, completion: { (user, err) in
            if err != nil {
                print("Something went wrong with our user: ", err!)
                return
            }
            self.presentGalleryScreen()
        })
    }
    
    // Handle the action when user tapped facebook login button
    @IBAction func facebookTapped(_ sender: UIButton) {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, err) in
            if err != nil {
                print("facebook sign up went wrong", err!)
                self.showWrong(err!.localizedDescription)
                return
            } else if let res = result, res.isCancelled {
                print("User cancels permission")
                return
            }
            print("Successfully logged in with facebook account.")
            self.facebookLogIn()
        }
    }
    
    // Pop out the alter window when error happened
    func showWrong(_ message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
