//
//  SetupMethods.swift
//  TransformationMatrixExample
//
//  Created by William Chen on 2023/3/20.
//

import Foundation


extension ViewController {
    
    func setUpButtons(){
        
        //Set the tags for the buttons
        forwardButton.tag = FORWARDBUTTONTAG
        backButton.tag = BACKBUTTONTAG
        leftButton.tag = LEFTBUTTONTAG
        rightButton.tag = RIGHTBUTTONTAG
        raiseButton.tag = RAISEBUTTONTAG
        lowerButton.tag = LOWERBUTTONTAG
        
        //Add the selectors for the events
        forwardButton.addTarget(self, action: #selector(buttonDown), for: .touchDown)
        forwardButton.addTarget(self, action: #selector(buttonUp), for: [.touchUpInside, .touchUpOutside])
        backButton.addTarget(self, action: #selector(buttonDown), for: .touchDown)
        backButton.addTarget(self, action: #selector(buttonUp), for: [.touchUpInside, .touchUpOutside])
        leftButton.addTarget(self, action: #selector(buttonDown), for: .touchDown)
        leftButton.addTarget(self, action: #selector(buttonUp), for: [.touchUpInside, .touchUpOutside])
        rightButton.addTarget(self, action: #selector(buttonDown), for: .touchDown)
        rightButton.addTarget(self, action: #selector(buttonUp), for: [.touchUpInside, .touchUpOutside])
        raiseButton.addTarget(self, action: #selector(buttonDown), for: .touchDown)
        raiseButton.addTarget(self, action: #selector(buttonUp), for: [.touchUpInside, .touchUpOutside])
        lowerButton.addTarget(self, action: #selector(buttonDown), for: .touchDown)
        lowerButton.addTarget(self, action: #selector(buttonUp), for: [.touchUpInside, .touchUpOutside])
    }
    
}
