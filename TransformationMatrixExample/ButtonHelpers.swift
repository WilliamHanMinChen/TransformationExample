//
//  ButtonHelpers.swift
//  TransformationMatrixExample
//
//  Created by William Chen on 2023/3/20.
//
//  This file contains helper methods used to setup the rapid fire button mechanics

import Foundation
import UIKit

extension ViewController {
    
    
    
    //MARK: Button Actions (Rapid Fire)
    @objc func buttonDown(_ sender: UIButton) {
        //Check which button
        switch sender.tag {
        case FORWARDBUTTONTAG:
            moveForward()
            forwardButtonTimer = Timer.scheduledTimer(timeInterval: RAPID_FIRE_INTERVAL, target: self, selector: #selector(moveForward), userInfo: nil, repeats: true)
        case BACKBUTTONTAG:
            moveBack()
            backButtonTimer = Timer.scheduledTimer(timeInterval: RAPID_FIRE_INTERVAL, target: self, selector: #selector(moveBack), userInfo: nil, repeats: true)
        case LEFTBUTTONTAG:
            moveLeft()
            leftButtonTimer = Timer.scheduledTimer(timeInterval: RAPID_FIRE_INTERVAL, target: self, selector: #selector(moveLeft), userInfo: nil, repeats: true)
        case RIGHTBUTTONTAG:
            moveRight()
            rightButtonTimer = Timer.scheduledTimer(timeInterval: RAPID_FIRE_INTERVAL, target: self, selector: #selector(moveRight), userInfo: nil, repeats: true)
        case RAISEBUTTONTAG:
            raise()
            raiseButtonTimer = Timer.scheduledTimer(timeInterval: RAPID_FIRE_INTERVAL, target: self, selector: #selector(raise), userInfo: nil, repeats: true)
        case LOWERBUTTONTAG:
            lower()
            lowerButtonTimer = Timer.scheduledTimer(timeInterval: RAPID_FIRE_INTERVAL, target: self, selector: #selector(lower), userInfo: nil, repeats: true)
        default:
            break;
        }
    }
    
    @objc func buttonUp(_ sender: UIButton) {
        //Check which button
        switch sender.tag {
        case FORWARDBUTTONTAG:
            forwardButtonCounter = 0
            forwardButtonTimer?.invalidate()
        case BACKBUTTONTAG:
            backButtonCounter = 0
            backButtonTimer?.invalidate()
        case LEFTBUTTONTAG:
            leftButtonCounter = 0
            leftButtonTimer?.invalidate()
        case RIGHTBUTTONTAG:
            rightButtonCounter = 0
            rightButtonTimer?.invalidate()
        case RAISEBUTTONTAG:
            raiseButtonCounter = 0
            raiseButtonTimer?.invalidate()
        case LOWERBUTTONTAG:
            lowerButtonCounter = 0
            lowerButtonTimer?.invalidate()
        default:
            break;
        }
    }
    
    
    
}
