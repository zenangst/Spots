import CoreGraphics

public protocol Wrappable: class {

  var bounds: CGRect { get }
  var contentView: View { get }
  var wrappedView: View? { get set }

  func configure(with view: View)
  func configureWrappedView()
}
