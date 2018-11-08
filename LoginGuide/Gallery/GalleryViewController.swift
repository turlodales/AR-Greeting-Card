//
//  GalleryViewController.swift
//  LoginGuide
//
//  This file implements the GalleryViewController, it displays all the types and all built-in
//  cards' preview images.

import UIKit
import FirebaseAuth

class GalleryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // Data
    var originalColor = UIColor()
    var typesVector = ["Birthday","Anniversary","Holiday", "Friendship", "Received"]
    var typeIndex = 0
    var typeDetails = [3, 3, 3, 3, 0]
    var detailNumber = 3

    // UI properties
    @IBOutlet weak var menu: UIBarButtonItem!
    @IBOutlet weak var typesCollectionView: UICollectionView!
    @IBOutlet weak var typeDetailCollectionView: UICollectionView!
    
    // Provide number of item for collectionview
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let _ = collectionView as? TypesCollectionView{
            return typesVector.count
        } else {
            return detailNumber
        }
    }
    // Provide cell information for collectionview
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let _ = collectionView as? TypesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Types", for: indexPath) as! TypesCollectionViewCell
            cell.imageView.image = UIImage(named: "type" + indexPath.row.description)
            cell.imageView.clipsToBounds = true
            cell.imageView.layer.cornerRadius = cell.imageView.frame.size.height / 2
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TypeDetail", for: indexPath) as! TypeDetailCollectionViewCell
            cell.detailImageView.image = UIImage(named: "type" + typeIndex.description + "item" + indexPath.row.description + "number1")
            cell.detailImageView.image?.accessibilityIdentifier = "type" + typeIndex.description + "item" + indexPath.row.description
            return cell
        }
    }
    
    // Set action when user choose a specific item in the collectionview
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // User choose type
        if let _ = collectionView as? TypesCollectionView {
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
            if indexPath.row == typesVector.count - 1 {
                print("More will always be at the last")
            }
            //print(typesVector[indexPath.row])
            typeIndex = indexPath.row
            detailNumber = typeDetails[indexPath.row]
            DispatchQueue.main.async {
                self.typeDetailCollectionView.reloadData()
            }
        } else {
            //print("Type Detail: " + indexPath.row.description)
            if let cell = collectionView.cellForItem(at: indexPath) as? TypeDetailCollectionViewCell,
                let imageIdentifier = cell.detailImageView.image?.accessibilityIdentifier,
                let detailARVC = self.storyboard?.instantiateViewController(withIdentifier: "detailARVC") as? DetailARViewController {
                detailARVC.cover = (UIImage(named: imageIdentifier + "number1"), UIImage(named: imageIdentifier + "number2"))
                detailARVC.content = (UIImage(named: imageIdentifier + "number3"), UIImage(named: imageIdentifier + "number1"))
                //self.present(detailARVC, animated: true, completion: nil)
                self.present(detailARVC, animated: true, completion: {
                    detailARVC.updateCard()
                })
            }
        }
    }
    
    // Set action when deselect an item in the colleciton view
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let _ = collectionView as? TypesCollectionView {
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.backgroundColor = originalColor
        }
    }
    
    // Set basic constrains for UI when view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        originalColor = typesCollectionView.backgroundColor!
        self.navigationController?.navigationBar.shadowImage = UIImage()
        typesCollectionView.layer.shadowColor = UIColor.gray.cgColor
        typesCollectionView.layer.shadowOffset = CGSize(width: 0, height: 1)
        typesCollectionView.layer.shadowOpacity = 1
        typesCollectionView.layer.shadowRadius = 1.0
        typesCollectionView.clipsToBounds = false
        typesCollectionView.layer.masksToBounds = false
        typesCollectionView.allowsSelection = true
        if self.revealViewController() != nil {
            menu.target = self.revealViewController()
            menu.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let indexPath = IndexPath(item: 0, section: 0)
        typesCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.left)
        typesCollectionView.delegate?.collectionView!(typesCollectionView, didSelectItemAt: indexPath)
    }
    
    
}

