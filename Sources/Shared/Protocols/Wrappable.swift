public protocol Wrappable: class {

  var contentView: View { get }
  var wrappedView: View? { get set }

  func configure(with view: View)
  func configureWrappedView()
}
