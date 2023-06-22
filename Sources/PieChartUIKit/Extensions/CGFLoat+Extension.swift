//
//  CGFLoat+Extension.swift
//  PieChartUIKit
//
//  Created by Phu Phong Ngo on 22/6/2023.
//

import Foundation

extension CGFloat {
    func toRadians() -> CGFloat {
        return self * CGFloat(Double.pi) / 180.0
    }

    func toDegrees() -> CGFloat {
        return self / (CGFloat(Double.pi) / 180.0)
    }
}
