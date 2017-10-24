import Foundation
import CoreGraphics

protocol AnyPresenter {
  func configure(view: View, model: ItemCodable, containerSize: CGSize) -> CGSize
}

public class Presenter<V: View, M: ItemModel>: AnyPresenter {
  public typealias ConfigurationClosure = ((_ view: V, _ model: M, _ containerSize: CGSize) -> CGSize)
  let identifier: StringConvertible
  private let closure: ConfigurationClosure

  public init(identifier: StringConvertible, _ closure: @escaping ConfigurationClosure) {
    self.identifier = identifier
    self.closure = closure
  }

  func configure(view: View, model: ItemCodable, containerSize: CGSize) -> CGSize {
    guard let view = view as? V else {
      return .zero
    }

    guard let model = model as? M else {
      return .zero
    }

    return closure(view, model, containerSize)
  }
}
