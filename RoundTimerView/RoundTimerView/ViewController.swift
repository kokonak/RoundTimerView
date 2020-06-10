//
//  ViewController.swift
//  RoundTimerView
//
//  Created by kokonak on 2020/06/09.
//  Copyright © 2020 kokonak. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private let startButton: UIButton = UIButton()
    private let timerView: TimerView = TimerView()
    
    override func loadView() {
        super.loadView()

        self.view.addSubview(self.timerView)
        
        self.startButton.layer.borderWidth = 1
        self.startButton.layer.borderColor = UIColor.black.cgColor
        self.startButton.setTitle("Timer start!", for: .normal)
        self.startButton.setTitleColor(UIColor.black, for: .normal)
        self.startButton.addTarget(self, action: #selector(timerStart(_:)), for: .touchUpInside)
        self.view.addSubview(self.startButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.timerView.frame.size = CGSize(width: 300, height: 300)
        self.timerView.center = self.view.center
        
        self.startButton.frame = CGRect(x: (self.view.frame.width - 200)/2, y: self.timerView.frame.maxY + 30, width: 200, height: 50)
    }

    @objc func timerStart(_ sender: UIButton) {
        self.timerView.startTimer()
    }

}

