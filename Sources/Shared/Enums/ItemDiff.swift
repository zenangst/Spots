public enum ItemDiff {
  case identifier, index, title, subtitle, text, image, kind, action, meta, relations, size, new, removed, none, move(Int, Int)
}
