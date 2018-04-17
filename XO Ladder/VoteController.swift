//
//  VoteController.swift
//  XO Ladder
//
//  Created by Jason Park on 4/16/18.
//  Copyright © 2018 Jason Park. All rights reserved.
//

import UIKit
import Firebase

class VoteController: UIViewController {
    
    //MARK: Global Variables
    var ref: DatabaseReference?
    var songs = [Song]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Check if user is signed into Firebase
        if let uid = Auth.auth().currentUser?.uid {
            ref = Database.database().reference()
        }
        fetchData {
            self.generateNewSongPair()
        }
        
    }
    
    func fetchData(completed: @escaping ()->()) {
        self.ref?.child("songs").observe(.value, with: { (snapshot) in
            
            print(snapshot)
            
            //Cast Firebase data snapshot as dictionary
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                for (key, value) in dictionary {
                    let song = Song()
                    var ratio: String?
                    
                    
                    song.name = key as! String
                    song.elo = value["elo"] as! Int
                    song.wins = value["wins"] as! Int
                    song.losses = value ["losses"] as! Int
                    print(song.name!, song.elo!, song.wins!, song.losses!)
                    
                    //Append each song object to songs array
                    self.songs.append(song)
                    
                }
            }
            completed()
        })
    }
    
    func generateNewSongPair() {
        
        //Random two songs
        let firstSongName = self.songs.randomElement()!.name!
        var secondSongName: String
        
        
        print(songs)
        let filteredArrayWithoutFirstSong = songs.filter { $0.name != firstSongName }
        print(filteredArrayWithoutFirstSong)
        
        secondSongName = filteredArrayWithoutFirstSong.randomElement()!.name!
        
        print(firstSongName, secondSongName)
        
        

        
    }
    
}


extension Array {
    func randomElement() -> Element? {
        if isEmpty { return nil }
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
