//
//  ChatsListViewController.swift
//  LunchApp
//
//  Created by Nathalie on 15/08/2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ChatsListViewController: UIViewController {

    @IBOutlet weak var chatsListTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("navigated to chats list")
        loadChats()
        }

    // chat is printinh the two users id who have the chat.
  //  use this to get user name and display
    
    func loadChats() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        Firestore.firestore().collection("Chats").whereField("users", arrayContains: currentUserId ?? "")
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching chats: \(error)")
                    return
                }
                
             //   self.chats.removeAll()
                for document in querySnapshot!.documents {
                     let chatData = document.data()
                        print(chatData)
                    
                }
           //     self.tableView.reloadData()
            }
    }

    
}





/*extension ChatsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatsListTableViewCellId", for: indexPath) as! chatsListTableViewCell
        return cell
    }
    
    
    // the sections are equivalent to the months
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // the rows are equal to the number of users whose birthdays are in this month
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        }
//
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "UITableViewHeaderFooterViewId")
//        headerView?.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
//        headerView?.textLabel?.text = monthName(from: birthdayData[section].section.month)
//        headerView?.contentView.backgroundColor = .white
//        headerView?.backgroundView?.backgroundColor = .white
//        headerView?.textLabel?.textColor = UIColor(red: 253.0/255.0, green: 136.0/255.0, blue: 71.0/255.0, alpha: 1.0)
//        return headerView
//    }
    

}*/

