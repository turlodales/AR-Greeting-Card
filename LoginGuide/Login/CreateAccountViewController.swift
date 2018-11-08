//
//  CreateAccountViewController.swift
//  LoginGuide
//
//  This file implements the view of creating account. Both user creation and facebook linked creation are implemented.

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class CreateAccountViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let loginButton = FBSDKLoginButton()
//        self.view.addSubview(loginButton)
//        loginButton.frame = CGRect(x: 16, y: 50, width: view.frame.width - 32, height: 50)
//        loginButton.delegate = self
//        loginButton.readPermissions = ["email", "public_profile"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Make the keyboard goes away when user touch other place
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Handle the user's action when sign up button is tapped
    @IBAction func signUpTapped(_ sender: UIButton) {
        if let username = usernameTextField.text, let password = passwordTextField.text, let confirm = confirmTextField.text {
            if password == confirm {
                Auth.auth().createUser(withEmail: username, password: password, completion: { (User, Error) in
                    if let firebaseError = Error {
                        print(firebaseError.localizedDescription)
                        self.createWrong(firebaseError.localizedDescription)
                        return
                    }
                    UserDefaults.standard.set(true, forKey: "HasLaunchedOnce")
                    self.presentGalleryScreen()
                })
            } else {
                print("Password != Confirmation")
            }
        }
    }
    
    // Set swipe down gesture for back action
    @IBAction func swipeDown(_ sender: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    // Handle user's action when social media login button is tapped
    @IBAction func facebookTapped(_ sender: UIButton) {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, err) in
            if err != nil {
                print("facebook sign up went wrong", err!)
                return
            } else if let res = result, res.isCancelled {
                print("User cancels permission")
                return
            }
            print("Successfully logged in with facebook account.")
            self.facebookLogIn()
        }
    }
    
    // Autorize the login information for fackbook
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
    
    // Configure the main page after successfully logged into the application
    func presentGalleryScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let galleryVC = storyboard.instantiateViewController(withIdentifier: "galleryVC") as! SWRevealViewController
        self.present(galleryVC, animated: true, completion: nil)
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of app with facebook account")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        print("Successfully logged in with facebook account.")
    }

    // Generate alter window when login information is wrong
    func createWrong(_ message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
