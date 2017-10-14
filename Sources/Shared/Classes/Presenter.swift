import CoreGraphics

public class Presenter<T: View, U: ItemModel> {
  public typealias ConfigurationClosure = ((_ view: T, _ model: U, _ containerSize: CGSize) -> CGSize)

  private let closure: ConfigurationClosure

  public init(closure: @escaping ConfigurationClosure) {
    self.closure = closure
  }

  func configure(_ view: View, _ model: ItemCodable, _ containerSize: CGSize) -> CGSize {
    guard let view = view as? T else {
      return .zero
    }

    guard let model = model as? U else {
      return .zero
    }

    return closure(view, model, containerSize)
  }
}
