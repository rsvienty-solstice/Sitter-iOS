//
//  ViewController.swift
//  Sitter-iOS
//
//  Created by Jillian Offutt on 7/17/14.
//  Copyright (c) 2014 Solstice Mobile. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController {
                            
    @IBOutlet var sitterBackgroundImageView: UIImageView
    
    @IBOutlet var firstBubble: UIButton
    @IBOutlet var firstWhiteView: UIView
    @IBOutlet var firstStatusView: UIView
    
    @IBOutlet var secondBubble: UIButton
    @IBOutlet var secondWhiteView: UIView
    @IBOutlet var secondStatusView: UIView
    
    @IBOutlet var thirdBubble: UIButton
    @IBOutlet var thirdWhiteView: UIView
    @IBOutlet var thirdStatusView: UIView
    
    
    @IBOutlet var secondNameView: UIView
    @IBOutlet var firstNameView: UIView
    @IBOutlet var thirdNameView: UIView
    
    @IBOutlet var menuButton: UIButton
    @IBOutlet var tintedView: UIView
    
    @IBOutlet var signOutButton: UIButton
    @IBOutlet var settingsButton: UIButton
    @IBOutlet var addChildButton: UIButton
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        firstBubble.layer.cornerRadius = 50;
        secondBubble.layer.cornerRadius = 65;
        thirdBubble.layer.cornerRadius = 80;
        firstBubble.clipsToBounds = true
        secondBubble.clipsToBounds = true
        thirdBubble.clipsToBounds = true
        
        firstWhiteView.clipsToBounds = true
        firstWhiteView.layer.cornerRadius = 54
        firstStatusView.clipsToBounds = true
        firstStatusView.layer.cornerRadius = 57
        
        secondWhiteView.clipsToBounds = true
        secondWhiteView.layer.cornerRadius = 69
        secondStatusView.clipsToBounds = true
        secondStatusView.layer.cornerRadius = 72
        secondNameView.clipsToBounds = true
        secondNameView.layer.cornerRadius = 35
        
        thirdWhiteView.clipsToBounds = true
        thirdWhiteView.layer.cornerRadius = 87
        thirdStatusView.clipsToBounds = true
        thirdStatusView.layer.cornerRadius = 91
        
        firstNameView.clipsToBounds = true
        firstNameView.layer.cornerRadius = 35
        thirdNameView.clipsToBounds = true
        thirdNameView.layer.cornerRadius = 35
        
        self.setUpParallax()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpParallax() {
        let interpolationHorizontal:UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffectType.TiltAlongHorizontalAxis)
        interpolationHorizontal.minimumRelativeValue = -10.0
        interpolationHorizontal.maximumRelativeValue = 10.0
        
        let interpolationVertical:UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffectType.TiltAlongVerticalAxis)
        interpolationVertical.minimumRelativeValue = -10.0
        interpolationVertical.maximumRelativeValue = 10.0
        
        sitterBackgroundImageView.addMotionEffect(interpolationHorizontal)
        sitterBackgroundImageView.addMotionEffect(interpolationVertical)
    }

    @IBAction func menuButtonTapped(sender: AnyObject) {
        if(self.tintedView.hidden == true) {
            self.tintedView.hidden = false
            self.view.bringSubviewToFront(self.addChildButton)
            self.view.bringSubviewToFront(self.settingsButton)
            self.view.bringSubviewToFront(self.signOutButton)
            self.view.bringSubviewToFront(self.menuButton)
            self.addChildButton.hidden = false
            self.settingsButton.hidden = false
            self.signOutButton.hidden = false
            //self.view.bringSubviewToFront(self.menuButton)
        }
        else {
            self.tintedView.hidden = true
            self.addChildButton.hidden = true
            self.settingsButton.hidden = true
            self.signOutButton.hidden = true
        }
            }

}

