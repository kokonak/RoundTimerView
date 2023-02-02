//
//  ViewController.swift
//  RoundTimerView
//
//  Created by kokonak on 2020/06/09.
//  Copyright © 2020 kokonak. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    private lazy var startButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.setTitle("Start", for: .normal)
        button.setTitle("Pause", for: .selected)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.03, green: 0.02, blue: 0.20, alpha: 1)
        button.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
        return button
    }()

    private let timerView: TimerView = TimerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.white

        view.addSubview(timerView)
        timerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timerView.widthAnchor.constraint(equalToConstant: 300),
            timerView.heightAnchor.constraint(equalTo: timerView.widthAnchor),
            timerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        view.addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startButton.topAnchor.constraint(equalTo: timerView.bottomAnchor, constant: 30),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc func buttonTap() {
        if startButton.isSelected {
            timerView.pauseTimer()
        } else {
            timerView.startTimer()
        }
        startButton.isSelected = !startButton.isSelected
    }
}

