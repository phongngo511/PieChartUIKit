//
//  ViewController.swift
//  PieChartUIKitSample
//
//  Created by Phu Phong Ngo on 22/6/2023.
//

import UIKit
import PieChartUIKit

class SampleViewController: UIViewController {

    let pieChartView = PieChartView(frame: CGRect(origin: CGPoint(x: 50, y: 150), size: CGSize(width: 300, height: 300)))
    let slider1 = UISlider(frame: CGRect(origin: CGPoint(x: 60, y: 450), size: CGSize(width: 250, height: 100)))
    let slider2 = UISlider(frame: CGRect(origin: CGPoint(x: 60, y: 550), size: CGSize(width: 250, height: 100)))
    let slider3 = UISlider(frame: CGRect(origin: CGPoint(x: 60, y: 650), size: CGSize(width: 250, height: 100)))

    let fillSlider1 = UISlider(frame: CGRect(origin: CGPoint(x: 60, y: 500), size: CGSize(width: 250, height: 50)))
    let fillSlider2 = UISlider(frame: CGRect(origin: CGPoint(x: 60, y: 600), size: CGSize(width: 250, height: 50)))
    let fillSlider3 = UISlider(frame: CGRect(origin: CGPoint(x: 60, y: 700), size: CGSize(width: 250, height: 50)))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupSliders()
        setupFillSliders()
        setupPieChartView()
    }

    func setupSliders() {
        slider1.maximumValue = 100
        slider1.minimumValue = 0
        slider1.value = 30
        slider1.addTarget(self, action: #selector(onSlider1ValueChanged), for: .valueChanged)

        slider2.maximumValue = 100
        slider2.minimumValue = 0
        slider2.value = 30
        slider2.addTarget(self, action: #selector(onSlider1ValueChanged), for: .valueChanged)

        slider3.maximumValue = 100
        slider3.minimumValue = 0
        slider3.value = 40
        slider3.addTarget(self, action: #selector(onSlider1ValueChanged), for: .valueChanged)

        [slider1, slider2, slider3].forEach(view.addSubview(_:))
    }

    func setupFillSliders() {
        fillSlider1.maximumValue = 1
        fillSlider1.minimumValue = 0
        fillSlider1.value = 100
        fillSlider1.addTarget(self, action: #selector(onFillSlider1ValueChanged), for: .valueChanged)

        fillSlider2.maximumValue = 1
        fillSlider2.minimumValue = 0
        fillSlider2.value = 100
        fillSlider2.addTarget(self, action: #selector(onFillSlider2ValueChanged), for: .valueChanged)

        fillSlider3.maximumValue = 1
        fillSlider3.minimumValue = 0
        fillSlider3.value = 100
        fillSlider3.addTarget(self, action: #selector(onFillSlider3ValueChanged), for: .valueChanged)

        [fillSlider1, fillSlider2, fillSlider3].forEach(view.addSubview(_:))
    }

    func setupPieChartView() {
        pieChartView.shouldShowPercentageLabel = true
        pieChartView.shouldHighlightPieOnTouch = true
        pieChartView.percentageLabelType = .segment
        pieChartView.segmentInnerCornerRadius = 8
        pieChartView.segmentOuterCornerRadius = 6
        pieChartView.pieFilledPercentages = [CGFloat(fillSlider1.value), CGFloat(fillSlider2.value), CGFloat(fillSlider3.value)]
        pieChartView.segments = [CGFloat(slider1.value), CGFloat(slider2.value), CGFloat(slider3.value)]
        pieChartView.pieGradientColors = [
            [UIColor(red: 118/255, green: 190/255, blue: 255/255, alpha: 1.0), UIColor(red: 136/255, green: 107/255, blue: 235/255, alpha: 1.0)],
            [UIColor(red: 255/255, green: 225/255, blue: 86/255, alpha: 1.0), UIColor(red: 254/255, green: 155/255, blue: 39/255, alpha: 1.0)],
            [UIColor(red: 254/255, green: 166/255, blue: 101/255, alpha: 1.0), UIColor(red: 255/255, green: 105/255, blue: 115/255, alpha: 1.0)]
        ]

        view.addSubview(pieChartView)
    }

    @objc func onSlider1ValueChanged(_ sender: UISlider) {
        pieChartView.segments[0] = CGFloat(sender.value)
    }

    @objc func onSlider2ValueChanged(_ sender: UISlider) {
        pieChartView.segments[1] = CGFloat(sender.value)
    }

    @objc func onSlider3ValueChanged(_ sender: UISlider) {
        pieChartView.segments[2] = CGFloat(sender.value)
    }

    @objc func onFillSlider1ValueChanged(_ sender: UISlider) {
        pieChartView.pieFilledPercentages[0] = CGFloat(sender.value)
    }

    @objc func onFillSlider2ValueChanged(_ sender: UISlider) {
        pieChartView.pieFilledPercentages[1] = CGFloat(sender.value)
    }

    @objc func onFillSlider3ValueChanged(_ sender: UISlider) {
        pieChartView.pieFilledPercentages[2] = CGFloat(sender.value)
    }
}
