# PieChartUIKit

![iOS 14.0+](https://img.shields.io/badge/iOS-14.0%2B-blue.svg)
![Swift 5.0+](https://img.shields.io/badge/Swift-5.0%2B-orange.svg)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/phongngo511/PieChartUIKit/blob/main/LICENSE?raw=true)

PieChartUIKit is a simple solution writen purely in Swift allowing to draw colorful Pie Charts with several customization options, such as gradient colors, spacing, hightlights, corner radius and more.

## Frameworks

CoreGraphics, CoreAnimation

UIBezierPath, CAGradientLayer, CAShapeLayer, QuadCurve

## Screenshots

<img src="https://github.com/phongngo511/PieChartUIKit/blob/main/SampleOutput.gif" width="250" height="550">

## Usage

1. Init `PieChartView`

```swift
/// Init PieChartView from Code
let pieChartView = PieChartView(frame: CGRect(origin: CGPoint(x: 50, y: 150), size: CGSize(width: 300, height: 300)))

```
2. Setup Constraints

```swift
/// Add constraints to PieChartView
pieChartView.translatesAutoresizingMaskIntoConstraints = false
pieChartView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
pieChartView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
pieChartView.widthAnchor.constraint(equalToConstant: 300).isActive = true
pieChartView.heightAnchor.constraint(equalToConstant: 300).isActive = true
```
3. Setup properties

```swift
/// Add properties to PieChartView
pieChartView.shouldShowPercentageLabel = true
pieChartView.shouldHighlightPieOnTouch = true
pieChartView.percentageLabelType = .segment
pieChartView.pieFilledPercentages = [90, 60, 80]
pieChartView.segments = [40, 30, 30]
pieChartView.pieGradientColors = [
    [UIColor(red: 118/255, green: 190/255, blue: 255/255, alpha: 1.0), UIColor(red: 136/255, green: 107/255, blue: 235/255, alpha: 1.0)],
    [UIColor(red: 255/255, green: 225/255, blue: 86/255, alpha: 1.0), UIColor(red: 254/255, green: 155/255, blue: 39/255, alpha: 1.0)],
    [UIColor(red: 254/255, green: 166/255, blue: 101/255, alpha: 1.0), UIColor(red: 255/255, green: 105/255, blue: 115/255, alpha: 1.0)]
]
```
4. Add `PieChartView` as `Subview`

```swift
/// Add it as subview
view.addSubview(pieChartView)
```

## UI Customizantion 

### Pie Gradient Colors
```swift
pieChartView.pieGradientColors = [gradientColors...]
```

### Pie Fill Proportions
```swift
pieChartView.pieFilledPercentages = [1, 0.8, 0.7]
```

### Pie Segments
```swift
pieChartView.segments = [40, 30, 30]
```

### Segment Spacing
```swift
pieChartView.offset = 5
```

### Inner corner radius
```swift
pieChartView.segmentInnerCornerRadius = 8

```

### Outer corner radius
```swift
pieChartView.segmentOuterCornerRadius = 6

```

### Pie Interactions
```swift
pieChartView.onTouchPie = {[weak self] sliceIndex in
    // your code with sliceIndex
}
```

## License
`PieChartUIKit` is available under the MIT License. See the `LICENSE` file for more info.