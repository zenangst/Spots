import Malibu

struct PlaylistsRequest: GETRequestable {
  var message = Message(resource: "me/playlists")
  var etagPolicy: ETagPolicy = .Disabled

  init(offset: Int = 0) {
    message.parameters["offset"] = offset
  }
}

struct PlaylistRequest: GETRequestable {
  var message = Message(resource: "users")
  var etagPolicy: ETagPolicy = .Disabled

  init(userID: String, playlistID: String) {
    message.resource = "users/\(userID)/playlists/\(playlistID)"
  }
}

struct FeaturedPlaylists: GETRequestable {
  var message = Message(resource: "browse/featured-playlists")
  var etagPolicy: ETagPolicy = .Disabled

  init() {
    message.parameters["country"] = "no"
  }
}

struct NewReleasesRequest: GETRequestable {
  var message = Message(resource: "browse/new-releases")
  var etagPolicy: ETagPolicy = .Disabled

  init() {
    message.parameters["country"] = "no"
  }
}

struct CategoriesRequest: GETRequestable {
  var message = Message(resource: "browse/categories")
  var etagPolicy: ETagPolicy = .Disabled

  init() {
    message.parameters["country"] = "no"
  }
}

struct CategoryRequest: GETRequestable {
  var etagPolicy: ETagPolicy = .Disabled
  var message = Message(resource: "browse/categories")

  init(categoryID: String) {
    message.resource = "browse/categories/\(categoryID)/playlists"
  }

}

struct TracksRequest: GETRequestable {
  var etagPolicy: ETagPolicy = .Disabled
  var message = Message(resource: "me/tracks")

  init() {
    message.parameters["limit"] = 50
  }
}

struct FollowingRequest: GETRequestable {
  var etagPolicy: ETagPolicy = .Disabled
  var message = Message(resource: "me/following")

  init() {
    message.parameters["limit"] = 50
    message.parameters["type"] = "artist"
  }
}

struct AlbumsRequest: GETRequestable {
  var etagPolicy: ETagPolicy = .Disabled
  var message = Message(resource: "me/albums")

  init() {
    message.parameters["limit"] = 50
  }
}

struct AlbumRequest: GETRequestable {
  var etagPolicy: ETagPolicy = .Disabled
  var message = Message(resource: "albums")

  init(albumID: String) {
    message.resource = "albums/\(albumID)"
  }
}

struct TopRequest: GETRequestable {
  var etagPolicy: ETagPolicy = .Disabled
  var message = Message(resource: "top")

  init(type: String) {
    message.resource = "me/top/\(type)"
  }
}

struct ArtistAlbums: GETRequestable {
  var etagPolicy: ETagPolicy = .Disabled
  var message = Message(resource: "")

  init(artistID: String) {
    message.resource = "artists/\(artistID)/albums"
    message.parameters["country"] = "no"
    message.parameters["album_type"] = "album,single"
  }
}

struct ArtistTopTracks: GETRequestable {
  var etagPolicy: ETagPolicy = .Disabled
  var message = Message(resource: "")

  init(artistID: String) {
    message.resource = "artists/\(artistID)/top-tracks"
    message.parameters["country"] = "no"
  }
}

struct ArtistRelatedArtists: GETRequestable {
  var etagPolicy: ETagPolicy = .Disabled
  var message = Message(resource: "")

  init(artistID: String) {
    message.resource = "artists/\(artistID)/related-artists"
    message.parameters["country"] = "no"
  }
}
