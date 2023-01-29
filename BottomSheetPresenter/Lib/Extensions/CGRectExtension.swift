//
//  CGRectExtension.swift
//  BottomSheetPresenter
//
//  Created by Raul Max on 29/01/23.
//

import Foundation

extension CGRect {
  var width: CGFloat {
    return size.width
  }

  var height: CGFloat {
    return size.height
  }

  var left: CGFloat {
    return origin.x
  }

  var right: CGFloat {
    return left + width
  }

  var top: CGFloat {
    return origin.y
  }

  var bottom: CGFloat {
    return top + height
  }
}
