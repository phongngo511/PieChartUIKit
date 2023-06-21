import UIKit
import PlaygroundSupport

class PieChartView: UIView {

    var onTouchPie: ((_ sliceIndex: Int) -> ())?
    var shouldHighlightPieOnTouch = false

    var shouldShowLabels: Bool = false {
        didSet { setNeedsLayout() }
    }
    var labelTextFont = UIFont.systemFont(ofSize: 12) {
        didSet { setNeedsLayout() }
    }
    var labelTextColor = UIColor.black {
        didSet { setNeedsLayout() }
    }

    var shouldShowTextPercentageFromFieFilledFigures = false {
        didSet { setNeedsLayout() }
    }

    var pieGradientColors: [[UIColor]] = [[.red,.red], [.cyan,.cyan], [.green,.green]] {
        didSet { setNeedsLayout() }
    }

    var pieFilledPercentages:[CGFloat] = [0, 0, 0] {
        didSet { setNeedsLayout() }
    }

    var segments:[CGFloat] = [40, 30, 30] {
        didSet { setNeedsLayout() }
    }

    var offset:CGFloat = 5 {
        didSet { setNeedsLayout() }
    }

    var spaceLineColor: UIColor = .white {
        didSet { setNeedsLayout() }
    }

    private var labels: [UILabel] = []
    private var labelSize = CGSize(width: 100, height: 50)
    private var shapeLayers = [CAShapeLayer]()
    private var gradientLayers = [CAGradientLayer]()

    override func layoutSubviews() {
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

            let path = createPath(from: startAngle, to: endAngle, percentage: CGFloat(proportions[i]), pieFilledPercentage: pieFilledPercentages[i])
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

            let label = labelFromPoint(point: getCenterPointOfArc(startAngle: startAngle, endAngle: endAngle), andText: String(format: "%.f", shouldShowTextPercentageFromFieFilledFigures ? pieFilledPercentages[i] * 100 :segments[i]) + "%")
            label.isHidden = !shouldShowLabels
            if proportions[i] != 0 {
                addSubview(label)
                labels.append(label)
            }

            startAngle = endAngle
        }
    }

    private func labelFromPoint(point: CGPoint, andText text: String) -> UILabel {
        let label = UILabel(frame: CGRect(origin: point, size: labelSize))
        label.font = labelTextFont
        label.textColor = labelTextColor
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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

    private func createPath(from startAngle: CGFloat, to endAngle: CGFloat, cornerRadius: CGFloat = 10, percentage: CGFloat, pieFilledPercentage: CGFloat) -> UIBezierPath {

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
        let pieSegmentOuterCornerRadiusInDegrees: CGFloat = 4.0 //for a given segment (and if it's >4° in size), use up 2 of its outer arc's degrees as rounded corners.
        let pieSegmentOuterCornerRadius = arcLengthPerDegree * pieSegmentOuterCornerRadiusInDegrees

        let path = UIBezierPath()

        //move to the centre of the pie chart, offset by the corner radius (so the corner of the segment can be rounded in a bit)
        path.move(to: CGPoint(x: center.x + (cos(startAngle - CGFloat(360).toRadians()) * cornerRadius), y: center.y + (sin(startAngle - CGFloat(360).toRadians()) * cornerRadius)))
        //if the size of the pie segment isn't big enough to warrant rounded outer corners along its outer arc, don't round them off
        if ((endAngle - startAngle).toDegrees() <= (pieSegmentOuterCornerRadiusInDegrees * 2.0)) {
            //add line from centre of pie chart to 1st outer corner of segment
            path.addLine(to: CGPoint(x: center.x + (cos(startAngle - CGFloat(360).toRadians()) * radius), y: center.y + (sin(startAngle - CGFloat(360).toRadians()) * radius)))
            //add arc for segment's outer edge on pie chart
            path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            //move down to the centre of the pie chart, leaving room for rounded corner at the end
            path.addLine(to: CGPoint(x: center.x + (cos(endAngle - CGFloat(360).toRadians()) * cornerRadius), y: center.y + (sin(endAngle - CGFloat(360).toRadians()) * cornerRadius)))
            //add final rounded corner in middle of pie chart
            path.addQuadCurve(to: CGPoint(x: center.x + (cos(startAngle - CGFloat(360).toRadians()) * cornerRadius), y: center.y + (sin(startAngle - CGFloat(360).toRadians()) * cornerRadius)), controlPoint: center)
        } else if percentage == 100 {
            path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        } else { //round the corners on the outer arc
            //add line from centre of pie chart to circumference of segment, minus the space needed for the rounded corner
            path.addLine(to: CGPoint(x: center.x + (cos(startAngle - CGFloat(360).toRadians()) * (radius - pieSegmentOuterCornerRadius)), y: center.y + (sin(startAngle - CGFloat(360).toRadians()) * (radius - pieSegmentOuterCornerRadius))))
            //add rounded corner onto start of outer arc
            let firstRoundedCornerEndOnArc = CGPoint(x: center.x + (cos(startAngle + pieSegmentOuterCornerRadiusInDegrees.toRadians() - CGFloat(360).toRadians()) * radius), y: center.y + (sin(startAngle + pieSegmentOuterCornerRadiusInDegrees.toRadians() - CGFloat(360).toRadians()) * radius))
            path.addQuadCurve(to: firstRoundedCornerEndOnArc, controlPoint: CGPoint(x: center.x + (cos(startAngle - CGFloat(360).toRadians()) * radius), y: center.y + (sin(startAngle - CGFloat(360).toRadians()) * radius)))
            //add arc for segment's outer edge on pie chart
            path.addArc(withCenter: center, radius: radius, startAngle: startAngle + pieSegmentOuterCornerRadiusInDegrees.toRadians(), endAngle: endAngle - pieSegmentOuterCornerRadiusInDegrees.toRadians(), clockwise: true)
            //add rounded corner onto end of outer arc
            let secondRoundedCornerEndOnLine = CGPoint(x: center.x + (cos(endAngle - CGFloat(360).toRadians()) * (radius - pieSegmentOuterCornerRadius)), y: center.y + (sin(endAngle - CGFloat(360).toRadians()) * (radius - pieSegmentOuterCornerRadius)))
            path.addQuadCurve(to: secondRoundedCornerEndOnLine, controlPoint: CGPoint(x: center.x + (cos(endAngle - CGFloat(360).toRadians()) * radius), y: center.y + (sin(endAngle - CGFloat(360).toRadians()) * radius)))
            //add line back to centre point of pie chart, leaving room for rounded corner at the end
            path.addLine(to: CGPoint(x: center.x + (cos(endAngle - CGFloat(360).toRadians()) * cornerRadius), y: center.y + (sin(endAngle - CGFloat(360).toRadians()) * cornerRadius)))
            //add final rounded corner in middle of pie chart
            path.addQuadCurve(to: CGPoint(x: center.x + (cos(startAngle - CGFloat(360).toRadians()) * cornerRadius), y: center.y + (sin(startAngle - CGFloat(360).toRadians()) * cornerRadius)), controlPoint: center)
        }
        path.close()
        //spread the segments out around the pie chart centre
        path.apply(CGAffineTransform(translationX: cos(midPointAngle) * offset, y: -sin(midPointAngle) * offset))
        return path
    }
}

extension CGFloat {
    func toRadians() -> CGFloat {
        return self * CGFloat(Double.pi) / 180.0
    }

    func toDegrees() -> CGFloat {
        return self / (CGFloat(Double.pi) / 180.0)
    }
}

enum GradientDirection {
    case leftRight, rightLeft, topBottom, bottomTop
    case topLeftBottomRight, bottomRightTopLeft, topRightBottomLeft, bottomLeftTopRight

    var points: (start: CGPoint, end: CGPoint) {
        switch self {
            case .leftRight: return (CGPoint(x: 0, y: 0.5), CGPoint(x: 1, y: 0.5))
            case .rightLeft: return (CGPoint(x: 1, y: 0.5), CGPoint(x: 0, y: 0.5))
            case .topBottom: return (CGPoint(x: 0.5, y: 0), CGPoint(x: 0.5, y: 1))
            case .bottomTop: return (CGPoint(x: 0.5, y: 1), CGPoint(x: 0.5, y: 0))
            case .topLeftBottomRight: return (CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 1))
            case .bottomRightTopLeft: return (CGPoint(x: 1, y: 1), CGPoint(x: 0, y: 0))
            case .topRightBottomLeft: return (CGPoint(x: 1, y: 0), CGPoint(x: 0, y: 1))
            case .bottomLeftTopRight: return (CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 0))
        }
    }
}

let pieChartView = PieChartView(frame: CGRect(origin: .zero, size: CGSize(width: 500, height: 500)))
pieChartView.shouldShowLabels = true
pieChartView.shouldHighlightPieOnTouch = true
pieChartView.shouldShowTextPercentageFromFieFilledFigures = true
pieChartView.pieFilledPercentages = [1, 1, 1]
pieChartView.segments = [30,30,40]
pieChartView.pieGradientColors = [
    [UIColor(red: 118/255, green: 190/255, blue: 255/255, alpha: 1.0), UIColor(red: 136/255, green: 107/255, blue: 235/255, alpha: 1.0)],
    [UIColor(red: 255/255, green: 225/255, blue: 86/255, alpha: 1.0), UIColor(red: 254/255, green: 155/255, blue: 39/255, alpha: 1.0)],
    [UIColor(red: 254/255, green: 166/255, blue: 101/255, alpha: 1.0), UIColor(red: 255/255, green: 105/255, blue: 115/255, alpha: 1.0)]
]

let containerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 500, height: 850)))

let slider1 = UISlider(frame: CGRect(origin: CGPoint(x: 0, y: 500), size: CGSize(width: 120, height: 100)))

let slider2 = UISlider(frame: CGRect(origin: CGPoint(x: 0, y: 600), size: CGSize(width: 120, height: 100)))
let slider3 = UISlider(frame: CGRect(origin: CGPoint(x: 0, y: 700), size: CGSize(width: 120, height: 100)))


[slider1, slider2, slider3, pieChartView].forEach(containerView.addSubview(_:))

PlaygroundPage.current.liveView = containerView

