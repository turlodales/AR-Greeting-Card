//
//  CalenderViewController.swift
//  LoginGuide
//
//  This file implements the CalenderViewController, which is used to set a notification event.

import UIKit
import UserNotifications
import FirebaseDatabase
import FirebaseAuth

class CalenderViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    // UI properties
    @IBOutlet weak var darkBackView: UIView!
    @IBOutlet weak var frontView: UIView!
    @IBOutlet weak var calenderTable: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var addOrEditButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel! {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            dateLabel.text = dateFormatter.string(from: Date())
        }
    }
    @IBOutlet weak var eventTextField: UITextField!
    @IBOutlet weak var datePiscker: UIDatePicker!
    @IBOutlet weak var menu: UIBarButtonItem!
    @IBOutlet weak var dimView: UIView!
    
    // Data
    var ref: DatabaseReference?
    var calenderItems: [CalenderItem] = []
    var editingItemIndex: IndexPath?
    let center = UNUserNotificationCenter.current()
    
    // Provide number of row for tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calenderItems.count
    }

    // Provide cell information for given location of tableview
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "calenderCell", for: indexPath)
        cell.textLabel?.text = calenderItems[indexPath.row].title
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        cell.detailTextLabel?.text = dateFormatter.string(from: (calenderItems[indexPath.row].date))
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

        }
    }
    
    // Edit action for certain row of tableview
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "edit") { (action, indexPath) in
            self.addOrEditButton.setTitle("Edit", for: .normal)
            self.eventTextField.text = self.calenderItems[indexPath.row].title
            self.dateLabel.text = self.calenderItems[indexPath.row].getString()
            self.datePiscker.date = self.calenderItems[indexPath.row].date
            self.editingItemIndex = indexPath
            if self.darkBackView.transform == .identity {
                UIView.animate(withDuration: 0.65, animations: {
                    self.dimView.alpha = 0.75
                    self.darkBackView.transform = CGAffineTransform(translationX: 0, y: 667)
                }, completion: { (true) in
                    
                })
            } else {
                UIView.animate(withDuration: 0.65, animations: {
                    self.dimView.alpha = 0
                    self.darkBackView.transform = .identity
                }, completion: { (true) in
                    
                })
            }
        }
        
        let delete = UITableViewRowAction(style: .destructive, title: "delete") { (action, indexPath) in
            if let userID = Auth.auth().currentUser?.uid {
                self.ref?.child("Users").child(userID).child("Calenders").child(self.calenderItems[indexPath.row].fireBaseID).removeValue()
                self.center.removePendingNotificationRequests(withIdentifiers: [self.calenderItems[indexPath.row].fireBaseID])
                self.calenderItems.remove(at: indexPath.row)
                self.calenderTable.deleteRows(at: [indexPath], with: .right)
            }
        }
        return [edit, delete]
    }
    
    // Handle action when user tapped add button
    @IBAction func addTapped(_ sender: UIButton) {
        self.addOrEditButton.setTitle("Add", for: .normal)
        if darkBackView.transform == CGAffineTransform.identity {
            UIView.animate(withDuration: 0.65, animations: {
                self.dimView.alpha = 0.75
                self.darkBackView.transform = CGAffineTransform(translationX: 0, y: 667)
                self.addButton.transform = CGAffineTransform(rotationAngle: self.radian(90))
            }, completion: { (true) in
                
            })
        } else {
            UIView.animate(withDuration: 0.65, animations: {
                self.dimView.alpha = 0
                self.darkBackView.transform = .identity
                self.addButton.transform = .identity
                self.view.endEditing(true)
            }, completion: { (true) in
                
            })
        }
    }
    
    // transform helper function
    func radian(_ degree: Double) -> CGFloat {
        return CGFloat(degree * .pi / 180)
    }
    
    // Set basic constrains and login safety guard
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        DispatchQueue.global(qos: .userInteractive).async {
            self.getCalenderFromFirebase()
        }
        if self.revealViewController() != nil {
            menu.target = self.revealViewController()
            menu.action = #selector(SWRevealViewController.revealToggle(_:))
            
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            let swipeUp = UISwipeGestureRecognizer()
            swipeUp.direction = .up
            swipeUp.addTarget(self, action: #selector(CalenderViewController.closeAddView))
            darkBackView.addGestureRecognizer(swipeUp)
        }
    }
    
    // Handle action when user select a date at the datapicker
    @IBAction func selectedDate(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateLabel.text = dateFormatter.string(from: datePiscker.date)
    }
    
    // Handle action when user tapped add
    @IBAction func addAnEvent(_ sender: UIButton) {
        if sender.titleLabel?.text == "Add" {
            if eventTextField.hasText, Date() < datePiscker.date {
                let fbID = ref?.childByAutoId()
                let calenderItem = CalenderItem(title: eventTextField.text!, date: datePiscker.date, fireBaseID: (fbID?.key)!)
                updateAddedCalenderToFirebase(calenderItem)
                self.schduleNotification(from: calenderItem)
                calenderItems.append(calenderItem)
                calenderItems.sort(by: {$0.date < $1.date})
                UIView.animate(withDuration: 0.65, animations: {
                    self.dimView.alpha = 0
                    self.darkBackView.transform = .identity
                    self.addButton.transform = .identity
                }, completion: { (true) in
                    let indexPath = IndexPath(row: (self.calenderItems.index(where: {$0.equal(calenderItem)})!), section: 0)
                    self.calenderTable.insertRows(at: [indexPath], with: .right)
                })
            } else {
                if eventTextField.hasText == false {
                    shake(eventTextField)
                }
                if Date() > datePiscker.date {
                    shake(dateLabel)
                }
            }
        }
    }
    
    // Handle action when user edit an item
    @IBAction func editAnEvent(_ sender: UIButton) {
        if sender.titleLabel?.text == "Edit", let indexPath = self.editingItemIndex {
            if eventTextField.hasText, Date() < datePiscker.date {
                let newEvent = CalenderItem(title: eventTextField.text!, date: datePiscker.date, fireBaseID: self.calenderItems[indexPath.row].fireBaseID)
                if !calenderItems[indexPath.row].equal(newEvent) {
                    updateAddedCalenderToFirebase(newEvent)
                    schduleNotification(from: newEvent)
                    UIView.animate(withDuration: 0.65, animations: {
                        self.dimView.alpha = 0
                        self.darkBackView.transform = CGAffineTransform(translationX: 0, y: -667)
                    }, completion: { (true) in
                        self.calenderItems.remove(at: indexPath.row)
                        self.calenderTable.deleteRows(at: [indexPath], with: .right)
                        self.calenderItems.append(newEvent)
                        self.calenderItems.sort(by: {$0.date < $1.date})
                        let insertIndexPath = IndexPath(row: self.calenderItems.index(where: {$0.equal(newEvent)})!, section: 0)
                        self.calenderTable.insertRows(at: [insertIndexPath], with: .right)
                    })
                } else {
                    UIView.animate(withDuration: 0.65, animations: {
                        self.darkBackView.transform = CGAffineTransform(translationX: 0, y: -667)
                    })
                }
            } else {
                if eventTextField.hasText == false {
                    shake(eventTextField)
                }
                if Date() > datePiscker.date {
                    shake(dateLabel)
                }
            }
        }
    }
    
    // Make the keyboard goes away when user touch other place
    @IBAction func hideKeyboard(_ sender: UIButton) {
        self.view.endEditing(true)
    }
    
    func shake(_ view: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.1
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 10, y: view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 10, y: view.center.y))
        view.layer.add(animation, forKey: "position")
    }
    
    @objc func closeAddView() {
        UIView.animate(withDuration: 0.65, animations: {
            self.dimView.alpha = 0
            self.darkBackView.transform = .identity
            self.addButton.transform = .identity
            self.view.endEditing(true)
        }) { (true) in
            
        }
    }
    
    // Update new calender information to firebase
    func updateAddedCalenderToFirebase(_ calenderItem: CalenderItem) {
        if let userID = Auth.auth().currentUser?.uid {
            ref?.child("Users").child(userID).child("Calenders").child(calenderItem.fireBaseID).setValue(["title" : calenderItem.title, "date" : calenderItem.getString()])
        }
    }
    
    // Download stored calender from firebase
    func getCalenderFromFirebase() {
        let userID = Auth.auth().currentUser?.uid
        ref?.child("Users").child(userID!).child("Calenders").observeSingleEvent(of: .value, with: { (snapshot) in
            if let calenders = snapshot.value as? NSDictionary {
                for (id, calender) in (calenders) {
                    if let item = calender as? Dictionary<String, String>, let idString = id as? String {
                        self.calenderItems.append(CalenderItem(title: item["title"]!, date: item["date"]!, fireBaseID: idString))
                    }
                }
                DispatchQueue.main.async {
                    self.calenderItems.sort(by: {$0.date < $1.date})
                    self.calenderTable.reloadData()
                }
            }
            })
    }
    
    // Start download from firebase
    func backgroundFetch(_ completion: () -> Void) {
        getCalenderFromFirebase()
        let currentDate = Date()
        print(currentDate)
        if let smallest = self.calenderItems.first, currentDate == smallest.date {
            completion()
        }
    }
    
    // Set notification for added calender
    func createNotification(from calenderItem: CalenderItem) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = calenderItem.title
        content.body = "Send an AR E-Card!"
        content.sound = UNNotificationSound.default()
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: calenderItem.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: calenderItem.fireBaseID, content: content, trigger: trigger)
        return request
    }
    
    // Schedule notification in the notification center
    func schduleNotification(from calenderItem: CalenderItem) {
        let request = createNotification(from: calenderItem)
        center.add(request) { (error) in
            print("no error now")
            if let err = error {
                print(err.localizedDescription)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

// Extension class for enabing foreground notification
class ForegroundNotificationDelegete : NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}








