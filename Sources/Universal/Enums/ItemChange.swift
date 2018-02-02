/// Determines how severe the update of an item is.
///
/// - hard: The data source will have to dequque a new view.
/// - medium: The view type can be reused but the content update changed the size.
///           The data source will have to invoke an update to get the new size on the cell.
/// - soft: Neither the view type or size did change, new data can cleanly be aggregated to the view.
enum ItemChange {
  case hard
  case medium
  case soft
}
