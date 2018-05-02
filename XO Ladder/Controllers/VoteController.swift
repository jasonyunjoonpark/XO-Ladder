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
    @IBOutlet weak var nextButtonDisabledView: UIView!
    
    @IBOutlet weak var topVotedView: UIView!
    @IBOutlet weak var topVotedViewSongLabel: UILabel!
    @IBOutlet weak var topVotedViewEloNumberLabel: CountingLabel!
    @IBOutlet weak var topVotedEloGainLabel: CountingLabel!
    @IBOutlet weak var topVotedGainLossTextLabel: UILabel!
    @IBOutlet weak var topVotedWinLossLabel: UILabel!
    @IBOutlet weak var topVotedCheck: UILabel!
    
    @IBOutlet weak var bottomVotedView: UIView!
    @IBOutlet weak var bottomVotedViewSongLabel: UILabel!
    @IBOutlet weak var bottomVotedEloGainLabel: CountingLabel!
    @IBOutlet weak var bottomVotedViewEloNumberLabel: CountingLabel!
    @IBOutlet weak var bottomVotedGainLossTextLabel: UILabel!
    @IBOutlet weak var bottomVotedWinLossLabel: UILabel!
    @IBOutlet weak var bottomVotedCheck: UILabel!
    
    //MARK: IBActions
    @IBAction func nextButtonClicked(_ sender: Any) {
        
        generateNewSongPair()
        
        //Update top & bottom views UI
        self.firstSongLabel.isHidden = false
        topVotedView.isHidden = true
        self.secondSongLabel.isHidden = false
        bottomVotedView.isHidden = true
        
        //Update next button UI
        self.nextButtonDisabledView.isHidden = false
        self.nextButton.isHidden = true
        
    }
    
    //MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup intial next button
        nextButton.isHidden = true
        
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
            
            //Calculate and update both song objects after top clicked
            self.calculateAndUpdateBothSongObjectsAfterTopClicked {
                
                //Update both songs' data in Firebase
                self.updateBothSongsDataOnFirebase {
                    //Update Top & Bottom Views UI after clicked
                    
                    //Top voted view update UI
                    self.firstSongLabel.isHidden = true
                    self.topVotedView.isHidden = false
                    self.topVotedViewSongLabel.text = self.firstSongName
                    
                    self.topVotedWinLossLabel.text = "\(self.firstSong.wins!) / \(self.firstSong.losses!)"

                    self.topVotedCheck.isHidden = false
                    self.topVotedCheck.textColor = UIColor(displayP3Red: 0/255, green: 175/255, blue: 1/255, alpha: 1)
                    self.topVotedGainLossTextLabel.text = "Gain"
                    self.topVotedEloGainLabel.text = "0"
                    self.topVotedEloGainLabel.textColor = UIColor(displayP3Red: 0/255, green: 175/255, blue: 1/255, alpha: 1)
                    self.topVotedEloGainLabel.count(fromValue: Float(0), to: Float((abs(self.firstSong.elo! - self.firstSong.intialElo!))), withDuration: 1, andAnimationType: .EaseOut, andCounterType: .Int)
                    
                    self.topVotedViewEloNumberLabel.textColor = UIColor(displayP3Red: 0/255, green: 175/255, blue: 1/255, alpha: 1)
                    self.topVotedViewEloNumberLabel.count(fromValue: Float(self.firstSong.intialElo!), to: Float(self.firstSong.elo!), withDuration: 2, andAnimationType: .EaseOut, andCounterType: .Int)
                    
                    //Bottom voted voted view update UI
                    self.secondSongLabel.isHidden = true
                    self.bottomVotedView.isHidden = false
                    self.bottomVotedViewSongLabel.text = self.secondSongName
                    
                    self.bottomVotedWinLossLabel.text = "\(self.secondSong.wins!)/\(self.secondSong.losses!)"
                    
                    self.bottomVotedCheck.isHidden = true
                    self.bottomVotedGainLossTextLabel.text = "Loss"
                    self.bottomVotedEloGainLabel.text = "0"
                    self.bottomVotedEloGainLabel.textColor = UIColor(displayP3Red: 255/255, green: 38/255, blue: 0/255, alpha: 1)
                    self.bottomVotedEloGainLabel.count(fromValue: Float(0), to: Float((abs(self.secondSong.elo! - self.secondSong.intialElo!))), withDuration: 1, andAnimationType: .EaseOut, andCounterType: .Int)
                    
                    self.bottomVotedViewEloNumberLabel.textColor = UIColor(displayP3Red: 255/255, green: 38/255, blue: 0/255, alpha: 1)
                    self.bottomVotedViewEloNumberLabel.count(fromValue: Float(self.secondSong.intialElo!), to: Float(self.secondSong.elo!), withDuration: 2, andAnimationType: .EaseOut, andCounterType: .Int)
                    
                    
                    //Update Next Button UI
                    self.nextButton.isHidden = false
                    self.nextButtonDisabledView.isHidden = true
                }

            }
            
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
            
            //Calculate and update both song objects after bottom clicked
            self.calculateAndUpdateBothSongObjectsAfterBottomClicked {
                
                //Update both songs' data in Firebase
                self.updateBothSongsDataOnFirebase {
                    //Update UI after clicked
                    
                    //Top voted view update UI
                    self.firstSongLabel.isHidden = true
                    self.topVotedView.isHidden = false
                    self.topVotedViewSongLabel.text = self.firstSongName
                    
                    self.topVotedWinLossLabel.text = "\(self.firstSong.wins!)/\(self.firstSong.losses!)"
                    
                    self.topVotedCheck.isHidden = true
                    self.topVotedGainLossTextLabel.text = "Loss"
                    self.topVotedEloGainLabel.text = "0"
                    self.topVotedEloGainLabel.textColor = UIColor(displayP3Red: 255/255, green: 38/255, blue: 0/255, alpha: 1)
                    self.topVotedEloGainLabel.count(fromValue: Float(0), to: Float((abs(self.firstSong.elo! - self.firstSong.intialElo!))), withDuration: 1, andAnimationType: .EaseOut, andCounterType: .Int)
                    
                    self.topVotedViewEloNumberLabel.textColor = UIColor(displayP3Red: 255/255, green: 38/255, blue: 0/255, alpha: 1)
                    self.topVotedViewEloNumberLabel.count(fromValue: Float(self.firstSong.intialElo!), to: Float(self.firstSong.elo!), withDuration: 2, andAnimationType: .EaseOut, andCounterType: .Int)
                    
                    
                    
                    //Bottom voted voted view update UI
                    self.secondSongLabel.isHidden = true
                    self.bottomVotedView.isHidden = false
                    self.bottomVotedViewSongLabel.text = self.secondSongName
                    
                    self.bottomVotedWinLossLabel.text = "\(self.secondSong.wins!)/\(self.secondSong.losses!)"
                    
                    self.bottomVotedCheck.isHidden = false
                    self.bottomVotedCheck.textColor = UIColor(displayP3Red: 0/255, green: 175/255, blue: 1/255, alpha: 1)
                    self.bottomVotedGainLossTextLabel.text = "Gain"
                    self.bottomVotedEloGainLabel.text = "0"
                    self.bottomVotedEloGainLabel.textColor = UIColor(displayP3Red: 0/255, green: 175/255, blue: 1/255, alpha: 1)
                    self.bottomVotedEloGainLabel.count(fromValue: Float(0), to: Float((abs(self.secondSong.elo! - self.secondSong.intialElo!))), withDuration: 1, andAnimationType: .EaseOut, andCounterType: .Int)
                    
                    self.bottomVotedViewEloNumberLabel.textColor = UIColor(displayP3Red: 0/255, green: 175/255, blue: 1/255, alpha: 1)
                    self.bottomVotedViewEloNumberLabel.count(fromValue: Float(self.secondSong.intialElo!), to: Float(self.secondSong.elo!), withDuration: 2, andAnimationType: .EaseOut, andCounterType: .Int)
                    
                    //Update Next Button UI
                    self.nextButton.isHidden = false
                    self.nextButtonDisabledView.isHidden = true
                }
            }
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
                self.firstSong.intialElo = firstSongDictionary["elo"] as! Int
                self.firstSong.elo = firstSongDictionary["elo"] as! Int
                self.firstSong.wins = firstSongDictionary["wins"] as! Int
                self.firstSong.losses = firstSongDictionary["losses"] as! Int
                
                //Fetch second song data
                self.ref?.child("songs").child(self.secondSongName).observeSingleEvent(of: .value, with: { (snapshot) in
                    //Cast Firebase data snapshot as dictionary
                    if let secondSongDictionary = snapshot.value as? [String: AnyObject] {
                        self.secondSong.name = secondSongDictionary["name"] as! String
                        self.secondSong.intialElo = secondSongDictionary["elo"] as! Int
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
    
    func calculateAndUpdateBothSongObjectsAfterTopClicked(completed: @escaping ()->()) {
        let tuple = self.calculateNewElos(songRatingOne: self.firstSong.elo!, songRatingTwo: self.secondSong.elo!)
        self.firstSong.elo = tuple.newSongRatingOne
        self.firstSong.wins! += 1
        self.secondSong.elo = tuple.newSongRatingTwo
        self.secondSong.losses! += 1
        
        DispatchQueue.main.async {
            completed()
        }
    }
    
    func calculateAndUpdateBothSongObjectsAfterBottomClicked(completed: @escaping ()->()) {
        let tuple = self.calculateNewElos(songRatingOne: self.firstSong.elo!, songRatingTwo: self.secondSong.elo!)
        self.firstSong.elo = tuple.newSongRatingOne
        self.firstSong.losses! += 1
        self.secondSong.elo = tuple.newSongRatingTwo
        self.secondSong.wins! += 1
        
        DispatchQueue.main.async {
            completed()
        }
    }
    
    func updateBothSongsDataOnFirebase(completed: @escaping ()-> ()) {
        self.ref?.child("songs").child(self.firstSongName).updateChildValues(["elo": self.firstSong.elo!,
                                                                              "wins": self.firstSong.wins!,
                                                                              "losses": self.firstSong.losses!])
        self.ref?.child("songs").child(self.secondSongName).updateChildValues(["elo": self.secondSong.elo!,
                                                                               "wins": self.secondSong.wins!,
                                                                               "losses": self.secondSong.losses!])
        
        DispatchQueue.main.async {
            completed()
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
