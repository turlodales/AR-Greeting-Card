//
//  CalenderItems.swift
//  LoginGuide
//
//  This file implements CalenderItem, which is the model of CalenderViewController.
//  It contains the data of each event.

import Foundation

class CalenderItem {
    // data contained in calender item
    var title: String
    var date: Date
    var fireBaseID: String
    
    // constructor
    init(title: String, date: Date, fireBaseID: String) {
        self.title = title
        self.date = date
        self.fireBaseID = fireBaseID
    }
    // constructor
    init(title: String, date: String, fireBaseID: String) {
        self.title = title
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        self.date = dateFormatter.date(from: date)!
        self.fireBaseID = fireBaseID
    }
    
    // Comparison function
    func equal(_ calenderItem: CalenderItem) -> Bool {
        if calenderItem.title == self.title, calenderItem.date == self.date, calenderItem.fireBaseID == self.fireBaseID {
            return true
        }
        return false
    }
    
    // Get string out of the date format of the calender item
    func getString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: self.date)
    }
}
