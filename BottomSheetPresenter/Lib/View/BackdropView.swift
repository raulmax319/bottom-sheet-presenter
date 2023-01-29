//
//  BackdropView.swift
//  BottomSheetPresenter
//
//  Created by Raul Max on 16/01/23.
//

import Foundation
import UIKit

final class BackdropView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = .black
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
