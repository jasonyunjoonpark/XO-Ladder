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
    var firstSong = Song()
    var secondSong = Song()
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
    // 2687, newSongRatingTwo: 1917
    // 2703, newSongRatingTwo: 1917)
    
    //Morning 1918 (top) vs High For This  2703 (bot) ->
    //         1949                        2687
    
    //The Morning 1918
    //High For This 2703
    //(newSongRatingOne: 1917, newSongRatingTwo: 2703)
    
    
    //MARK: Obj-C Handlers
    @objc func topViewClicked() {
        print("Top clicked!")
        sOne = 1.0
        sTwo = 0.0
        
        //Remove both gestures recognizers
        removeGestureRecognizers()
        
        //Update Firebase data with new elos, new wins, new losses
        fetchTwoSongs {
            print(self.firstSong.name!, self.firstSong.elo!)
            print(self.secondSong.name!, self.secondSong.elo!)
            let tuple = self.calculateNewElos(songRatingOne: self.firstSong.elo!, songRatingTwo: self.secondSong.elo!)
            self.firstSong.elo = tuple.newSongRatingOne
            self.secondSong.elo = tuple.newSongRatingTwo
        }
        
    }
    
    @objc func bottomViewClicked() {
        print("Bottom clicked!")
        sOne = 0.0
        sTwo = 1.0
        
        //Remove both gestures recognizers
        removeGestureRecognizers()
        
        //Update Firebase data with new elos, new wins, new losses
        fetchTwoSongs {
            print(self.firstSong.name!, self.firstSong.elo!)
            print(self.secondSong.name!, self.secondSong.elo!)
            let tuple = self.calculateNewElos(songRatingOne: self.firstSong.elo!, songRatingTwo: self.secondSong.elo!)
            self.firstSong.elo = tuple.newSongRatingOne
            self.secondSong.elo = tuple.newSongRatingTwo
        }
    }
    
    //MARK: Functions
    func fetchSongs(completed: @escaping ()->()) {
        self.ref?.child("songs").observeSingleEvent(of: .value, with: { (snapshot) in
            
            print(snapshot)
            
            //Cast Firebase data snapshot as dictionary
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                for (key, value) in dictionary {
                    let song = Song()
                    var ratio: String?
                    
                    song.name = key as! String
                    
                    self.songs.append(song)
                }
            }
            completed()
        })
    }
    
    func fetchTwoSongs(completed: @escaping ()->()) {
        //Fetch first song data
        self.ref?.child("songs").child(firstSongName).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            //Cast Firebase data snapshot as dictionary
            if let firstSongDictionary = snapshot.value as? [String: AnyObject] {
                self.firstSong.name = firstSongDictionary["name"] as! String
                self.firstSong.elo = firstSongDictionary["elo"] as! Int
                self.firstSong.wins = firstSongDictionary["wins"] as! Int
                self.firstSong.losses = firstSongDictionary["losses"] as! Int
                
                //Fetch second song data
                self.ref?.child("songs").child(self.secondSongName).observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot)
                    //Cast Firebase data snapshot as dictionary
                    if let secondSongDictionary = snapshot.value as? [String: AnyObject] {
                        self.secondSong.name = secondSongDictionary["name"] as! String
                        self.secondSong.elo = secondSongDictionary["elo"] as! Int
                        self.secondSong.wins = secondSongDictionary["wins"] as! Int
                        self.secondSong.losses = secondSongDictionary["losses"] as! Int
                    }
                    completed()
                })
            }
            
        })

    }
    
    func generateNewSongPair() {
        //Random first song
        firstSongName = self.songs.randomElement()!.name!
        
        //Random second song that isn't the same as first song
        let filteredArrayWithoutFirstSong = songs.filter { $0.name != firstSongName }
        secondSongName = filteredArrayWithoutFirstSong.randomElement()!.name!
        
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
