//
//  File.swift
//  
//
//  Created by Phu Phong Ngo on 21/6/2023.
//

import Foundation

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
