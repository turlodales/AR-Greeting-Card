//
//  CoverEditViewController.swift
//  LoginGuide
// 
//  This file implements the CoverEditViewController, which is used for users to
//  edit the cover images when they create an AR Card.

import UIKit
import ALCameraViewController

class CoverEditViewController: UITableViewController {
    // Default images for cover
    var frontImage = UIImage(named: "1")
    var backImage = UIImage(named:"2")
    private let front = true
    private let back = false
    // UI properties
    @IBOutlet weak var menu: UIBarButtonItem!
    @IBOutlet weak var frontImageView: UIImageView!
    @IBOutlet weak var backImageView: UIImageView!
    // update UI
    func updateImageViews() {
        frontImageView.image = frontImage
        backImageView.image = backImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateImageViews()
        if self.revealViewController() != nil {
            menu.target = self.revealViewController()
            menu.action = #selector(SWRevealViewController.revealToggle(_:))
            
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
    }
    // When this function is called, it will access to camera, and return the image taken by the camera or
    // directly from album.
    // Also update the UI.
    func openCamera(for flag: Bool) {
        print("open camera")
        let cameraVC = CameraViewController(allowsLibraryAccess: true) { [weak self] image, asset in
            if let newImage = image {
                if flag == true {
                    self?.frontImage = newImage
                } else {
                    self?.backImage = newImage
                }
                self?.updateImageViews()
            }
            self?.dismiss(animated: true, completion: nil)
        }
        present(cameraVC, animated: true, completion: nil)
    }
    // When this function is called, it will access to camera, and return the image taken by the camera or
    // directly from album.
    // Also update the UI.
    func openLibrary(for flag: Bool) {
        let cameraVC = CameraViewController() { [weak self] image, asset in
            if let newImage = image {
                if flag == true {
                    self?.frontImage = newImage
                } else {
                    self?.backImage = newImage
                }
                self?.updateImageViews()
            }
            self?.dismiss(animated: true, completion: nil)
        }
        present(cameraVC, animated: true, completion: nil)
    }
    // Set action when user choose a image to edit.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
//            let alertController = UIAlertController(title: "Change Front", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
//            alertController.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.default) {
//                (alertAction) -> Void in
//                self.openCamera(for: self.front)
//            })
//            alertController.addAction(UIAlertAction(title: "Album", style: UIAlertActionStyle.default) {
//                (alertAction) -> Void in
//                self.openLibrary(for: self.front)
//            })
//            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
//            self.present(alertController, animated: true, completion: nil)
            self.openCamera(for: self.front)
        } else if indexPath.row == 3 {
//            let alertController = UIAlertController(title: "Change Back", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
//            alertController.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.default) {
//                (alertAction) -> Void in
//                self.openCamera(for: self.back)
//            })
//            alertController.addAction(UIAlertAction(title: "Album", style: UIAlertActionStyle.default) {
//                (alertAction) -> Void in
//                self.openLibrary(for: self.back)
//            })
//            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
//            self.present(alertController, animated: true, completion: nil)
            self.openCamera(for: self.back)
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 || indexPath.row == 2 {
            return false
        }
        return true
    }
    // segue to ContentViewController, along with the cover images
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Content" {
            var destinationController = segue.destination
            if let navigationController = destinationController as? UINavigationController {
                destinationController = navigationController.visibleViewController ?? destinationController
            }
            if let contentEditViewController = destinationController as? ContentEditViewController {
                contentEditViewController.cover = (frontImage, backImage)
            }
        }
    }
}
