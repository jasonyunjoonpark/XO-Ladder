//
//  VoteController+EloManager.swift
//  XO Ladder
//
//  Created by Jason Park on 4/17/18.
//  Copyright © 2018 Jason Park. All rights reserved.
//

import UIKit

extension VoteController {
    
//    var ratingOne = Double(2300)
//    var ratingTwo = Double(1100)
//    
//    var rOne = Double( pow(10, ratingOne/400) )
//    var rTwo = Double( pow(10, ratingTwo/400) )
//    
//    var expectedScoreRatingOne = Double( rOne / (rOne + rTwo) )
//    var expectedScoreRatingTwo = Double( rTwo / (rOne + rTwo) )
//    
//    var sOne = Double(0)
//    var sTwo = Double(1)
//    
//    func findKFactor(rating: Double) -> Double {
//        var kFactor = Double(0)
//        
//        if rating < 2100 {
//            kFactor = 32
//        }
//        if rating >= 2100 && ratingOne <= 2400 {
//            kFactor = 24
//        }
//        else if rating > 2400 {
//            kFactor = 16
//        }
//        return kFactor
//    }
//    
//    var kFactorOne = findKFactor(rating: ratingOne)
//    var kFactorTwo = findKFactor(rating: ratingTwo)
//    
//    
//    var gainLossOne = kFactorOne * (sOne - expectedScoreRatingOne)
//    var gainLoseeTwo = kFactorTwo * (sTwo - expectedScoreRatingTwo)
//    
//    var updatedEloRatingOne = ratingOne + ( kFactorOne * (sOne - expectedScoreRatingOne) )
//    var updatedEloRatingTwo = ratingTwo + ( kFactorTwo * (sTwo - expectedScoreRatingTwo))
    
    func calculateNewElos(songRatingOne: Int, songRatingTwo: Int) -> (newSongRatingOne: Int, newSongRatingTwo: Int) {
        let songRatingOne = Double(songRatingOne)
        let songRatingTwo = Double(songRatingTwo)
        
        let rOne = Double( pow(10, songRatingOne/400) )
        let rTwo = Double( pow(10, songRatingTwo/400) )
        
        let expectedScoreRatingOne = Double( rOne / (rOne + rTwo) )
        let expectedScoreRatingTwo = Double( rTwo / (rOne + rTwo) )
        
        //var sOne = Double(0)
        //var sTwo = Double(1)
        
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
        
        return (newSongRatingOne, newSongRatingTwo)
    }
    
}





