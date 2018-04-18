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
    
    @IBOutlet weak var topVotedView: UIView!
    @IBOutlet weak var topVotedViewSongLabel: UILabel!
    @IBOutlet weak var topVotedViewEloNumberLabel: UILabel!
    
    @IBOutlet weak var bottomVotedView: UIView!
    @IBOutlet weak var bottomVotedViewSongLabel: UILabel!
    @IBOutlet weak var bottomVotedViewEloNumberLabel: UILabel!
    
    //MARK: IBActions
    @IBAction func nextButtonClicked(_ sender: Any) {
        generateNewSongPair()
        
        self.firstSongLabel.isHidden = false
        topVotedView.isHidden = true
        self.secondSongLabel.isHidden = false
        bottomVotedView.isHidden = true
        
    }
    
    //MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup intial next button
        nextButton.isEnabled = true
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
        sOne = 1.0
        sTwo = 0.0
        
        //Remove both gestures recognizers
        removeGestureRecognizers()
        
        //Update Firebase data with new elos, new wins, new losses
        fetchTwoSongs {
            let tuple = self.calculateNewElos(songRatingOne: self.firstSong.elo!, songRatingTwo: self.secondSong.elo!)
            self.firstSong.elo = tuple.newSongRatingOne
            self.firstSong.wins! += 1
            self.secondSong.elo = tuple.newSongRatingTwo
            self.secondSong.losses! += 1
            
            //Update UI after clicked
            self.firstSongLabel.isHidden = true
            self.topVotedView.isHidden = false
            self.topVotedViewSongLabel.text = self.firstSongName
            self.topVotedViewEloNumberLabel.text = "\(self.firstSong.elo!)"
            
            self.secondSongLabel.isHidden = true
            self.bottomVotedView.isHidden = false
            self.bottomVotedViewSongLabel.text = self.secondSongName
            self.bottomVotedViewEloNumberLabel.text = "\(self.secondSong.elo!)"
            
            print(self.firstSong.name!, self.firstSong.wins!, self.firstSong.losses!)
            print(self.secondSong.name!, self.secondSong.wins!, self.secondSong.losses!)
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
            self.firstSong.losses! += 1
            self.secondSong.elo = tuple.newSongRatingTwo
            self.secondSong.wins! += 1
            
            //Update UI after clicked
            self.firstSongLabel.isHidden = true
            self.topVotedView.isHidden = false
            self.topVotedViewSongLabel.text = self.firstSongName
            self.topVotedViewEloNumberLabel.text = "\(self.firstSong.elo!)"
            
            self.secondSongLabel.isHidden = true
            self.bottomVotedView.isHidden = false
            self.bottomVotedViewSongLabel.text = self.secondSongName
            self.bottomVotedViewEloNumberLabel.text = "\(self.secondSong.elo!)"
            
            print(self.firstSong.name!, self.firstSong.wins!, self.firstSong.losses!)
            print(self.secondSong.name!, self.secondSong.wins!, self.secondSong.losses!)
            
        }
    }
    
    //MARK: Functions
    func fetchSongs(completed: @escaping ()->()) {
        self.ref?.child("songs").observeSingleEvent(of: .value, with: { (snapshot) in
            
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
            //Cast Firebase data snapshot as dictionary
            if let firstSongDictionary = snapshot.value as? [String: AnyObject] {
                self.firstSong.name = firstSongDictionary["name"] as! String
                self.firstSong.elo = firstSongDictionary["elo"] as! Int
                self.firstSong.wins = firstSongDictionary["wins"] as! Int
                self.firstSong.losses = firstSongDictionary["losses"] as! Int
                
                //Fetch second song data
                self.ref?.child("songs").child(self.secondSongName).observeSingleEvent(of: .value, with: { (snapshot) in
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
        addGestureRecognizers()
    }
    
    func addGestureRecognizers() {
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
