//
//  UIView+layout.swift
//  GILibrary
//
//  Created by Gin Imor on 1/31/21.
//
//

import UIKit

public protocol AnchorObject: class {
  var defaultAnchoredView: UIView? {get}
  var bottomAnchor: NSLayoutYAxisAnchor {get}
  var centerXAnchor: NSLayoutXAxisAnchor {get}
  var centerYAnchor: NSLayoutYAxisAnchor {get}
  var heightAnchor: NSLayoutDimension {get}
  var leadingAnchor: NSLayoutXAxisAnchor {get}
  var leftAnchor: NSLayoutXAxisAnchor {get}
  var rightAnchor: NSLayoutXAxisAnchor {get}
  var topAnchor: NSLayoutYAxisAnchor {get}
  var trailingAnchor: NSLayoutXAxisAnchor {get}
  var widthAnchor: NSLayoutDimension {get}
}

extension UIView: AnchorObject {
  public var defaultAnchoredView: UIView? { superview }
}
extension UILayoutGuide: AnchorObject {
  public var defaultAnchoredView: UIView? { owningView }
}

public enum HorizontalAnchor {
  case leading, trailing, horizontal, centerX
}

public enum VerticalAnchor {
  case top, bottom, vertical, centerY
}

public enum BaselineAnchor {
  case first, last
}

public enum SizeAnchor {
  case width, height
}

public extension NSLayoutConstraint {
  
  @discardableResult
  func withPriority(value: Float) -> NSLayoutConstraint {
    priority = UILayoutPriority(rawValue: value)
    return self
  }
  
  @discardableResult
  func activate() -> UIView? {
    isActive = true
    return firstItem as? UIView
  }
}

public extension UIView {
  
  convenience init(backgroundColor: UIColor) {
    self.init()
    self.backgroundColor = backgroundColor
  }
  
  @discardableResult
  func disableTAMIC() -> Self {
    translatesAutoresizingMaskIntoConstraints = false
    return self
  }
  
  @discardableResult
  func add(to view: UIView) -> Self {
    view.addSubview(self)
    translatesAutoresizingMaskIntoConstraints = false
    return self
  }
  
  @discardableResult
  func withCH(_ CH: Float, CR: Float, axis: NSLayoutConstraint.Axis) -> Self {
    setContentHuggingPriority(UILayoutPriority(rawValue: CH), for: axis)
    setContentCompressionResistancePriority(UILayoutPriority(rawValue: CR), for: axis)
    return self
  }
  
  @discardableResult
  func withCH(_ priority: Float, axis: NSLayoutConstraint.Axis) -> Self {
    setContentHuggingPriority(UILayoutPriority(rawValue: priority), for: axis)
    return self
  }
  
  @discardableResult
  func withCR(_ priority: Float, axis: NSLayoutConstraint.Axis) -> Self {
    setContentCompressionResistancePriority(UILayoutPriority(rawValue: priority), for: axis)
    return self
  }
  
  @discardableResult
  func baselining(
    _ anchor: BaselineAnchor,
    to linedObject: UIView,
    _ linedAnchor: BaselineAnchor? = nil,
    value: CGFloat = 0,
    constraintHandler: ((NSLayoutConstraint) -> Void)? = nil
  ) -> Self {
    let anchoringObjects = [self, linedObject]
    let anchors = [anchor, linedAnchor ?? anchor]
    var uikitAnchors: [NSLayoutYAxisAnchor] = []
    for i in 0..<2 {
      switch anchors[i] {
      case .first: uikitAnchors[i] = anchoringObjects[i].firstBaselineAnchor
      case .last: uikitAnchors[i] = anchoringObjects[i].lastBaselineAnchor
      }
    }
    let constraint = uikitAnchors[0].constraint(equalTo: uikitAnchors[1], constant: value)
    constraint.isActive = true
    constraintHandler?(constraint)
    return self
  }
  
}

public extension AnchorObject {
  
  @discardableResult
  func hLining(
    _ anchor: HorizontalAnchor,
    to linedObject: AnchorObject? = nil,
    _ linedAnchor: HorizontalAnchor? = nil,
    value: CGFloat = 0,
    constraintsHandler: (([NSLayoutConstraint]) -> Void)? = nil
  ) -> Self {
    let potentialLinedObject: AnchorObject?
    if #available(iOS 11.0, *) {
      potentialLinedObject = defaultAnchoredView?.safeAreaLayoutGuide
    } else {
      potentialLinedObject = defaultAnchoredView
    }
    guard let _linedObject = linedObject ?? potentialLinedObject else { return self }
    var constraints = [NSLayoutConstraint]()
    if anchor == .horizontal {
      constraints.append(leadingAnchor.constraint(equalTo: _linedObject.leadingAnchor, constant: value))
      constraints.append(trailingAnchor.constraint(equalTo: _linedObject.trailingAnchor, constant: -value))
    } else {
      let _linedAnchor = linedAnchor ?? anchor
      let anchoringObjects = [self, _linedObject]
      let anchors = [anchor, _linedAnchor]
      var uikitAnchors: [NSLayoutXAxisAnchor] = []
      for i in 0..<2 {
        switch anchors[i] {
        case .leading: uikitAnchors.append(anchoringObjects[i].leadingAnchor)
        case .trailing: uikitAnchors.append(anchoringObjects[i].trailingAnchor)
        case .centerX: uikitAnchors.append(anchoringObjects[i].centerXAnchor)
        case .horizontal: return self
        }
      }
      constraints.append(uikitAnchors[0].constraint(equalTo: uikitAnchors[1], constant: value))
    }
    NSLayoutConstraint.activate(constraints)
    constraintsHandler?(constraints)
    return self
  }
  
  @discardableResult
  func vLining(
    _ anchor: VerticalAnchor,
    to linedObject: AnchorObject? = nil,
    _ linedAnchor: VerticalAnchor? = nil,
    value: CGFloat = 0,
    constraintsHandler: (([NSLayoutConstraint]) -> Void)? = nil
  ) -> Self {
    let potentialLinedObject: AnchorObject?
    if #available(iOS 11.0, *) {
      potentialLinedObject = defaultAnchoredView?.safeAreaLayoutGuide
    } else {
      potentialLinedObject = defaultAnchoredView
    }
    guard let _linedObject = linedObject ?? potentialLinedObject else { return self }
    let constraints: [NSLayoutConstraint]
    if anchor == .vertical {
      constraints = [
        topAnchor.constraint(equalTo: _linedObject.topAnchor, constant: value),
        bottomAnchor.constraint(equalTo: _linedObject.bottomAnchor, constant: -value)
      ]
    } else {
      let _linedAnchor = linedAnchor ?? anchor
      let anchoringObjects = [self, _linedObject]
      let anchors = [anchor, _linedAnchor]
      var uikitAnchors: [NSLayoutYAxisAnchor] = []
      for i in 0..<2 {
        switch anchors[i] {
        case .top: uikitAnchors.append(anchoringObjects[i].topAnchor)
        case .bottom: uikitAnchors.append(anchoringObjects[i].bottomAnchor)
        case .centerY: uikitAnchors.append(anchoringObjects[i].centerYAnchor)
        case .vertical: return self
        }
      }
      constraints = [uikitAnchors[0].constraint(equalTo: uikitAnchors[1], constant: value)]
    }
    NSLayoutConstraint.activate(constraints)
    constraintsHandler?(constraints)
    return self
  }
  
  @discardableResult
  func filling(
    _ filledObject: AnchorObject? = nil,
    edgeInsets: UIEdgeInsets = .zero,
    constraintsHandler: (([NSLayoutConstraint]) -> Void)? = nil
  ) -> Self {
    let potentialFilledObject: AnchorObject?
    if #available(iOS 11.0, *) {
      potentialFilledObject = defaultAnchoredView?.safeAreaLayoutGuide
    } else {
      potentialFilledObject = defaultAnchoredView
    }
    guard let _filledObject = filledObject ?? potentialFilledObject else { return self }
    let constraints = [
      topAnchor.constraint(equalTo: _filledObject.topAnchor, constant: edgeInsets.top),
      leadingAnchor.constraint(equalTo: _filledObject.leadingAnchor, constant: edgeInsets.left),
      bottomAnchor.constraint(equalTo: _filledObject.bottomAnchor, constant: -edgeInsets.bottom),
      trailingAnchor.constraint(equalTo: _filledObject.trailingAnchor, constant: -edgeInsets.right)
    ]
    NSLayoutConstraint.activate(constraints)
    constraintsHandler?(constraints)
    return self
  }
  
  @discardableResult
  func centering(
    _ centeredObject: AnchorObject? = nil,
    vector: CGVector = .zero,
    constraintsHandler: (([NSLayoutConstraint]) -> Void)? = nil
  ) -> Self {
    let potentialCenteredObject: AnchorObject?
    if #available(iOS 11.0, *) {
      potentialCenteredObject = defaultAnchoredView?.safeAreaLayoutGuide
    } else {
      potentialCenteredObject = defaultAnchoredView
    }
    guard let _centeredObject = centeredObject ?? potentialCenteredObject else { return self }
    let constraints = [
      centerXAnchor.constraint(equalTo: _centeredObject.centerXAnchor, constant: vector.dx),
      centerYAnchor.constraint(equalTo: _centeredObject.centerYAnchor, constant: vector.dy)
    ]
    NSLayoutConstraint.activate(constraints)
    constraintsHandler?(constraints)
    return self
  }
  
  @discardableResult
  func sizing(
    to sizedObject: AnchorObject? = nil,
    widthMultiplier: CGFloat = 1.0,
    widthDelta: CGFloat = 0,
    heightMultiplier: CGFloat = 1.0,
    heightDelta: CGFloat = 0,
    constraintsHandler: (([NSLayoutConstraint]) -> Void)? = nil
) -> Self {
    let potentialSizedObject: AnchorObject?
    if #available(iOS 11.0, *) {
      potentialSizedObject = defaultAnchoredView?.safeAreaLayoutGuide
    } else {
      potentialSizedObject = defaultAnchoredView
    }
    guard let _sizedObject = sizedObject ?? potentialSizedObject else { return self }
    let constraints = [
      widthAnchor.constraint(equalTo: _sizedObject.widthAnchor, multiplier: widthMultiplier, constant: widthDelta),
      heightAnchor.constraint(equalTo: _sizedObject.heightAnchor, multiplier: heightMultiplier, constant: heightDelta)
    ]
    NSLayoutConstraint.activate(constraints)
    constraintsHandler?(constraints)
    return self
  }
  
  @discardableResult
  func sizing(
    _ anchor: SizeAnchor,
    to sizedObject: AnchorObject? = nil,
    _ sizedAnchor: SizeAnchor? = nil,
    multiplier: CGFloat = 1.0,
    delta: CGFloat = 0,
    constraintsHandler: (([NSLayoutConstraint]) -> Void)? = nil
  ) -> Self {
    guard let _sizedObject = sizedObject ?? defaultAnchoredView else { return self }
    let _sizedAnchor = sizedAnchor ?? anchor
    let anchoringObjects = [self, _sizedObject]
    let anchors = [anchor, _sizedAnchor]
    var uikitAnchors: [NSLayoutDimension] = []
    for i in 0..<2 {
      switch anchors[i] {
      case .width: uikitAnchors.append(anchoringObjects[i].widthAnchor)
      case .height: uikitAnchors.append(anchoringObjects[i].heightAnchor)
      }
    }
    let constraint = uikitAnchors[0].constraint(equalTo: uikitAnchors[1], multiplier: multiplier, constant: delta)
    constraint.isActive = true
    constraintsHandler?([constraint])
    return self
  }
  
  @discardableResult
  func sizing(
    width: CGFloat = 0,
    height: CGFloat = 0,
    constraintsHandler: (([NSLayoutConstraint]) -> Void)? = nil
  ) -> Self {
    var constraints = [NSLayoutConstraint]()
    if width > 0 { constraints.append(widthAnchor.constraint(equalToConstant: width)) }
    if height > 0 { constraints.append(heightAnchor.constraint(equalToConstant: height)) }
    NSLayoutConstraint.activate(constraints)
    constraintsHandler?(constraints)
    return self
  }
  
  @discardableResult
  func sizing(
    to value: CGFloat,
    constraintsHandler: (([NSLayoutConstraint]) -> Void)? = nil
  ) -> Self {
    var constraints = [NSLayoutConstraint]()
    if value > 0 {
      constraints.append(widthAnchor.constraint(equalToConstant: value))
      constraints.append(heightAnchor.constraint(equalToConstant: value))
    }
    NSLayoutConstraint.activate(constraints)
    constraintsHandler?(constraints)
    return self
  }
  
}
