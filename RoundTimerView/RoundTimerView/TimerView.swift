//
//  TimerView.swift
//  RoundTimerView
//
//  Created by kokonak on 2020/06/09.
//  Copyright © 2020 kokonak. All rights reserved.
//

import UIKit

class TimerView: UIView {

    private let roundLayerBackground: CAShapeLayer = CAShapeLayer()
    private let roundLayer: CAShapeLayer = CAShapeLayer()
    private let sliderButtonView: UIView = UIView()
    private let sliderView: UIView = UIView()
    private let gesture: UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    private let timerLabel: UILabel = UILabel()

    var maxSeconds: Double = 60
    var timeInterval: Double = 1
    
    var borderWidth: CGFloat = 20 {
        didSet {
            self.resizeFrames()
        }
    }
    
    var sliderButtonRadius: CGFloat = 20 {
        didSet {
            self.resizeFrames()
        }
    }
    
    var time: Double = 0 {
        didSet {
            self.timerLabel.attributedText = self.attributedStringForTimerLabel(seconds: self.time)
            self.sliderView.layer.transform = CATransform3DMakeRotation(self.getTimeRadian(time: self.time), 0, 0, 1)
        }
    }

    override var frame: CGRect {
        didSet {
            self.resizeFrames()
        }
    }
    private func resizeFrames() {
        var sliderButtonFrame: CGRect
        var roundLayerFrame: CGRect
        
        if self.borderWidth < sliderButtonRadius * 2{
            sliderButtonFrame = CGRect(x: self.bounds.width/2 - self.sliderButtonRadius, y: 0, width: self.sliderButtonRadius * 2, height: self.sliderButtonRadius * 2)
            
            let margin: CGFloat = self.sliderButtonRadius
            roundLayerFrame = CGRect(x: margin, y: margin, width: self.bounds.width - self.sliderButtonRadius * 2, height: self.bounds.height - self.sliderButtonRadius * 2)
        }
        else {
            let margin: CGFloat = self.borderWidth/2
            roundLayerFrame = CGRect(x: margin, y: margin, width: self.bounds.width - self.borderWidth, height: self.bounds.height - self.borderWidth)
            sliderButtonFrame = CGRect(x: self.bounds.width/2 - self.sliderButtonRadius, y: (self.borderWidth/2 - self.sliderButtonRadius), width: self.sliderButtonRadius * 2, height: self.sliderButtonRadius * 2)
        }
        
        self.sliderView.frame = self.bounds
        self.sliderButtonView.frame = sliderButtonFrame
        self.sliderButtonView.layer.cornerRadius = self.sliderButtonRadius
        
        self.roundLayerBackground.lineWidth = self.borderWidth
        self.roundLayer.lineWidth = self.borderWidth
        
        self.roundLayerBackground.frame = self.bounds
        self.roundLayerBackground.path = UIBezierPath(roundedRect: roundLayerFrame, cornerRadius: roundLayerFrame.width/2).cgPath
        
        self.roundLayer.frame = self.roundLayerBackground.bounds
        self.roundLayer.path = self.roundLayerBackground.path
        
        self.timerLabel.frame = self.bounds
    }
    
    
    init() {
        super.init(frame: CGRect.zero)
        self.initElements()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initElements()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initElements() {
        self.backgroundColor = UIColor.clear
                
        self.roundLayerBackground.lineWidth = self.borderWidth
        self.roundLayerBackground.strokeColor = UIColor(red:0.62, green:0.62, blue:0.62, alpha:1.00).cgColor
        self.roundLayerBackground.fillColor = UIColor.clear.cgColor
        self.roundLayerBackground.strokeEnd = 1
        self.layer.addSublayer(self.roundLayerBackground)
        
        self.roundLayer.lineWidth = self.borderWidth
        self.roundLayer.strokeColor = UIColor.red.withAlphaComponent(0.6).cgColor
        self.roundLayer.fillColor = UIColor.clear.cgColor
        self.roundLayer.lineCap = CAShapeLayerLineCap.round
        self.roundLayer.strokeEnd = 0
        self.roundLayer.actions = ["strokeEnd": NSNull()]
        self.layer.addSublayer(self.roundLayer)
        
        self.sliderView.frame = self.bounds
        self.addSubview(self.sliderView)
        
        self.gesture.addTarget(self, action: #selector(handleTapGesture(sender:)))
        self.sliderButtonView.backgroundColor = UIColor.red
        self.sliderButtonView.addGestureRecognizer(self.gesture)
        self.sliderView.addSubview(self.sliderButtonView)
        
        self.timerLabel.font = UIFont.systemFont(ofSize: 60, weight: .medium)
        self.timerLabel.textAlignment = .center
        self.addSubview(self.timerLabel)
        
        self.initializeTime()
    }
    func initializeTime() {
        self.time = 0
        self.timerLabel.attributedText = self.attributedStringForTimerLabel(seconds: self.time)
        self.sliderView.layer.transform = CATransform3DIdentity
        self.roundLayer.strokeEnd = 0
    }
    
    private func attributedStringForTimerLabel(seconds: Double) -> NSAttributedString {
        let minString = "\(Int(seconds))"
        let minPrefix: String = seconds == 0 ? " second" : " seconds"
        
        let attributedString = NSMutableAttributedString(string: minString, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 70, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ])
        attributedString.append(NSAttributedString(string: minPrefix, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .light),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]))
        return attributedString
    }
    
    private func getTimeRadian(time: Double) -> CGFloat {
        let secondAngle: CGFloat = 360 / CGFloat(self.maxSeconds)
        let angle: CGFloat = CGFloat(time) * secondAngle
        let radian: CGFloat = self.degreeToRadian(angle)
        
        return radian
    }
    
    @objc private func handleTapGesture(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            
            let newPoint = sender.location(in: self)
            let x = self.sliderView.center.x
            let y = self.sliderView.center.y
            
            let dx = newPoint.x - x
            let dy = newPoint.y - y
            
            var radian = atan2(dx, -dy)
            
            if radian < 0 {
                radian = (CGFloat.pi * 2) + radian
            }
            else if radian == 0 {
                radian = CGFloat.pi * 2
            }
            
            let interval: CGFloat = CGFloat(self.maxSeconds / self.timeInterval)
            
            let value: CGFloat = (CGFloat.pi * 2) / interval
            let newRadian: CGFloat = CGFloat(Int(radian / value)) * value
            
            var time: Int = 0
            time += Int(radian/value) * Int(self.timeInterval)
            
            if radian > ((interval - 1) * value) + value/2 {
                self.roundLayer.strokeEnd = 1.0
                self.time = self.maxSeconds
                self.sliderView.layer.transform = CATransform3DMakeRotation(0, 0, 0, 1)
            }
            else {
                self.roundLayer.strokeEnd = CGFloat(self.radianToDegree(newRadian)/360.0)
                self.time = Double(time)
                self.sliderView.layer.transform = CATransform3DMakeRotation(newRadian, 0, 0, 1)
            }
        default: break
        }
    }
    private func degreeToRadian(_ angle: CGFloat) -> CGFloat {
        return (angle * CGFloat.pi) / 180
    }
    
    private func radianToDegree(_ radian: CGFloat) -> CGFloat {
        var newAngle: CGFloat = (radian * 180.0) / CGFloat.pi
        if newAngle < 0 {
            newAngle = 360 + newAngle
        }
        return newAngle
    }
    
    private var timer: Timer?
    func startTimer() {
        if self.timer != nil {
            return
        }
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
            if self.time <= 0 {
                timer.invalidate()
                self.timer = nil
                return
            }
            self.roundLayer.strokeEnd = CGFloat(self.radianToDegree(self.getTimeRadian(time: self.time))/360.0)
            self.time -= 0.1
        }
        RunLoop.main.add(self.timer!, forMode: RunLoop.Mode.common)
    }
}
