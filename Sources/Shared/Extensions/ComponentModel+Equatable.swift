#if os(OSX)
  import Foundation
#else
  import UIKit
#endif

// Compare a collection of view models

/// A collection of ComponentModel Equatable implementation
/// - parameter lhs: Left hand component
/// - parameter rhs: Right hand component
///
/// - returns: A boolean value, true if both ComponentModels are equal
public func == (lhs: [ComponentModel], rhs: [ComponentModel]) -> Bool {
  var equal = lhs.count == rhs.count

  if !equal {
    return false
  }

  for (index, item) in lhs.enumerated() {
    if item != rhs[index] {
      equal = false
      break
    }
  }

  return equal
}

/// Compare two collections of ComponentModels to see if they are truly equal
///
/// - parameter lhs: Left hand component
/// - parameter rhs: Right hand component
///
/// - returns: A boolean value, true if both collections are equal
public func === (lhs: [ComponentModel], rhs: [ComponentModel]) -> Bool {
  var equal = lhs.count == rhs.count

  if !equal {
    return false
  }

  for (index, item) in lhs.enumerated() {
    if item !== rhs[index] {
      equal = false
      break
    }
  }

  return equal
}

/// Check if to collection of components are not equal
///
/// - parameter lhs: Left hand component
/// - parameter rhs: Right hand component
///
/// - returns: A boolean value, true if both ComponentModels are no equal
public func != (lhs: [ComponentModel], rhs: [ComponentModel]) -> Bool {
  return !(lhs == rhs)
}

/// Check if to collection of components are truly not equal
///
/// - parameter lhs: Left hand component
/// - parameter rhs: Right hand component
///
/// - returns: A boolean value, true if both ComponentModels are no equal
public func !== (lhs: [ComponentModel], rhs: [ComponentModel]) -> Bool {
  return !(lhs === rhs)
}

/// Compare view models

/// Check if to components are equal
///
/// - parameter lhs: Left hand component
/// - parameter rhs: Right hand component
///
/// - returns: A boolean value, true if both ComponentModels are no equal
public func == (lhs: ComponentModel, rhs: ComponentModel) -> Bool {
  guard lhs.identifier == rhs.identifier else {
    return false
  }

  let headersAreEqual = optionalCompare(lhs: lhs.header, rhs: rhs.header)
  let footersAreEqual = optionalCompare(lhs: lhs.footer, rhs: rhs.footer)

  let result = headersAreEqual == true &&
    footersAreEqual == true &&
    lhs.kind == rhs.kind &&
    lhs.layout == rhs.layout &&
    (lhs.meta as NSDictionary).isEqual(rhs.meta as NSDictionary)

  return result
}

func optionalCompare(lhs: Item?, rhs: Item?) -> Bool {
  guard let lhsItem = lhs, let rhsItem = rhs else {
    return lhs == nil && rhs == nil
  }

  return lhsItem == rhsItem
}

/// Check if to components are truly equal
///
/// - parameter lhs: Left hand component
/// - parameter rhs: Right hand component
///
/// - returns: A boolean value, true if both ComponentModels are no equal
public func === (lhs: ComponentModel, rhs: ComponentModel) -> Bool {
  guard lhs.identifier == rhs.identifier else {
    return false
  }

  let lhsChildren = lhs.items.flatMap { $0.children.flatMap({ ComponentModel($0) }) }
  let rhsChildren = rhs.items.flatMap { $0.children.flatMap({ ComponentModel($0) }) }

  let headersAreEqual = optionalCompare(lhs: lhs.header, rhs: rhs.header)
  let footersAreEqual = optionalCompare(lhs: lhs.footer, rhs: rhs.footer)

  return headersAreEqual &&
    footersAreEqual &&
    lhs.kind == rhs.kind &&
    lhs.layout == rhs.layout &&
    (lhs.meta as NSDictionary).isEqual(rhs.meta as NSDictionary) &&
    lhsChildren === rhsChildren &&
    lhs.items == rhs.items
}

/// Check if to components are not equal
///
/// - parameter lhs: Left hand component
/// - parameter rhs: Right hand component
///
/// - returns: A boolean value, true if both ComponentModels are no equal
public func != (lhs: ComponentModel, rhs: ComponentModel) -> Bool {
  return !(lhs == rhs)
}

/// Check if to components are truly not equal
///
/// - parameter lhs: Left hand component
/// - parameter rhs: Right hand component
///
/// - returns: A boolean value, true if both ComponentModels are no equal
public func !== (lhs: ComponentModel, rhs: ComponentModel) -> Bool {
  return !(lhs === rhs)
}
