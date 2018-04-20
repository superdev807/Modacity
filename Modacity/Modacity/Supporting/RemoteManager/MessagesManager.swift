//
//  MessagesManager.swift
//  Modacity
//
//  Created by BC Engineer on 20/4/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class MessagesManager: NSObject {
    
    static let manager = MessagesManager()
    
    func sendMessageToModacity(type: ModacityEmailType, body:String, includeAudio: Bool, completion: @escaping (String?)->()) {
        
        let timeString = Date().toString(format: "yyyyMMdd'T'HH:mm:ssZZZZ")
        
        var contactTypeString = "Want a boost"
        if type == .AskExpert {
            contactTypeString = "Want a boost"
        } else {
            contactTypeString = "Feedback"
        }
        
        if let me = MyProfileLocalManager.manager.me {
            if includeAudio {
                let fileURL = Recording.currentRecordingURL()
                Storage.storage().reference().child("messages").child(timeString).child(me.uid).putFile(from: fileURL, metadata: nil) { (metaData, error) in
                    if let error = error {
                        completion(error.localizedDescription)
                    } else {
                        if let downloadUrl = metaData?.downloadURL() {
                            Database.database().reference().child("messages").child(timeString).child(me.uid)
                                .setValue(["type":contactTypeString, "message":body, "uid":me.uid, "email":me.email, "included":downloadUrl.absoluteString]) { (error, _) in
                                    if let error = error {
                                        completion(error.localizedDescription)
                                    } else {
                                        completion(nil)
                                    }
                            }
                        } else {
                            completion("Included audio file is not available to upload.")
                        }
                    }
                }
            } else {
                Database.database().reference().child("messages").child(timeString).child(me.uid)
                    .setValue(["type":contactTypeString, "message":body, "uid":me.uid, "email":me.email]) { (error, _) in
                        if let error = error {
                            completion(error.localizedDescription)
                        } else {
                            completion(nil)
                        }
                }
            }
        }
    }
}
