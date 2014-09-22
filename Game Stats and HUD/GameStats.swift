//
//  GameStats.swift
//
//  Created by Adrian Simionescu on 17/09/14.
//

import Foundation

public class GameStats
{
    var score : Int;
    var birdsLeft : Int;
    var lives : Int;
    
    init()
    {
        self.score = 0;
        self.birdsLeft = 0;
        self.lives = 0;
    }
}