import Brick

extension SPTListPage {

  public func viewModels(_ playlistID: String? = nil, offset: Int = 0) -> [Item] {
    var viewModels = [Item]()
    if let items = items {
      for (index, item) in items.enumerated() {
        if let playlistID = playlistID {
          guard let artists = (item as AnyObject).artists as? [SPTPartialArtist],
            let artist = artists.first?.name,
            let album = (item as AnyObject).album,
            let albumName = album.name
            else { continue }

          let smallImage = album.smallestCover != nil
            ? album.smallestCover.imageURL.absoluteString
            : ""
          let largeImage = album.largestCover != nil
            ? album.largestCover.imageURL.absoluteString
            : ""

          viewModels.append(Item(
            title: (item as AnyObject).name,
            subtitle:  "\(artist) - \(albumName)",
            image: smallImage,
            kind: "playlist",
            action: "play:\(playlistID):\(index + offset)",
            meta: [
              "notification" : (item as AnyObject).name + " by " + artist,
              "track" : (item as AnyObject).name ?? "",
              "artist" : artist,
              "image" : largeImage
            ]
            ))
        } else {
          guard let image = (item as AnyObject).largestImage,
            let uri = (item as AnyObject).uri,
          let subtitle = (item as AnyObject).trackCount,
            image != nil
            else { continue }

          viewModels.append(Item(
            title: (item as AnyObject).name,
            subtitle: "\(subtitle) songs",
            image: (image as SPTImage).imageURL.absoluteString,
            kind: "playlist",
            action: "playlist:" + uri.absoluteString.replace(":", with: "-"))
          )
        }
      }
    }

    return viewModels
  }

  public func uris() -> [URL] {
    var urls = [URL]()
    if let items = items {
      urls = items.map { ($0 as AnyObject).uri }
    }
    return urls
  }
}
