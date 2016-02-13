import Spots

extension SPTListPage {

  public func viewModels(playlistID: String? = nil, offset: Int = 0) -> [ViewModel] {
    var viewModels = [ViewModel]()
    if let items = items {
      for (index, item) in items.enumerate() {
        if let playlistID = playlistID {
          guard let artists = item.artists as? [SPTPartialArtist],
            artist = artists.first,
            album = item.album
            else { continue }

          viewModels.append(ViewModel(
            title: item.name,
            subtitle:  "\(artist.name) - \(album.name)",
            image: album.largestCover.imageURL.absoluteString,
            kind: "playlist",
            action: "play:\(playlistID):\(index + offset)",
            meta: [
              "notification" : "\(item.name) by \(artist.name)",
              "track" : item.name,
              "artist" : artist.name,
              "image" : album.largestCover.imageURL.absoluteString
            ]
            ))
        } else {
          guard let image = item.largestImage,
            uri = item.uri
            where image != nil
            else { continue }

          viewModels.append(ViewModel(
            title: item.name,
            subtitle: "\(item.trackCount) songs",
            image: (image as SPTImage).imageURL.absoluteString,
            kind: "playlist",
            action: "playlist:" + uri.absoluteString.replace(":", with: "-"))
          )
        }
      }
    }

    return viewModels
  }

  public func uris() -> [NSURL] {
    var urls = [NSURL]()
    if let items = items {
      urls = items.map { $0.uri }
    }
    return urls
  }
}
