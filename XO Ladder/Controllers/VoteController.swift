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
    var firstSongName = ""
    var secondSongName = ""
    var sOne: Double = 0.0
    var sTwo: Double = 0.0
    
    //MARK: Outlets
    @IBOutlet weak var firstSongLabel: UILabel!
    @IBOutlet weak var secondSongLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    
    //MARK: IBActions
    @IBAction func nextButtonClicked(_ sender: Any) {
        generateNewSongPair()

    }
    
    //MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup intial next button
        nextButton.isEnabled = false
        nextButton.titleLabel?.text = "Or"
        
        //Check if user is signed into Firebase
        if let uid = Auth.auth().currentUser?.uid {
            ref = Database.database().reference()
        }
        
        //Fetch songs & generate new song pair
        fetchSongs {
            self.generateNewSongPair()
        }
        
    }
    
    //MARK: Obj-C Handlers
    @objc func topViewClicked() {
        print("Top clicked!")
        
        //Remove both gestures recognizers
        removeGestureRecognizers()
        
        //Update Firebase data with new elos, new wins, new losses
        self.ref?.child("songs").child(firstSongName).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            
            //Cast Firebase data snapshot as dictionary
            if let firstSongDictionary = snapshot.value as? [String: AnyObject] {
                
                let firstSong = Song()
                
                firstSong.name = firstSongDictionary["name"] as! String
                firstSong.elo = firstSongDictionary["elo"] as! Int
                firstSong.wins = firstSongDictionary["wins"] as! Int
                firstSong.losses = firstSongDictionary["losses"] as! Int
                
                print(firstSong.name!, firstSong.elo!, firstSong.wins!, firstSong.losses!)

            }
        })
        
    }
    
    @objc func bottomViewClicked() {
        print("Bottom clicked!")
        
        //Remove both gestures recognizers
        removeGestureRecognizers()
        
    }
    
    //MARK: Functions
    func fetchSongs(completed: @escaping ()->()) {
        self.ref?.child("songs").observe(.value, with: { (snapshot) in
            
            print(snapshot)
            
            //Cast Firebase data snapshot as dictionary
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                for (key, value) in dictionary {
                    let song = Song()
                    var ratio: String?
                    
                    song.name = key as! String
                    //song.elo = value["elo"] as! Int
                    //song.wins = value["wins"] as! Int
                    //song.losses = value ["losses"] as! Int
                    //print(song.name!, song.elo!, song.wins!, song.losses!)
                    
                    //Append each song object to songs array
                    self.songs.append(song)
                }
            }
            completed()
        })
    }
    
    func generateNewSongPair() {
        //Random first song
        firstSongName = self.songs.randomElement()!.name!
        
        //Random second song that isn't the same as first song
        let filteredArrayWithoutFirstSong = songs.filter { $0.name != firstSongName }
        secondSongName = filteredArrayWithoutFirstSong.randomElement()!.name!
        
        print(filteredArrayWithoutFirstSong)
        print(firstSongName, secondSongName)
        
        //Update UI
        firstSongLabel.text = firstSongName
        secondSongLabel.text = secondSongName
        
        //Add tap gesture for uiviews
        let topViewGesture = UITapGestureRecognizer(target: self, action:  #selector(topViewClicked))
        let bottomViewGesture = UITapGestureRecognizer(target: self, action: #selector(bottomViewClicked))
        self.topView.addGestureRecognizer(topViewGesture)
        self.bottomView.addGestureRecognizer(bottomViewGesture)
        
        
    }
    
    func removeGestureRecognizers() {
        for gesture in topView.gestureRecognizers! {
            self.topView.removeGestureRecognizer(gesture)
        }
        for gesture in bottomView.gestureRecognizers! {
            self.bottomView.removeGestureRecognizer(gesture)
        }
    }
    
    
    
}


extension Array {
    func randomElement() -> Element? {
        if isEmpty { return nil }
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
