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
    var refresher: UIRefreshControl!

    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set Firebase reference
        ref = Database.database().reference()

        //Add refresh control
        refresher = UIRefreshControl()
        refresher.tintColor = .white
        refresher.attributedTitle = NSAttributedString(string: "Refreshing ladder...", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        refresher.addTarget(self, action: #selector(LadderController.fetchSongsSelector), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        //Delegates
        tableView.delegate = self
        tableView.dataSource = self
        
        //Fetch data & populate cells
        DispatchQueue.main.async {
            self.fetchSongs {
                self.tableView.reloadData()
            }
        }

    }

    @objc func fetchSongsSelector() {
        self.songs = []

        fetchSongs {
            self.refresher.endRefreshing()
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
                    song.elo = value["elo"] as! Int
                    song.wins = value["wins"] as! Int
                    song.losses = value["losses"] as! Int
                    
                    if song.losses! != 0 && song.wins! == 0 {
                        ratio = "0%"
                    }
                    
                    if song.losses! == 0 && song.wins! == 0{
                        ratio = "n/a"
                    }
                    
                    if song.losses! == 0 && song.wins! != 0 {
                        ratio = "100%"
                    }
                    
                    if song.losses! != 0 && song.wins! != 0 {
                        let ratioCalculation = (Double(song.wins!)/((Double(song.wins!)) + (Double(song.losses!))) * 100)
                        let roundedRatioCalculation = Int(round(ratioCalculation))
                        ratio = "\(roundedRatioCalculation)%"
                    }
                    
                    song.ratio = ratio
                    self.songs.append(song)
                    
                    DispatchQueue.main.async {
                        //Sort posts array by elo
                        self.songs.sort{ $0.elo! > $1.elo! }
                        //Reload table view cells
                        self.tableView.reloadData()
                    }
                }
                completed()
            }
        })
    }

    @objc func fetchSongs2() {
        ref?.child("songs").observe(.childAdded, with: { (snapshot) in
            
            //Cast Firebase data snapshot as dictionary
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let song = Song()
                var ratio: String?
                
                //Store each song's data into Song model
                song.name = dictionary["name"] as? String
                song.elo = dictionary["elo"] as? Int
                song.wins = dictionary["wins"] as? Int
                song.losses = dictionary["losses"] as? Int
                
                if song.losses! != 0 && song.wins! == 0 {
                    ratio = "0%"
                }
                
                if song.losses! == 0 && song.wins! == 0{
                    ratio = "n/a"
                }
                
                if song.losses! == 0 && song.wins! != 0 {
                    ratio = "100%"
                }
                    
                if song.losses! != 0 && song.wins! != 0 {
                    let ratioCalculation = (Double(song.wins!)/((Double(song.wins!)) + (Double(song.losses!))) * 100)
                    let roundedRatioCalculation = Int(round(ratioCalculation))
                    ratio = "\(roundedRatioCalculation)%"
                }
                
                song.ratio = ratio
                
                //Add each song to songs array
                self.songs.append(song)
                
                DispatchQueue.main.async {
                    //Sort posts array by elo
                    self.songs.sort{ $0.elo! > $1.elo! }
                    //Reload table view cells
                    self.tableView.reloadData()
                }
            }
        })
    }
    
}

extension LadderController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        let rankLabel = cell?.viewWithTag(-1) as? UILabel
        rankLabel?.text = "\(Int(indexPath.row) + 1)"
        
        let songLabel = cell?.viewWithTag(1) as? UILabel
        songLabel?.text = songs[indexPath.row].name
        
        let winLossLabel = cell?.viewWithTag(2) as? UILabel
        let winLossText = "\(songs[indexPath.row].wins ?? 0)/\(songs[indexPath.row].losses ?? 0)"
        winLossLabel?.text = winLossText
        
        let ratioLabel = cell?.viewWithTag(3) as? UILabel
        ratioLabel?.text = songs[indexPath.row].ratio
        
        let eloLabel = cell?.viewWithTag(4) as? UILabel
        eloLabel?.text = "\(songs[indexPath.row].elo ?? 0)"
        
        return cell!
    }
    
}


