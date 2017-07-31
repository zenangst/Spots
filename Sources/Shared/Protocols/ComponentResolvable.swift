/// ComponentResolvable is used to safely and easily resolve the component instance.
/// This is used to reduce the amount of guard's when DataSource and Delegate needs access
/// to the components data.
/// For more information about what `ComponentResolvable` adds, see `ComponentResolvable+Extensions`.
protocol ComponentResolvable {
  /// An optional component instance.
  var component: Component? { get }
}
