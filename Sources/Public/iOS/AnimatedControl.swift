//
//  AnimatedControl.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 2/4/19.
//

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)
import UIKit

/// Lottie comes prepacked with a two Animated Controls, `AnimatedSwitch` and
/// `AnimatedButton`. Both of these controls are built on top of `AnimatedControl`
///
/// `AnimatedControl` is a subclass of `UIControl` that provides an interactive
/// mechanism for controlling the visual state of an animation in response to
/// user actions.
///
/// The `AnimatedControl` will show and hide layers depending on the current
/// `UIControl.State` of the control.
///
/// Users of `AnimationControl` can set a Layer Name for each `UIControl.State`.
/// When the state is change the `AnimationControl` will change the visibility
/// of its layers.
///
/// NOTE: Do not initialize directly. This is intended to be subclassed.
open class AnimatedControl: UIControl {

  // MARK: Lifecycle

  // MARK: Initializers

  public init(
    animation: Animation,
    configuration: LottieConfiguration = .shared)
  {
    animationView = AnimationView(
      animation: animation,
      configuration: configuration)

    super.init(frame: animation.bounds)
    commonInit()
  }

  public init() {
    animationView = AnimationView()
    super.init(frame: .zero)
    commonInit()
  }

  required public init?(coder aDecoder: NSCoder) {
    animationView = AnimationView()
    super.init(coder: aDecoder)
    commonInit()
  }

  // MARK: Open

  // MARK: UIControl Overrides

  open override var isEnabled: Bool {
    didSet {
      updateForState()
    }
  }

  open override var isSelected: Bool {
    didSet {
      updateForState()
    }
  }

  open override var isHighlighted: Bool {
    didSet {
      updateForState()
    }
  }

  open override var intrinsicContentSize: CGSize {
    animationView.intrinsicContentSize
  }

  open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    updateForState()
    return super.beginTracking(touch, with: event)
  }

  open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    updateForState()
    return super.continueTracking(touch, with: event)
  }

  open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    updateForState()
    return super.endTracking(touch, with: event)
  }

  open override func cancelTracking(with event: UIEvent?) {
    updateForState()
    super.cancelTracking(with: event)
  }

  open func animationDidSet() {

  }

  // MARK: Public

  /// The animation view in which the animation is rendered.
  public let animationView: AnimationView

  /// The animation backing the animated control.
  public var animation: Animation? {
    didSet {
      animationView.animation = animation
      animationView.bounds = animation?.bounds ?? .zero
      setNeedsLayout()
      updateForState()
      animationDidSet()
    }
  }

  /// The speed of the animation playback. Defaults to 1
  public var animationSpeed: CGFloat {
    set { animationView.animationSpeed = newValue }
    get { animationView.animationSpeed }
  }

  /// Sets which Animation Layer should be visible for the given state.
  public func setLayer(named: String, forState: UIControl.State) {
    stateMap[forState.rawValue] = named
    updateForState()
  }

  /// Sets a ValueProvider for the specified keypath
  public func setValueProvider(_ valueProvider: AnyValueProvider, keypath: AnimationKeypath) {
    animationView.setValueProvider(valueProvider, keypath: keypath)
  }

  // MARK: Internal

  var stateMap: [UInt: String] = [:]

  func updateForState() {
    guard let animationLayer = animationView.animationLayer else { return }
    if
      let layerName = stateMap[state.rawValue],
      let stateLayer = animationLayer.layer(for: AnimationKeypath(keypath: layerName))
    {
      for layer in animationLayer._animationLayers {
        layer.isHidden = true
      }
      stateLayer.isHidden = false
    } else {
      for layer in animationLayer._animationLayers {
        layer.isHidden = false
      }
    }
  }

  // MARK: Private

  private func commonInit() {
    animationView.clipsToBounds = false
    clipsToBounds = true
    animationView.translatesAutoresizingMaskIntoConstraints = false
    animationView.backgroundBehavior = .forceFinish
    addSubview(animationView)
    animationView.contentMode = .scaleAspectFit
    animationView.isUserInteractionEnabled = false
    animationView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    animationView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    animationView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    animationView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
  }
}
#endif
