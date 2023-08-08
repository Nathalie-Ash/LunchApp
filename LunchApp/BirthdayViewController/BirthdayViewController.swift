//
//  BirthdayViewController.swift
//  LunchApp
//
//  Created by Nathalie on 02/08/2023.
//

import UIKit
import Firebase
import FirebaseStorage

class BirthdayViewController: UIViewController {
    
    @IBOutlet weak var birthdaysTableView: UITableView!

    let database = Firestore.firestore()
    let currentDate = Date()
    var birthdayData: [BirthdayData] = []
//
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "BirthdayTableViewCell", bundle: .main)
        self.birthdaysTableView.register(nib, forCellReuseIdentifier: "BirthdayTableViewCellId")
        fetchBirthdays()
    }
    
    func fetchBirthdays() {

         database.collection("users").addSnapshotListener {
            querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            
            // This dictionary contains the users information and the sections aka the months
            var userBirthdayDict : [SectionKey : [BirthdayUser]] = [ : ]
             
            // gets the upcoming 3 months
            let targetMonths = self.getTargetMonths()
             
             // query the users document
            for document in querySnapshot.documents {
                if let data = document.data() as? [String: Any],
                   //fetch users information
                   let userId = data["userId"] as? String,
                   let birthday = data["birthday"] as? String,
                   let name = data["name"] as? String,
                   let imageURL = data["profilePictureURL"] as? String,
                   let isPublic = data["isPublic"] as? Bool {
                   let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    if let date = dateFormatter.date(from: birthday) {
                        let calendar = Calendar.current
                        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                        // get the month component from the users birthdays
                        let month = dateComponents.month ?? 1
                        if (isPublic == true){
                            // if the months that were found are in the next upcoming 3 months
                            if targetMonths.contains(month) {
                                // set the key of the dictionary to that month
                                let key = SectionKey(month: month)
                                // set the values of the dictionary to the user information
                                let birthdayUser = BirthdayUser(userId: userId, name: name, birthday: date, imageURL: imageURL)
                                // if there are no birthdays leave it empty
                                if userBirthdayDict[key] == nil {
                                    userBirthdayDict[key] = []
                                }
                                //else append the users info to the dict
                                userBirthdayDict[key]?.append(birthdayUser)
                            }
                        }
                    
                    }
                }
                
            }
             // update the birthdayData array which contains all the inforamtion and sort the months in increasing order
             self.birthdayData = userBirthdayDict.map({ (key: SectionKey, value: [BirthdayUser]) in
                 BirthdayData(section: key, birthdays: value)
             }).sorted(by: { data1, data2 in
                 data1.section.month < data2.section.month
             })
             // reload the table view
             self.birthdaysTableView.reloadData()
         //   print("Dict: \(userBirthdayDict)")
        }
    }
    
    // function to get the current month and the upcoming 2 months to display
    func getTargetMonths() -> Set<Int> {
        let currentDate = Date()
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: currentDate)
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentDate)
        let secondNextMonth = calendar.date(byAdding: .month, value: 2, to: currentDate)
        return [
            currentMonth,
            calendar.component(. month, from: nextMonth ?? Date()),
            calendar.component(.month, from: secondNextMonth ?? Date())
        ]
    }
    
    // convert the month from integer to the month as a string
    func monthName(from month: Int) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        
        if let date = Calendar.current.date(from: DateComponents(year: 1950, month: month, day: 1)) {
            return dateFormatter.string(from: date)
        } else {
            return nil
        }
    }

}



extension BirthdayViewController: UITableViewDelegate, UITableViewDataSource {
    
    // the sections are equivalent to the months
    func numberOfSections(in tableView: UITableView) -> Int {
        birthdayData.count
    }
    
    // the rows are equal to the number of users whose birthdays are in this month
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.birthdayData[section].birthdays.count
        }
    
    //the title of each section is the month
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        monthName(from: birthdayData[section].section.month)
    }
    
    // fetch the data from the birthdayData array and place it in each cell accordingly
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BirthdayTableViewCellId", for: indexPath) as! BirthdayTableViewCell
        let data = birthdayData[indexPath.section].birthdays[indexPath.row]
        cell.nameLabel.text =  data.name
        cell.birthdayLabel.text = data.getBirthdayFormatted()
        
        let profilePictureURLString = data.imageURL
        let profilePictureURL = URL(string: profilePictureURLString)
        if let profilePictureURL = profilePictureURL {
            do {
                let storageReference = try Storage.storage().reference(for: profilePictureURL)
                storageReference.getData(maxSize: 10 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("Error fetching image data")
                        return
                    }
                    if let imageData = data, let image = UIImage(data: imageData) {
                        DispatchQueue.main.async {
                            cell.userProfileImageView.image = image
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
        return cell
    }
}

// thi struct contains the total birthday information and the table divisions
struct BirthdayData {
    
    let section: SectionKey
    let birthdays: [BirthdayUser]
    
}

struct BirthdayUser {
    
    let userId: String
    let name: String
    let birthday: Date
    let imageURL: String
    
    func getBirthdayFormatted() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        return dateFormatter.string(from: self.birthday)
    }
    
    
}

// the key of the dictionary will be the month
struct SectionKey: Equatable, Hashable {
      let month: Int
    
}
