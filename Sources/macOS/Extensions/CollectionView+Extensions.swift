extension CollectionView {
  var flowLayout: FlowLayout? {
    set { collectionViewLayout = newValue }
    get { return collectionViewLayout as? FlowLayout }
  }
}
