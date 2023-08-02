//
//  BirthdayViewController.swift
//  LunchApp
//
//  Created by Nathalie on 02/08/2023.
//

import UIKit
import Firebase

class BirthdayViewController: UIViewController {
    
    @IBOutlet weak var firstMonthLabel: UILabel!
    @IBOutlet weak var secondMonthLabel: UILabel!
    @IBOutlet weak var thirdMonthLabel: UILabel!
    @IBOutlet weak var firstMonthTable: UITableView!
    @IBOutlet weak var secondMonthTable: UITableView!
    @IBOutlet weak var thirdMonthTable: UITableView!
    
    let database = Firestore.firestore()
    var birthdayMonth1 : [String] = []
    var birthdayMonth2 : [String] = []
    var birthdayMonth3 : [String] = []
    
    let currentDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        displayBirthdays()
        updateMonthLabel()
    }
    
    func displayBirthdays() {
       
    let calendar = Calendar.current
    let currentMonth = calendar.component(.month, from: currentDate)
    
    let usersCollection = database.collection("users")
        .addSnapshotListener { documentSnapshot, error in
        guard let documentSnapshot = documentSnapshot else {
            print("Error fetching document: \(error!)")
            return
        }
        
        self.birthdayMonth1 = []
        self.birthdayMonth2 = []
        self.birthdayMonth3 = []
            
        for document in documentSnapshot.documents {
            if let data = document.data() as? [String: Any],
                let birthday = data["birthday"] as? String, let name = data["name"] as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                    if let date = dateFormatter.date(from: birthday) {
                        dateFormatter.dateFormat = "MMMM d"
                        let birthdayAsMonth = dateFormatter.string(from: date)
                        let calendar = Calendar.current
                        let month = calendar.component(.month, from: date)
                        
                        if (month == currentMonth){
                            self.firstMonthLabel.text = self.monthName(from: currentMonth)
                                self.birthdayMonth1.append(birthdayAsMonth)
                                self.firstMonthTable.reloadData()
                            } else if (month == currentMonth+1){
                                self.secondMonthLabel.text = self.monthName(from: currentMonth+1)
                                self.birthdayMonth2.append(birthdayAsMonth)
                                self.secondMonthTable.reloadData()
                            } else if (month == currentMonth+2){
                               
                                self.thirdMonthLabel.text = self.monthName(from: currentMonth+2)
                                self.birthdayMonth3.append(birthdayAsMonth)
                                self.thirdMonthTable.reloadData()
                            }
                        } else {
                            print("Invalid date format: \(birthday)")
                        }

                    }
                }
        }
    }
    
    func updateMonthLabel() {
        let calendar = Calendar.current
        var currentMonth = calendar.component(.month, from: currentDate)
        
        self.firstMonthLabel.text = self.monthName(from: currentMonth)
        self.secondMonthLabel.text = self.monthName(from: currentMonth+1)
        self.thirdMonthLabel.text = self.monthName(from: currentMonth+2)
        if (currentMonth == 12){
            currentMonth = 1
        }
    }
    
    
    func monthName(from month: Int) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM" // Use "MMMM" to get the full month name
        
        if let date = Calendar.current.date(from: DateComponents(year: 1950, month: month, day: 1)) {
            return dateFormatter.string(from: date)
        } else {
            return nil
        }
    }
    
    
    

}



extension BirthdayViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == firstMonthTable {
            return birthdayMonth1.count
        }
        else if tableView == secondMonthTable {
            return birthdayMonth2.count
        } else if tableView == thirdMonthTable {
            return birthdayMonth3.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == firstMonthTable {
            let element = self.birthdayMonth1[indexPath.row]
            let cell = UITableViewCell()
            cell.textLabel?.text = element
            cell.textLabel?.textColor = .black
            cell.selectionStyle = .none
            return cell
            
        } else if tableView == secondMonthTable {
            let element = self.birthdayMonth2[indexPath.row]
            let cell = UITableViewCell()
            cell.textLabel?.text = element
            cell.textLabel?.textColor = .black
            cell.selectionStyle = .none
            return cell
        } else if tableView == thirdMonthTable {
            let element = self.birthdayMonth3[indexPath.row]
            let cell = UITableViewCell()
            cell.textLabel?.text = element
            cell.textLabel?.textColor = .black
            cell.selectionStyle = .none
            return cell
        }
        
        return UITableViewCell()
    }
}
