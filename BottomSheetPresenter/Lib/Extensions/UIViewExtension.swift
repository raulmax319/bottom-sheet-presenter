//
//  UIViewExtension.swift
//  BottomSheetPresenter
//
//  Created by Raul Max on 28/01/23.
//

import Foundation

extension UIView {
  var width: CGFloat {
    return frame.size.width
  }

  var height: CGFloat {
    return frame.size.height
  }

  var left: CGFloat {
    return frame.origin.x
  }

  var right: CGFloat {
    return left + width
  }

  var top: CGFloat {
    return frame.origin.y
  }

  var bottom: CGFloat {
    return top + height
  }

  func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
    let size = CGSize(width: radius, height: radius)

    let path = UIBezierPath(
      roundedRect: bounds,
      byRoundingCorners: corners,
      cornerRadii: size
    )

    let mask = CAShapeLayer()
    mask.path = path.cgPath
    layer.mask = mask
  }
}
