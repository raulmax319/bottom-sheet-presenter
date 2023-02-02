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
  }

  private var initialPosition: CGRect = .zero
  private var percentThreshold: CGFloat = 0.15
  private var presentediViewPosition: PresentationPosition = .bottom

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
      y = height - (height * 0.9)
    case .middle:
      y = height - (height * 0.6)
    case .bottom:
      y = height - (height * 0.3)
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
    presentedViewController.dismiss(animated: true)
  }

  private func beginAnimation(
    in presentedView: UIView,
    at position: PresentationPosition,
    with yOffset: CGFloat
  ) {
    guard let containerView else {
      return
    }

    UIView.animate(
      withDuration: 0.5,
      delay: 0.0,
      usingSpringWithDamping: 0.7,
      initialSpringVelocity: 0.7,
      animations: {
        let oldFrame = presentedView.frame
        let containerFrame = containerView.frame
        let newY = containerView.bounds.height - containerView.bounds.height * yOffset
        presentedView.frame = CGRect(origin: CGPoint(x: containerFrame.left, y: newY), size: oldFrame.size)
      }) { [unowned self] success in
        presentediViewPosition = position
      }
  }

  private func resetPosition(in view: UIView) {
    UIView.animate(
      withDuration: 0.5,
      delay: 0.0,
      usingSpringWithDamping: 0.7,
      initialSpringVelocity: 0.7,
      animations: {
        view.frame = self.initialPosition
      }
    )
  }

  private func updatePosition(at origin: CGPoint) {
    guard let presentedView else {
      return
    }

    let oldFrame = presentedView.frame
    presentedView.frame = CGRect(origin: origin, size: oldFrame.size)
  }

  private func endMovement(with progress: CGFloat) {
    guard let presentedView else {
      return
    }

    switch presentediViewPosition {
    case .top:
      if progress >= percentThreshold {
        beginAnimation(
          in: presentedView,
          at: .middle,
          with: 0.6
        )
      } else {
        resetPosition(in: presentedView)
      }
    case .middle:
      if progress < 0, abs(progress) >= percentThreshold {
        beginAnimation(
          in: presentedView,
          at: .top,
          with: 0.9
        )
      } else if progress > 0, progress >= percentThreshold {
        beginAnimation(
          in: presentedView,
          at: .bottom,
          with: 0.3
        )
      } else {
        resetPosition(in: presentedView)
      }
    case .bottom:
      if progress < 0, abs(progress) >= percentThreshold {
        beginAnimation(
          in: presentedView,
          at: .middle,
          with: 0.6
        )
      } else if progress > 0, progress >= percentThreshold {
        presentedViewController.dismiss(animated: true)
      } else {
        resetPosition(in: presentedView)
      }
    }
  }

  private func moveView(with translation: CGPoint) {
    switch presentediViewPosition {
    case .top:
      guard translation.y > 0 else {
        return
      }

      let origin = CGPoint(x: initialPosition.left, y: initialPosition.top + translation.y)
      updatePosition(at: origin)
    case .middle:
      let origin = CGPoint(x: initialPosition.left, y: initialPosition.top + translation.y)
      updatePosition(at: origin)
    case .bottom:
      let origin = CGPoint(x: initialPosition.left, y: initialPosition.top + translation.y)
      updatePosition(at: origin)
    }
  }

  @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
    guard let presentedView, let containerView else {
      return
    }

    let translation = gesture.translation(in: containerView)

    let verticalMovement = translation.y / (containerView.bounds.height - containerView.safeAreaInsets.top)
    let movementPercent = fminf(Float(verticalMovement), 1.0)

    let progress = CGFloat(movementPercent)

    switch gesture.state {
    case .began:
      initialPosition = presentedView.frame
    case .changed:
      moveView(with: translation)
    case .ended,
        .cancelled:
      endMovement(with: progress)
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
      [.topLeft, .topRight],
      radius: 15
    )
  }

  public override func containerViewDidLayoutSubviews() {
    super.containerViewDidLayoutSubviews()

    presentedView?.frame = frameOfPresentedViewInContainerView
    backdropView.frame = containerView?.bounds ?? .zero
  }
}
