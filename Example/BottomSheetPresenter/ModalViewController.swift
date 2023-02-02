//
//  ModalViewController.swift
//  BottomSheetPresenter_Example
//
//  Created by Raul Max on 28/01/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

final class ModalViewController: UIViewController {
  private lazy var button: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Dismiss Modal", for: .normal)
    button.setTitleColor(.label, for: .normal)

    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    view.addSubview(button)
    button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    button.centerYAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
    button.widthAnchor.constraint(equalToConstant: 200).isActive = true
    button.heightAnchor.constraint(equalToConstant: 50).isActive = true

    button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
  }

  @objc private func buttonTapped() {
    dismiss(animated: true)
  }
}
