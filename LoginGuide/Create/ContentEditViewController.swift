//
//  ContentEditViewController.swift
//  LoginGuide
//
//  This file implements the ContentEditViewController, which is used for users to
//  edit the content images when they create an AR Card.


import UIKit
import ALCameraViewController

class ContentEditViewController: UITableViewController {
    // Default images for contents
    var frontImage = UIImage(named: "3")
    var backImage = UIImage(named: "4")
    //var cover = (front: UIImage(named: "1"), back: UIImage(named: "2"))
    
    // data of cover images, will be passed from CoverEditViewController
    var cover: (front: UIImage?, back: UIImage?)
    private let front = true
    private let back = false
    // handle the undo button action
    @IBAction func undoEdit(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true)
    }
    // handle the done button action, which will pass cover and content images to DetailARViewController and jump to that
    @IBAction func doneEdit(_ sender: UIBarButtonItem) {
        if let detailARController = self.storyboard?.instantiateViewController(withIdentifier: "detailARVC") as? DetailARViewController {
            detailARController.cover = cover
            detailARController.content = (frontImage, backImage)
            //self.present(detailARController, animated: true, completion: nil)
            self.present(detailARController, animated: true, completion: {
                detailARController.updateCard()
            })
        }
    }
    // UI properties
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
}
