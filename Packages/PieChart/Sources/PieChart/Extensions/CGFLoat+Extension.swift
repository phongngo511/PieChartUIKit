//
//  CGFLoat+Extension.swift
//  PieChart
//
//  Created by Phu Phong Ngo on 21/6/2023.
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
