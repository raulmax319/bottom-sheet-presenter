//
//  BottomSheetPresentationController.swift
//  BottomSheetPresenter
//
//  Created by Raul Max on 16/01/23.
//

import Foundation
import UIKit

final public class BottomSheetPresentationController: UIPresentationController {
  private enum PresentationPosition {
    case top
    case middle
    case bottom

    func setYCenter(for containerView: UIView, with height: CGFloat) -> CGFloat {
      switch self {
      case .top:
        return .zero
      case .middle:
        return .zero
      case .bottom:
        return .zero
      }
    }
  }

  private var initialPosition: CGPoint = .zero
  private var presentediViewPosition: PresentationPosition = .top

  private lazy var backdropView: BackdropView = {
    return BackdropView()
  }()

  private var tapGestureRecognizer: UITapGestureRecognizer {
    return UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
  }

  private var panGestureRecognizer: UIPanGestureRecognizer {
    return UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
  }

  public override var frameOfPresentedViewInContainerView: CGRect {
    guard let containerView else {
      return .zero
    }

    let height = containerView.bounds.height
    let width = containerView.bounds.width
    var y: CGFloat

    switch presentediViewPosition {
    case .top:
      y = containerView.safeAreaInsets.top
    case .middle:
      y = containerView.bounds.height - height * 0.6
    case .bottom:
      y = containerView.bounds.height - height * 0.3
    }

    return CGRect(x: 0, y: y, width: width, height: height)
  }

  override public init(
    presentedViewController: UIViewController,
    presenting presentingViewController: UIViewController?
  ) {
    super.init(
      presentedViewController: presentedViewController,
      presenting: presentingViewController
    )

    setupBackdropView()
    setupPresentedView()
  }
}

// MARK: - Private
extension BottomSheetPresentationController {
  private func setupBackdropView() {
    backdropView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    backdropView.isUserInteractionEnabled = true
    backdropView.addGestureRecognizer(tapGestureRecognizer)
  }

  private func setupPresentedView() {
    presentedView?.isUserInteractionEnabled = true
    presentedView?.addGestureRecognizer(panGestureRecognizer)
  }

  @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
    presentedViewController.dismiss(animated: true, completion: nil)
  }

  @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
    guard let presentedView, let containerView else {
      return
    }

    let percentThreshold = 0.3
    let translation = gesture.translation(in: containerView)

    let verticalMovement = translation.y / (containerView.bounds.height - containerView.safeAreaInsets.top)
    let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
    let movementPercent = fminf(downwardMovement, 1.0)

    let progress = CGFloat(movementPercent)

    switch gesture.state {
    case .began:
      initialPosition = presentedView.center
    case .changed:

      switch presentediViewPosition {
      case .top:
        guard translation.y > 0 else {
          return
        }

        presentedView.center = CGPoint(
          x: initialPosition.x,
          y: initialPosition.y + translation.y
        )
      case .middle:
        presentedView.center = CGPoint(
          x: initialPosition.x,
          y: initialPosition.y + translation.y
        )
      case .bottom:
        guard translation.y < 0 else {
          return
        }

        presentedView.center = CGPoint(
          x: initialPosition.x,
          y: initialPosition.y + translation.y
        )
      }
    case .ended,
         .cancelled:
      switch presentediViewPosition {
      case .top:
        if progress > percentThreshold {
          UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.7,
            animations: {
              let center = containerView.center
              presentedView.center = CGPoint(x: center.x, y: center.y + self.initialPosition.y)
            }) { [unowned self] success in
              presentediViewPosition = .middle
            }
        } else {
          UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.7,
            animations: {
              presentedView.center = self.initialPosition
            }
          )
        }
      case .middle:
        break
      case .bottom:
        break
      }
    default:
      break
    }
  }
}

// MARK: - PresentationTransition
extension BottomSheetPresentationController {
    public override func presentationTransitionWillBegin() {
    backdropView.alpha = 0.0
    containerView?.addSubview(backdropView)

    presentedViewController.transitionCoordinator?.animate(
      alongsideTransition: { [unowned self] _ in
        self.backdropView.alpha = 0.75
      },
      completion: nil
    )
  }

    public override func dismissalTransitionWillBegin() {
    presentedViewController.transitionCoordinator?.animate(
      alongsideTransition: { [unowned self] _ in
        self.backdropView.alpha = 0.0
      },
      completion: nil
    )
  }
}

// MARK: - ContainerViewLayout
extension BottomSheetPresentationController {
    public override func containerViewWillLayoutSubviews() {
    super.containerViewWillLayoutSubviews()

      presentedView?.roundCorners(
        [.topLeft, .topRight, .bottomLeft, .bottomRight],
        radius: 15
      )
  }

    public override func containerViewDidLayoutSubviews() {
    super.containerViewDidLayoutSubviews()

    presentedView?.frame = frameOfPresentedViewInContainerView
    backdropView.frame = containerView?.bounds ?? .zero
  }
}