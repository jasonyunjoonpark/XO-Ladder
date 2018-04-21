//
//  VoteController+EloManager.swift
//  XO Ladder
//
//  Created by Jason Park on 4/17/18.
//  Copyright © 2018 Jason Park. All rights reserved.
//

import UIKit

extension VoteController {
    
    func calculateNewElos(songRatingOne: Int, songRatingTwo: Int) -> (newSongRatingOne: Int, newSongRatingTwo: Int) {
        let songRatingOne = Double(songRatingOne)
        let songRatingTwo = Double(songRatingTwo)
        
        let rOne = Double( pow(10, songRatingOne/400) )
        let rTwo = Double( pow(10, songRatingTwo/400) )
        
        let expectedScoreRatingOne = Double( rOne / (rOne + rTwo) )
        let expectedScoreRatingTwo = Double( rTwo / (rOne + rTwo) )
        
        //Find k factors
        func findKFactor(rating: Double) -> Double {
            var kFactor = Double(0)
            
            if rating < 2100 {
                kFactor = 32
            }
            if rating >= 2100 && rating <= 2400 {
                kFactor = 24
            }
            else if rating > 2400 {
                kFactor = 16
            }
            return kFactor
        }
        
        let kFactorOne = findKFactor(rating: songRatingOne)
        let kFactorTwo = findKFactor(rating: songRatingTwo)
        
        //Calculate gain or loss for new elos
        let gainLossOne = kFactorOne * (sOne - expectedScoreRatingOne)
        let gainLoseeTwo = kFactorTwo * (sTwo - expectedScoreRatingTwo)
        
        //New elos
        var newSongRatingOne = Int(songRatingOne + ( kFactorOne * (sOne - expectedScoreRatingOne)))
        var newSongRatingTwo = Int(songRatingTwo + ( kFactorTwo * (sTwo - expectedScoreRatingTwo)))
        
        if newSongRatingOne < 0 {
            newSongRatingOne = 0
        }
        
        if newSongRatingTwo < 0 {
            newSongRatingTwo = 0
        }
        
        return (newSongRatingOne, newSongRatingTwo)
    }
    
}





