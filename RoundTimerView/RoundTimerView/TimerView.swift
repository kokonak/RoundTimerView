//
//  TimerView.swift
//  RoundTimerView
//
//  Created by kokonak on 2023/02/02.
//  Copyright © 2023 kokonak. All rights reserved.
//

import UIKit

final class TimerView: UIView {

    private lazy var borderView: UIView = {
        let view = UIView()
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        return view
    }()

    private lazy var borderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = borderWidth
        layer.strokeColor = UIColor(red: 0.03, green: 0.02, blue: 0.20, alpha: 0.5).cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = CAShapeLayerLineCap.round
        layer.strokeEnd = 0
        layer.actions = ["strokeEnd": NSNull()]
        return layer
    }()

    private let sliderView = UIView()

    private let sliderButtonView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.03, green: 0.02, blue: 0.20, alpha: 1)
        view.clipsToBounds = true
        return view
    }()

    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 60, weight: .medium)
        label.textAlignment = .center
        label.text = "\(Int(time))"
        return label
    }()

    private lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer()
        gesture.addTarget(self, action: #selector(handlePanGesture(sender:)))
        return gesture
    }()

    private lazy var borderViewTopConstraint = borderView.topAnchor.constraint(equalTo: self.topAnchor)
    private lazy var borderViewLeadingConstraint = borderView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
    private lazy var borderViewTrailingConstraint = borderView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
    private lazy var borderViewBottomConstraint = borderView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    private lazy var sliderButtonWidthConstraint = sliderButtonView.widthAnchor.constraint(equalToConstant: 0)
    private lazy var sliderButtonHeightConstraint = sliderButtonView.heightAnchor.constraint(equalToConstant: 0)
    private lazy var sliderButtonTopConstraint = sliderButtonView.topAnchor.constraint(equalTo: self.topAnchor)

    var borderWidth: CGFloat = 20 {
        didSet { updateUI() }
    }

    var sliderButtonRadius: CGFloat = 15 {
        didSet { updateUI() }
    }

    var time: Double = 0 {
        didSet {
            timerLabel.text = "\(Int(time))"
            sliderView.layer.transform = CATransform3DMakeRotation(getTimeRadian(time: time), 0, 0, 1)
        }
    }

    var maxSeconds: Double = 60
    var timeInterval: Double = 1
    private var timer: Timer?

    init() {
        super.init(frame: .zero)
        setupUI()
        updateUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(borderView)
        borderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            borderViewTopConstraint,
            borderViewLeadingConstraint,
            borderViewTrailingConstraint,
            borderViewBottomConstraint
        ])

        layer.addSublayer(borderLayer)

        addSubview(sliderView)
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sliderView.topAnchor.constraint(equalTo: self.topAnchor),
            sliderView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            sliderView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            sliderView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

        sliderView.addSubview(sliderButtonView)
        sliderButtonView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sliderButtonTopConstraint,
            sliderButtonWidthConstraint,
            sliderButtonHeightConstraint,
            sliderButtonView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])

        sliderButtonView.addGestureRecognizer(panGesture)

        addSubview(timerLabel)
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timerLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }

    private func updateUI() {
        if borderWidth < sliderButtonRadius * 2 {
            // sliderButtonRadius - borderWidth / 2,
            // sliderButton의 중앙보다 borderWidth / 2 뺀 만큼 borderView의 크기가 되어야함.
            borderViewTopConstraint.constant = sliderButtonRadius - borderWidth / 2
            borderViewLeadingConstraint.constant = sliderButtonRadius - borderWidth / 2
            borderViewTrailingConstraint.constant = -(sliderButtonRadius - borderWidth / 2)
            borderViewBottomConstraint.constant = -(sliderButtonRadius - borderWidth / 2)

            sliderButtonTopConstraint.constant = 0
        } else {
            borderViewTopConstraint.constant = 0
            borderViewLeadingConstraint.constant = 0
            borderViewTrailingConstraint.constant = 0
            borderViewBottomConstraint.constant = 0

            sliderButtonTopConstraint.constant = borderWidth / 2 - sliderButtonRadius
        }

        borderLayer.lineWidth = borderWidth

        sliderButtonWidthConstraint.constant = sliderButtonRadius * 2
        sliderButtonHeightConstraint.constant = sliderButtonRadius * 2
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        borderView.layer.cornerRadius = borderView.frame.width / 2

        // shapeLayer의 stroke은 layer의 가장자리를 중심으로 그려지기 때문에 borderView와는 다르게 계산해야함
        borderLayer.frame = bounds
        borderLayer.path = UIBezierPath(
            roundedRect: .init(
                x: borderView.frame.minX + borderWidth / 2,
                y: borderView.frame.minY + borderWidth / 2,
                width: borderView.frame.width - borderWidth,
                height: borderView.frame.height - borderWidth
            ),
            cornerRadius: (borderView.frame.height - borderWidth) / 2
        ).cgPath
        sliderButtonView.layer.cornerRadius = sliderButtonRadius
    }

    @objc private func handlePanGesture(sender: UIPanGestureRecognizer) {
        switch sender.state {
            case .changed:
                let newPoint = sender.location(in: self)
                let x = sliderView.center.x
                let y = sliderView.center.y

                let dx = newPoint.x - x
                let dy = newPoint.y - y

                var radian = atan2(dx, -dy)

                if radian < 0 {
                    radian = (CGFloat.pi * 2) + radian
                } else if radian == 0 {
                    radian = CGFloat.pi * 2
                }

                let interval: CGFloat = CGFloat(maxSeconds / timeInterval)

                let value: CGFloat = (CGFloat.pi * 2) / interval
                let newRadian: CGFloat = CGFloat(Int(radian / value)) * value

                var time: Int = 0
                time += Int(radian/value) * Int(timeInterval)

                if radian > ((interval - 1) * value) + value/2 {
                    borderLayer.strokeEnd = 1.0
                    self.time = maxSeconds
                    sliderView.layer.transform = CATransform3DMakeRotation(0, 0, 0, 1)
                } else {
                    borderLayer.strokeEnd = CGFloat(radianToDegree(newRadian)/360.0)
                    self.time = Double(time)
                    sliderView.layer.transform = CATransform3DMakeRotation(newRadian, 0, 0, 1)
                }
            default:
                break
        }
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if self.time <= 0 {
                self.timer?.invalidate()
                self.timer = nil
                return
            }
            self.borderLayer.strokeEnd = CGFloat(self.radianToDegree(self.getTimeRadian(time: self.time))/360.0)
            self.time -= 0.1
        }
    }

    func pauseTimer() {
        timer?.invalidate()
    }
}

// MARK: - 유틸성
extension TimerView {

    private func getTimeRadian(time: Double) -> CGFloat {
        let secondAngle: CGFloat = 360 / CGFloat(maxSeconds)
        let angle: CGFloat = CGFloat(time) * secondAngle
        let radian: CGFloat = degreeToRadian(angle)

        return radian
    }

    private func degreeToRadian(_ angle: CGFloat) -> CGFloat {
        return (angle * CGFloat.pi) / 180
    }

    private func radianToDegree(_ radian: CGFloat) -> CGFloat {
        var newAngle: CGFloat = (radian * 180) / CGFloat.pi
        if newAngle < 0 {
            newAngle = 360 + newAngle
        }
        return newAngle
    }
}
