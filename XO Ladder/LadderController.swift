//
//  ViewController.swift
//  XO Ladder
//
//  Created by Jason Park on 4/15/18.
//  Copyright © 2018 Jason Park. All rights reserved.
//

import UIKit
import Firebase

class LadderController: UIViewController {
    
    //MARK: Global Variables
    var ref: DatabaseReference?
    var songs = [Song]()

    override func viewDidLoad() {
        super.viewDidLoad()

        //Check if user is signed into Firebase
        if let uid = Auth.auth().currentUser?.uid {
            ref = Database.database().reference()
        }
        
        fetchSongs()
    }

    func fetchSongs() {
        ref?.child("songs").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let song = Song()
                
                song.name = dictionary["name"] as? String
                song.rating = dictionary["rating"] as? Int
                song.wins = dictionary["wins"] as? Int
                song.losses = dictionary["losses"] as? Int
                //print(song.name, song.rating, song.wins, song.losses)
                
                self.songs.append(song)
                
                DispatchQueue.main.async {
                    
                }
                
            }
        })
    }

}

