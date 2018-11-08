//
//  GalleryTableViewController.swift
//  LoginGuide
//
//  

import UIKit
import FirebaseAuth

class GalleryTableViewController: UITableViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Types
    var typesVector = ["Faverite", "Recieved", "Birthday","Anniversary","Holiday", "more"]
    
    // UI properties
    @IBOutlet weak var menu: UIBarButtonItem!
    @IBOutlet weak var typesCollectionView: UICollectionView!
    
    // Set basic constrains for UI
    override func viewDidLoad() {
        super.viewDidLoad()
        typesCollectionView.layer.shadowColor = UIColor.gray.cgColor
        typesCollectionView.layer.shadowOffset = CGSize(width: 0, height: 1)
        typesCollectionView.layer.shadowOpacity = 1
        typesCollectionView.layer.shadowRadius = 1.0
        typesCollectionView.clipsToBounds = false
        typesCollectionView.layer.masksToBounds = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        if self.revealViewController() != nil {
            menu.target = self.revealViewController()
            menu.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return typesVector.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Types", for: indexPath) as! TypesCollectionViewCell
        //cell.typeButton.titleLabel?.text = typesVector[indexPath.row]
        return cell
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

}
