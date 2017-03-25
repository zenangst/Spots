/// A component diff enum
///
/// - identifier: Indicates that the identifier changed
/// - kind:       Indicates that the kind changed
/// - layout:     Indicates that the layout changed
/// - header:     Indicates that the header changed
/// - footer:     Indicates that the footer changed
/// - meta:       Indicates that the meta changed
/// - items:      Indicates that the items changed
/// - new:        Indicates that the component is new
/// - removed:    Indicates that the component was removed
/// - none:       Indicates that nothing did change
public enum ComponentModelDiff {
  case identifier, kind, layout, header, footer, meta, items, new, removed, none
}
