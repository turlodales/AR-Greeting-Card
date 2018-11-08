//
//  ViewController.swift
//  LoginGuide
//
//  This file implements the welcome page views when user first time launch the application.

import UIKit
import FirebaseAuth

class WelcomePageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    // UI properties
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pageBottomConstrain: NSLayoutConstraint!
    @IBOutlet weak var skipTopConstrain: NSLayoutConstraint!
    @IBOutlet weak var nextTopConstrain: NSLayoutConstraint!
    
    fileprivate var pc: NSLayoutConstraint?
    fileprivate var sc: NSLayoutConstraint?
    fileprivate var nc: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeKeyboardNotifications()
    }
    
    // Welcome page structure
    fileprivate let pages: [Page] = {
        let firstPage = Page(title: "TEST1", message: "TEST MESSAGE 1", imageName: "page1")
        let secondPage = Page(title: "TEST2", message: "TEST MESSAGE 2", imageName: "page2")
        let thirdPage = Page(title: "TEST3", message: "TEST MESSAGE 3", imageName: "page3")
        return [firstPage, secondPage, thirdPage]
    }()
    
    // Provide number of item in each section for collectionview
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count + 1
    }
    
    // Provide cell data for collectionview
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // The front three normal welcome page
        if indexPath.item == pages.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "loginID", for: indexPath)
            return cell
        }
        // The last welcome page with buttons
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellID", for: indexPath) as! PageCell
        cell.page = pages[indexPath.item]
        return cell
    }
    
    // Provide size for each cell in collectionview
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    // Set notification center configuration
    fileprivate func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // Animation for hiding keyboard
    @objc fileprivate func keyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            }, completion: nil)
    }
    
    // Animation for showing keyboard
    @objc fileprivate func keyboardShow() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.view.frame = CGRect(x: 0, y: -60, width: self.view.frame.width, height: self.view.frame.height)
            }, completion: nil)
    }
    
    // Make the keyboard goes away when user tap other place
    @IBAction func tapOnLoginBackground(_ sender: AnyObject) {
        view.endEditing(true)
        //observeKeyboardNotifications()
    }
    
    // Make the keyboard goes away when user scroll the welcome page back and forth
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    // Set the page control to correct index
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageNumber = Int(targetContentOffset[0].x / view.frame.width)
        pageControl.currentPage = pageNumber
        
        if pageNumber == pages.count {
            moveConstrainsOffScreen()
        } else {
            pageBottomConstrain.constant = 12
            skipTopConstrain.constant = 0
            nextTopConstrain.constant = 0
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Action for skip button
    @IBAction func skip(_ sender: UIButton) {
        pageControl.currentPage = pages.count - 1
        next(sender)
    }
    
    // Animation for hiding skip, next and page control when the user scrolls to the last welcome page
    fileprivate func moveConstrainsOffScreen() {
        pageBottomConstrain.constant = -40
        skipTopConstrain.constant = -60
        nextTopConstrain.constant = -60
    }

    // Action for next button
    @IBAction func next(_ sender: UIButton) {
        if pageControl.currentPage == pages.count {
            return
        }
        
        if pageControl.currentPage == pages.count - 1 {
            moveConstrainsOffScreen()
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
        
        let indextPath = IndexPath(item: pageControl.currentPage + 1, section: 0)
        collectionView.scrollToItem(at: indextPath, at: .centeredHorizontally, animated: true)
        pageControl.currentPage += 1
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
        let indexPath = IndexPath(item: pageControl.currentPage, section: 0)
        
        DispatchQueue.main.async{
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.collectionView.reloadData()
        }
    }
    
    // Prepare the main page after welcome page
    func presentGalleryScreen() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let galleryVC = storyboard.instantiateViewController(withIdentifier: "galleryVC") as! SWRevealViewController
        present(galleryVC, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            self.presentGalleryScreen()
        }
    }
}



























