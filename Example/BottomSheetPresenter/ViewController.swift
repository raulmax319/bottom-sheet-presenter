//
//  ViewController.swift
//  BottomSheetPresenter_Example
//
//  Created by Raul Max on 01/16/2023.
//  Copyright (c) 2023 Raul Max. All rights reserved.
//

import BottomSheetPresenter
import UIKit

class ViewController: UIViewController {

  private lazy var button: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Show Modal", for: .normal)

    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    view.backgroundColor = .systemRed

    view.addSubview(button)
    button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    button.widthAnchor.constraint(equalToConstant: 200).isActive = true
    button.heightAnchor.constraint(equalToConstant: 50).isActive = true

    button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
  }

  @objc private func buttonTapped() {
    let modalViewController = ModalViewController()
    modalViewController.modalPresentationStyle = .custom
    modalViewController.transitioningDelegate = self
    present(modalViewController, animated: true, completion: nil)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

extension ViewController: UIViewControllerTransitioningDelegate {
  func presentationController(
    forPresented presented: UIViewController,
    presenting: UIViewController?,
    source: UIViewController
  ) -> UIPresentationController? {
    return BottomSheetPresentationController(
      presentedViewController: presented,
      presenting: presenting
    )
  }
}
