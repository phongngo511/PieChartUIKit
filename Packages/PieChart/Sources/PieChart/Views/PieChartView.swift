//
//  PieChartView.swift
//  PieChart
//
//  Created by Phu Phong Ngo on 21/6/2023.
//

import UIKit

public class PieChartView: UIView {

    /// Callback returns slice index when a piece of pie is touched
    public var onTouchPie: ((_ sliceIndex: Int) -> ())?

    /// Boolean indicates whether pie is highlighted upon user interactions
    public var shouldHighlightPieOnTouch = false

    /// Boolean indicates percentage label's isibility whether it is hidden or showed
    public var shouldShowPercentageLabel: Bool = false {
        didSet { setNeedsLayout() }
    }

    /// Determines font of percentage label
    public var percentageLabelTextFont = UIFont.systemFont(ofSize: 12) {
        didSet { setNeedsLayout() }
    }

    /// Determines text color of percentage label
    public var percentageLabelTextColor = UIColor.black {
        didSet { setNeedsLayout() }
    }

    public enum PercentageLabelType {
        case segment
        case fill
    }

    /// Determines the percentage label type
    public var percentageLabelType = PercentageLabelType.segment {
        didSet { setNeedsLayout() }
    }

    /// Determines gradient colors for each segment
    public var pieGradientColors: [[UIColor]] = [[.red,.red], [.cyan,.cyan], [.green,.green]] {
        didSet { setNeedsLayout() }
    }

    /// Specify the space of each segment
    /// Percentage value is ranged within 0...1
    public var pieFilledPercentages: [CGFloat] = [0, 0, 0] {
        didSet { setNeedsLayout() }
    }

    /// Specify number of segments and how much space each takes from the pie
    /// Space value is ranged within 0...100
    public var segments: [CGFloat] = [40, 30, 30] {
        didSet { setNeedsLayout() }
    }

    /// Determines spacing between each segment, its value range is idealy from 0 to 20
    public var offset: CGFloat = 5 {
        didSet { setNeedsLayout() }
    }

    /// Determines inner corner radius of pie segment
    public var segmentInnerCornerRadius: CGFloat = 10 {
        didSet { setNeedsDisplay() }
    }

    /// Determines outer corner radius of pie segment
    public var segmentOuterCornerRadius: CGFloat = 5 {
        didSet { setNeedsDisplay() }
    }

    private var labels: [UILabel] = []
    private var labelSize = CGSize(width: 100, height: 50)
    private var shapeLayers = [CAShapeLayer]()
    private var gradientLayers = [CAGradientLayer]()

    public override func layoutSubviews() {
        super.layoutSubviews()

        labels.forEach({$0.removeFromSuperview()})
        labels.removeAll()

        shapeLayers.forEach({$0.removeFromSuperlayer()})
        shapeLayers.removeAll()

        gradientLayers.forEach({$0.removeFromSuperlayer()})
        gradientLayers.removeAll()

        let valueCount = segments.reduce(CGFloat(0), {$0 + $1})
        guard pieFilledPercentages.count >= 3, segments.count >= 3, pieGradientColors.count >= 3 , valueCount > 0 else { return }
        var startAngle: CGFloat = 360
        var proportions = segments.map({ ($0 / valueCount * 100).rounded()})
        proportions.removeLast()
        let sumOfProportions = proportions.reduce(0, {$0 + $1})
        proportions.append(max(100 - sumOfProportions, 0))

        for i in 0..<segments.count {
            let endAngle = startAngle - CGFloat(proportions[i]) / 100 * 360

            let path = createPath(from: startAngle, to: endAngle, innerCornerRadius: segmentInnerCornerRadius, outerCornerRadius: segmentOuterCornerRadius, percentage: CGFloat(proportions[i]), pieFilledPercentage: pieFilledPercentages[i])
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayers.append(shapeLayer)

            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = pieGradientColors[i].map({$0.cgColor})
            gradientLayer.startPoint = GradientDirection.topBottom.points.start
            gradientLayer.endPoint = GradientDirection.topBottom.points.end
            gradientLayer.mask = shapeLayer
            gradientLayer.bounds = path.bounds
            gradientLayer.frame = path.bounds

            if proportions[i] != 0 && pieFilledPercentages[i] != 0 {
                layer.addSublayer(gradientLayer)
                gradientLayers.append(gradientLayer)
            }

            let label = labelFromPoint(point: getCenterPointOfArc(startAngle: startAngle, endAngle: endAngle), andText: String(format: "%.f", percentageLabelType == .fill ? pieFilledPercentages[i] * 100 : segments[i]) + "%")
            label.isHidden = !shouldShowPercentageLabel
            if proportions[i] != 0 {
                addSubview(label)
                labels.append(label)
            }

            startAngle = endAngle
        }
    }

    private func labelFromPoint(point: CGPoint, andText text: String) -> UILabel {
        let label = UILabel(frame: CGRect(origin: point, size: labelSize))
        label.font = percentageLabelTextFont
        label.textColor = percentageLabelTextColor
        label.text = text
        return label
    }

    private func getCenterPointOfArc(startAngle: CGFloat, endAngle: CGFloat) -> CGPoint {
        let oRadius = max(bounds.width / 2, bounds.height / 2) * 0.9
        let center = CGPoint(x: oRadius, y: oRadius)
        let centerAngle = ((startAngle + endAngle) / 2.0).toRadians()
        let arcCenter = CGPoint(x: center.x + oRadius * cos(centerAngle), y: center.y - oRadius * sin(centerAngle))
        return CGPoint(x: (center.x + arcCenter.x) / 2, y: (center.y + arcCenter.y) / 2)
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, shouldHighlightPieOnTouch {
            var touchedIndex: Int = -1
            shapeLayers.enumerated().forEach { (item) in
                if let path = item.element.path, path.contains(touch.location(in: self)) {
                    touchedIndex = item.offset
                    item.element.opacity = 1
                }
            }
            if touchedIndex != -1 {
                shapeLayers.enumerated().filter({$0.offset != touchedIndex}).forEach({$0.element.opacity = 0.3})
                onTouchPie?(touchedIndex)
            } else {
                shapeLayers.forEach({$0.opacity = 1})
                onTouchPie?(-1)
            }
        }
        super.touchesBegan(touches, with: event)
    }

    private func highlightLayer(index: Int) {
        shapeLayers.enumerated().forEach({$0.element.opacity = $0.offset == index ? 1: 0.3 })
    }

    private func createPath(from startAngle: CGFloat,
                            to endAngle: CGFloat,
                            innerCornerRadius: CGFloat,
                            outerCornerRadius: CGFloat,
                            percentage: CGFloat,
                            pieFilledPercentage: CGFloat) -> UIBezierPath {

        var radius: CGFloat = min(bounds.width, bounds.height) / 2.0 - (2.0 * offset)
        radius *= min(1, max(0.3, pieFilledPercentage))
        if pieFilledPercentage == 0 {
            radius = 0
        }
        radius -= offset * 3 * (1 - percentage / 100)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let midPointAngle = ((startAngle + endAngle) / 2.0).toRadians() //used to spread the segment away from its neighbours after creation

        let startAngle = (360.0 - startAngle).toRadians()
        let endAngle = (360.0 - endAngle).toRadians()

        let circumference: CGFloat = CGFloat(2.0 * (Double.pi * Double(radius)))
        let arcLengthPerDegree = circumference / 360.0 //how many pixels long the outer arc is of the pie chart, per 1° of a pie segment
        let pieSegmentOuterCornerRadius = arcLengthPerDegree * outerCornerRadius

        let path = UIBezierPath()

        //move to the centre of the pie chart, offset by the corner radius (so the corner of the segment can be rounded in a bit)
        path.move(to: CGPoint(x: center.x + (cos(startAngle - CGFloat(360).toRadians()) * innerCornerRadius), y: center.y + (sin(startAngle - CGFloat(360).toRadians()) * innerCornerRadius)))
        //if the size of the pie segment isn't big enough to warrant rounded outer corners along its outer arc, don't round them off
        if ((endAngle - startAngle).toDegrees() <= (outerCornerRadius * 2.0)) {
            //add line from centre of pie chart to 1st outer corner of segment
            path.addLine(to: CGPoint(x: center.x + (cos(startAngle - CGFloat(360).toRadians()) * radius), y: center.y + (sin(startAngle - CGFloat(360).toRadians()) * radius)))
            //add arc for segment's outer edge on pie chart
            path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            //move down to the centre of the pie chart, leaving room for rounded corner at the end
            path.addLine(to: CGPoint(x: center.x + (cos(endAngle - CGFloat(360).toRadians()) * innerCornerRadius), y: center.y + (sin(endAngle - CGFloat(360).toRadians()) * innerCornerRadius)))
            //add final rounded corner in middle of pie chart
            path.addQuadCurve(to: CGPoint(x: center.x + (cos(startAngle - CGFloat(360).toRadians()) * innerCornerRadius), y: center.y + (sin(startAngle - CGFloat(360).toRadians()) * innerCornerRadius)), controlPoint: center)
        } else if percentage == 100 {
            path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        } else { //round the corners on the outer arc
            //add line from centre of pie chart to circumference of segment, minus the space needed for the rounded corner
            path.addLine(to: CGPoint(x: center.x + (cos(startAngle - CGFloat(360).toRadians()) * (radius - pieSegmentOuterCornerRadius)), y: center.y + (sin(startAngle - CGFloat(360).toRadians()) * (radius - pieSegmentOuterCornerRadius))))
            //add rounded corner onto start of outer arc
            let firstRoundedCornerEndOnArc = CGPoint(x: center.x + (cos(startAngle + outerCornerRadius.toRadians() - CGFloat(360).toRadians()) * radius), y: center.y + (sin(startAngle + outerCornerRadius.toRadians() - CGFloat(360).toRadians()) * radius))
            path.addQuadCurve(to: firstRoundedCornerEndOnArc, controlPoint: CGPoint(x: center.x + (cos(startAngle - CGFloat(360).toRadians()) * radius), y: center.y + (sin(startAngle - CGFloat(360).toRadians()) * radius)))
            //add arc for segment's outer edge on pie chart
            path.addArc(withCenter: center, radius: radius, startAngle: startAngle + outerCornerRadius.toRadians(), endAngle: endAngle - outerCornerRadius.toRadians(), clockwise: true)
            //add rounded corner onto end of outer arc
            let secondRoundedCornerEndOnLine = CGPoint(x: center.x + (cos(endAngle - CGFloat(360).toRadians()) * (radius - pieSegmentOuterCornerRadius)), y: center.y + (sin(endAngle - CGFloat(360).toRadians()) * (radius - pieSegmentOuterCornerRadius)))
            path.addQuadCurve(to: secondRoundedCornerEndOnLine, controlPoint: CGPoint(x: center.x + (cos(endAngle - CGFloat(360).toRadians()) * radius), y: center.y + (sin(endAngle - CGFloat(360).toRadians()) * radius)))
            //add line back to centre point of pie chart, leaving room for rounded corner at the end
            path.addLine(to: CGPoint(x: center.x + (cos(endAngle - CGFloat(360).toRadians()) * innerCornerRadius), y: center.y + (sin(endAngle - CGFloat(360).toRadians()) * innerCornerRadius)))
            //add final rounded corner in middle of pie chart
            path.addQuadCurve(to: CGPoint(x: center.x + (cos(startAngle - CGFloat(360).toRadians()) * innerCornerRadius), y: center.y + (sin(startAngle - CGFloat(360).toRadians()) * innerCornerRadius)), controlPoint: center)
        }
        path.close()
        //spread the segments out around the pie chart centre
        path.apply(CGAffineTransform(translationX: cos(midPointAngle) * offset, y: -sin(midPointAngle) * offset))
        return path
    }
}
