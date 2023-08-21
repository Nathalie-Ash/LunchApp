
//
//  ChatViewController.swift
//  LunchApp
//
//  Created by Nathalie on 09/08/2023.
//


import InputBarAccessoryView
import FirebaseFirestore
import FirebaseAuth
import MessageKit
import SDWebImage

class ChatViewController: MessagesViewController,InputBarAccessoryViewDelegate, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    var currentUserId: String?
    var userName: String?
    private var docReference: DocumentReference?
    var messages: [Message] = []
    
    var secondUserId: String?
    var secondUserName: String?
    let database = Firestore.firestore()
    
    override func viewDidLoad() {
      
        super.viewDidLoad()
        setUpMessagesView()
        
        print("CURRENT USER ID: \(currentUserId)")
        getCurrentUserName(currentUserId ?? "Current user name not available") { userName in
            DispatchQueue.main.async {
                self.userName = userName
                // Now you can use the userName as needed
                print("Current User's name: \(userName)")
            }
        }

        print("Second User Id: \(secondUserId)")
        getCurrentUserName(secondUserId ?? "second user name not available") { userName in
            DispatchQueue.main.async {
                self.secondUserName = userName
                // Now you can use the userName as needed
                print("second User's name: \(userName)")
            }
        }
        loadChat()
        
        
    }
    
    func getCurrentUserName(_ userId: String, completion: @escaping (String) -> Void) {
        database.collection("users").whereField("userId", isEqualTo: userId).addSnapshotListener { querySnapshot, error in
            guard let querySnapshot = querySnapshot else {
                completion("User name not available")
                return
            }
            for document in querySnapshot.documents {
                if let data = document.data() as? [String: Any] {
                    if let userName = data["name"] as? String {
                        completion(userName)
                    } else {
                        completion("User name not available")
                    }
                } else {
                    completion("User name not available")
                }
            }
        }
    }
    
    func getUserProfileUrl(_ userId: String, completion: @escaping (String) -> Void) {
        database.collection("users").whereField("userId", isEqualTo: userId).addSnapshotListener { querySnapshot, error in
            guard let querySnapshot = querySnapshot else {
                completion("Profile not available")
                return
            }
            for document in querySnapshot.documents {
                if let data = document.data() as? [String: Any] {
                    if let profilePictureURL = data["profilePictureURL"] as? String {
                        completion(profilePictureURL)
                    } else {
                        completion("Profile not available")
                    }
                } else {
                    completion("Profile not available")
                }
            }
        }
    }

    func currentSender() -> SenderType {
        if let currentUserId = currentUserId {
            getCurrentUserName(currentUserId) { userName in
                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadData()
                }
            }
        }
        
        return ChatUser(senderId: currentUserId ?? "", displayName: self.userName ?? "User name not available")
    }

    
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    //Return the total number of messages
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        if messages.count == 0 {
            print("There are no messages")
            return 0
        } else {
            return messages.count
        }
    }
    
    
     private func loadChat() {
         // Fetch chat document for the users
         guard let currentUserId = currentUserId, let secondUserId = secondUserId else {
             return
         }
         
         database.collection("Chats").whereField("users", arrayContains: [currentUserId, secondUserId])
             .getDocuments { (querySnapshot, error) in
                 if let error = error {
                     print("Error fetching chat: \(error)")
                     return
                 }
                 
                 if let document = querySnapshot?.documents.first {
                     self.docReference = document.reference
                     self.loadMessages()
                 } else {
                     self.createNewChat()
                 }
             }
     }
     
    private func loadMessages() {
         guard let docReference = docReference else {
             return
         }
         
         docReference.collection("thread")
             .order(by: "created", descending: false)
             .addSnapshotListener { (querySnapshot, error) in
                 guard let querySnapshot = querySnapshot else {
                     print("Error fetching messages: \(error?.localizedDescription ?? "Unknown error")")
                     return
                 }
                 
                 self.messages.removeAll()
                 for messageDocument in querySnapshot.documents {
                     if let message = Message(dictionary: messageDocument.data()) {
                         self.messages.append(message)
                     }
                 }
                 self.messagesCollectionView.reloadData()
                 self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
             }
     }
     
     private func createNewChat() {
         guard let currentUserId = currentUserId, let secondUserId = secondUserId else {
             return
         }
         
         let users = [currentUserId, secondUserId]
         let data: [String: Any] = ["users": users]
         
         database.collection("Chats").addDocument(data: data) { (error) in
             if let error = error {
                 print("Error creating chat: \(error)")
                 return
             }
             
            // self.loadChat()
         }
     }
    
    private func insertNewMessage(_ message: Message) {
        //add the message to the messages array and reload it
        messages.append(message)
        messagesCollectionView.reloadData()
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
        }
    }
    private func save(_ message: Message) {
        //Preparing the data as per our firestore collection
        let data: [String: Any] = [
            "content": message.content,
            "created": message.created,
            "id": message.id,
            "senderID": message.senderID,
            "senderName": message.senderName
        ]
        //Writing it to the thread using the saved document reference we saved in load chat function
        docReference?.collection("thread").addDocument(data: data, completion: { (error) in
            if let error = error {
                print("Error Sending message: \(error)")
                return
            }
            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
        })
    }

    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        //When user presses the send button, this method is called.
        
        getCurrentUserName(currentUserId ?? "") { senderName in
            let message = Message(id: UUID().uuidString, content: text, created: Timestamp(), senderID: self.currentUserId ?? "Unavailable", senderName: senderName)
            
            // Calling function to insert and save message
            self.insertNewMessage(message)
            self.save(message)
            
            // Clearing input field
            inputBar.inputTextView.text = ""
            
            // Reload data and scroll to the last item
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
        }
    }

    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .blue: .lightGray
    }
  
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // Check if the message sender is the current user
        let isCurrentUser = message.sender.senderId == currentUserId
        
        // Get the user ID of the sender
        let senderId = (isCurrentUser ? currentUserId : (secondUserId ?? ""))!
        
        // Use the getUserProfileUrl function to fetch the profile picture URL
        getUserProfileUrl(senderId) { profilePictureURL in
            DispatchQueue.main.async {
                if let url = URL(string: profilePictureURL) {
                    SDWebImageManager.shared.loadImage(with: url, options: .highPriority, progress: nil) { (image, data, error, cacheType, isFinished, imageUrl) in
                        // Set the avatarView's image to the loaded image
                        avatarView.image = image
                    }
                }
            }
        }
    }

    //Styling the bubble to have a tail
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight: .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    func setUpMessagesView() {
        navigationItem.largeTitleDisplayMode = .never
        maintainPositionOnKeyboardFrameChanged = true
        scrollsToLastItemOnKeyboardBeginsEditing = true
        messageInputBar.inputTextView.tintColor = .systemBlue
        messageInputBar.sendButton.setTitleColor(.systemTeal, for: .normal)
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
}
