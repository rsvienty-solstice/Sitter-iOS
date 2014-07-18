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
                            
    @IBOutlet var firstBubble: UIButton
    @IBOutlet var secondBubble: UIButton
    @IBOutlet var secondWhiteView: UIView
    @IBOutlet var secondStatusView: UIView
    @IBOutlet var thirdBubble: UIButton
    @IBOutlet var secondNameView: UIView

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        firstBubble.layer.cornerRadius = 50;
        secondBubble.layer.cornerRadius = 65;
        thirdBubble.layer.cornerRadius = 80;
        firstBubble.clipsToBounds = true
        secondBubble.clipsToBounds = true
        thirdBubble.clipsToBounds = true
        
        secondWhiteView.clipsToBounds = true
        secondWhiteView.layer.cornerRadius = 69
        secondStatusView.clipsToBounds = true
        secondStatusView.layer.cornerRadius = 72
        secondNameView.clipsToBounds = true
        secondNameView.layer.cornerRadius = 35
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

