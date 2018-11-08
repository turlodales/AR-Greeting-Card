//
//  DetailARViewController.swift
//  LoginGuide
//
//  This file implements DetailARViewController, which is used to create AR object
//  projection and display it.

import UIKit
import SceneKit
import ARKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import Alamofire
import AlamofireImage

// View for demonstrating AR
class DetailARViewController: UIViewController, ARSCNViewDelegate, ARSessionObserver {
    
    // UI properties
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var toast: UIVisualEffectView!
    @IBOutlet weak var toastLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    let path = Auth.auth().currentUser?.uid
    var ref: DatabaseReference?
    let downloader = ImageDownloader()
    
    // Set AR card's dimension
    //let plane = SCNNode()
    let card = ARCard(width: 0.2, height: 0.2)
    
    // Set default images
    var cover = (front: UIImage(named: "1"), back: UIImage(named: "2"))
    var content = (front: UIImage(named: "3"), back: UIImage(named: "1"))
    
    // Update images whenever needed
    func updateCard() {
        card.setCover(front: cover.front!, back: cover.back!)
        card.setContent(front: content.front!, back: cover.front!)
        //print(card.childNodes)
    }
    
    // Set basic constrains
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        sceneView.delegate = self
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetailARViewController.didTap(_:)))
        sceneView.addGestureRecognizer(tapRecognizer)
        //card.setCover(front: #imageLiteral(resourceName: "TypeThumb"), back: #imageLiteral(resourceName: "page1_landscape"))
        //card.setContent(front: #imageLiteral(resourceName: "page2_landscape"), back: #imageLiteral(resourceName: "TypeThumb"))
        //card.setCover(front: UIImage(named: "1")!, back: UIImage(named: "2")!)
        //card.setContent(front: UIImage(named: "3")!, back: UIImage(named: "4")!)
        //updateCard()
    }
    
    // Start AR session
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        startNewSession()
    }
    
    // Stop AR session
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        sceneView.session.pause()
    }
    
    // Handle action when user tap close
    @IBAction func closeTapped(_ sender: UIButton) {
        //        self.dismiss(animated: true, completion: nil)
        if let presentVC = presentingViewController {
            presentVC.dismiss(animated: true, completion: nil)
        } else {
            let galleryVC = self.storyboard?.instantiateViewController(withIdentifier: "galleryVC") as! SWRevealViewController
            self.present(galleryVC, animated: true, completion: nil)
        }
    }
    
    // Handle action when user tap share
    @IBAction func shareTapped(_ sender: UIButton) {
        combineURLs { (url) in
            // the title of shared information
            let title = "Check out an new AR E-Card sent to you!"
            // the url we want to share
            //let url = NSURL(string: "www.google.com")!
            let activityItems = [title, url] as [Any]
            let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            // services not include
            let excludedActivities = [UIActivityType.saveToCameraRoll, UIActivityType.print, UIActivityType.assignToContact, UIActivityType.addToReadingList, UIActivityType.postToVimeo, UIActivityType.postToFlickr, UIActivityType.openInIBooks]
            activityController.excludedActivityTypes = excludedActivities
            activityController.completionWithItemsHandler = { [weak self] activity, completed, items, error in
                // if sending complete, pop up an alert
                // click the button to return to gallery
                if completed {
                    print("done sending")
                    activityController.dismiss(animated: true, completion: nil)
                    let alertController = UIAlertController(title: "Send Complete!", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                        (alertAction) -> Void in
                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                        let galleryVC = storyboard.instantiateViewController(withIdentifier: "galleryVC") as! SWRevealViewController
                        self?.present(galleryVC, animated: true, completion: nil)
                    })
                    self?.present(alertController, animated: true, completion: nil)
                }
            }
            self.present(activityController, animated: true, completion: nil)
        }
    }
    
    func startNewSession() {
        // Create a session configuration with horizontal plane detection
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
    }
    
    // Bottom indicator for current state of AR
    func showToast(_ text: String) {
        toastLabel.text = text
        
        guard toast.alpha == 0 else {
            return
        }
        toast.layer.masksToBounds = true
        toast.layer.cornerRadius = 7.5
        
        UIView.animate(withDuration: 0.25, animations: {
            self.toast.alpha = 1
            self.toast.frame = self.toast.frame.insetBy(dx: -5, dy: -5)
        })
    }
    
    func hideToast() {
        UIView.animate(withDuration: 0.25) {
            self.toast.alpha = 0
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        showToast("Session was interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        startNewSession()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        showToast("Session failed: \(error.localizedDescription)")
        startNewSession()
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        var message: String? = nil
        
        switch camera.trackingState {
        case .notAvailable:
            message = "Tracking not available"
        case .limited(.initializing):
            message = "Initializing AR session"
        case .limited(.excessiveMotion):
            message = "Too much motion"
        case .limited(.insufficientFeatures):
            message = "Not enough surface details"
        case .normal:
            message = "Ready to render an AR E-Card"
        }
        
        message != nil ? showToast(message!) : hideToast()
    }
    
    @objc func didTap(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: sceneView)
        let result = sceneView.hitTest(location, types: [.existingPlane, .estimatedHorizontalPlane])
        if let bestResult = result.first {
            if let _ = sceneView.hitTest(location, options: nil).first {
                card.respondsToTap()
            } else {
                card.simdTransform = bestResult.worldTransform
                sceneView.scene.rootNode.addChildNode(card)
            }
        }
    }
    
    // Render AR into the real world
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            card.simdTransform = anchor.transform
            //card.contentFrontNode?.position = SCNVector3Make((card.contentFrontNode?.position.x)!, (card.contentFrontNode?.position.y)! - 0.001, (card.contentFrontNode?.position.z)!)
//            card.coverFrontNode?.position = SCNVector3Make((card.coverFrontNode?.position.x)!, (card.coverFrontNode?.position.y)! + 0.01, (card.coverFrontNode?.position.z)!)
//            card.coverBackNode?.position = SCNVector3Make((card.coverBackNode?.position.x)!, (card.coverBackNode?.position.y)! + 0.01, (card.coverBackNode?.position.z)!)
        }
    }
    
    // Hide share button when user get into the view with the shared URL
    func hideShareButton() {
        self.sendButton.isHidden = true
    }
    
    // upload each image and get its URL
    func upload(_ image: UIImage, _ name: String, at folder: String, completion: @escaping (String) -> ())  {
        var data = Data()
        data = UIImagePNGRepresentation(image)!
        let storage = Storage.storage().reference().child(path!).child(folder).child("\(name).png")
        _ = storage.putData(data, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                print("ERROR with \(name): \(error!.localizedDescription)")
                return
            } else {
                print("SUCCESSED with \(name)")
                let URL = metadata?.downloadURL()?.absoluteString
                completion(URL!)
            }
        })
    }
    
    // upload ALL images
    func uploadImages(completion: @escaping ([String : String]) -> ()) {
        let folder = NSUUID().uuidString
        var download = [String : String]()
        let images = [(card.coverFrontImage, "coverF"), (card.coverBackImage, "coverB"), (card.contentFrontImage, "contentF"), (card.contentBackImage, "contentB")]
        for (image, name) in images {
            _ = upload(image!, name, at: folder, completion: { (url) in
                download[name] = url
                if download.count == 4 {
                    completion(download)
                }
            })
        }
    }
    
    func combineURLs(completion: @escaping (String) -> ()) {
        let folder = NSUUID().uuidString
        _ = uploadImages(completion: { (urls) in
            var count = 0
            for (name, url) in urls {
                self.ref?.child("Shares").child(self.path!).child(folder).child(name).setValue(["url" : url], withCompletionBlock: { (err, databaseReference) in
                    count += 1
                    if count == urls.count {
                        print("UPLOADED ALL THE URL")
                        completion("ARCDL://download/\(self.path!)/\(folder)")
                    }
                })
            }
            
        })
    }
    
    // Download image from the given url
    func downloadImages(from url: URL, completion: @escaping (UIImage, UIImage, UIImage, UIImage) -> ()) {
        let address = url.path.components(separatedBy: "/")
        let path = address[1]
        let folder = address[2]
        var coverFImage: UIImage?
        var coverBImage: UIImage?
        var contentFImage: UIImage?
        var contentBImage: UIImage?
        var count = 0
        ref?.child("Shares").child(path).child(folder).observeSingleEvent(of: .value, with: { (snapshot) in
            if let imageURLs = snapshot.value as? NSDictionary {
                for (name, url) in imageURLs {
                    if let url = url as? Dictionary<String, String>, let name = name as? String {
                        //print("name: \(name) - url: \(url["url"]!)")
                        let urlRequest = URLRequest(url: URL(string: url["url"]!)!)
                        self.downloader.download(urlRequest, completion: { (response) in
                            print("DOWNLOAD - \(name)")
                            if let image = response.result.value {
                                print(image)
                                switch name {
                                case "coverF":
                                    coverFImage = image
                                case "coverB":
                                    coverBImage = image
                                case "contentF":
                                    contentFImage = image
                                case "contentB":
                                    contentBImage = image
                                default:
                                    print("WRONG NAME")
                                }
                                count += 1
                                if count == 4 {
                                    completion(coverFImage!, coverBImage!, contentFImage!, contentBImage!)
                                }
                            }
                        })
                    }
                }
            }
        })
    }
    
    
    // Update card with download images
    func changeImages(from url: URL) {
        self.downloadImages(from: url) { (coverF, coverB, contentF, contentB) in
            print("DOWNLOAD ALL THE IMAGES, READY TO RENDER")
            self.cover = (coverF, coverB)
            self.content = (contentF, coverF)
            self.updateCard()
        }
    }
    
    // Actual download process
    func download(image name: String, from url: String, completion: @escaping (UIImage) -> ()) {
        Alamofire.request(url, method: .get).responseImage { response in
            guard let image = response.result.value else {
                print("ERROR AT: \(name)")
                return
            }
            completion(image)
        }
    }
    
}
