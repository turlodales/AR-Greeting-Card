//
//  MenuViewController.swift
//  
//
//  This file implements the slide bar menu on the left.

import UIKit
import FirebaseAuth

class MenuViewController: UIViewController {
    
    // UI properties
    @IBOutlet weak var gallery: UIButton!
    @IBOutlet weak var create: UIButton!
    @IBOutlet weak var calender: UIButton!
    @IBOutlet weak var signOut: UIButton!
    
    // Set UI constrains
    override func viewDidLoad() {
        super.viewDidLoad()
        gallery.imageEdgeInsets.left = 16
        gallery.titleEdgeInsets.left = 32
        create.imageEdgeInsets.left = 16
        create.titleEdgeInsets.left = 32
        calender.imageEdgeInsets.left = 16
        calender.titleEdgeInsets.left = 32
        signOut.imageEdgeInsets.left = 16
        signOut.titleEdgeInsets.left = 32
    }
    
    // Set menu view
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.revealViewController() != nil {
            self.revealViewController().view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().frontViewController.revealViewController().tapGestureRecognizer()
            self.revealViewController().frontViewController.view.isUserInteractionEnabled = false
        }
    }
    
    // Disable the action at main page when manu view is presented
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.revealViewController() != nil {
            //self.revealViewController().frontViewController.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().frontViewController.view.isUserInteractionEnabled = true
        }
    }
    
    // Handle the action when user tapped the sign out button
    @IBAction func signOutTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Sign out", message: "Are you sure?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { UIAlertAction in
            do {
                try Auth.auth().signOut()
                self.presentWelcomeScreen()
            } catch {
                print("Something went wrong when signing out")
            }
        }
        let noAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Prepare the welcome page after signing out
    func presentWelcomeScreen() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let welcome = storyboard.instantiateViewController(withIdentifier: "welcomeAloneVC")
        present(welcome, animated: true, completion: nil)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
