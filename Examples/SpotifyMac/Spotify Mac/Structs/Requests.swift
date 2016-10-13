import Malibu

struct PlaylistsRequest: GETRequestable {
  var message = Message(resource: "me/playlists")

  init(offset: Int = 0) {
    message.parameters["offset"] = offset
  }
}

struct PlaylistRequest: GETRequestable {
  var message = Message(resource: "users")
  var etagPolicy: EtagPolicy = .disabled

  init(userID: String, playlistID: String) {
    message.resource = "users/\(userID)/playlists/\(playlistID)"
  }
}

struct FeaturedPlaylists: GETRequestable {
  var message = Message(resource: "browse/featured-playlists")
  var etagPolicy: EtagPolicy = .disabled

  init() {
    message.parameters["country"] = "no"
  }
}

struct NewReleasesRequest: GETRequestable {
  var message = Message(resource: "browse/new-releases")
  var etagPolicy: EtagPolicy = .disabled

  init() {
    message.parameters["country"] = "no"
  }
}

struct CategoriesRequest: GETRequestable {
  var message = Message(resource: "browse/categories")
  var etagPolicy: EtagPolicy = .disabled

  init() {
    message.parameters["country"] = "no"
  }
}

struct CategoryRequest: GETRequestable {
  var message = Message(resource: "browse/categories")
  var etagPolicy: EtagPolicy = .disabled

  init(categoryID: String) {
    message.resource = "browse/categories/\(categoryID)/playlists"
  }

}

struct TracksRequest: GETRequestable {
  var message = Message(resource: "me/tracks")
  var etagPolicy: EtagPolicy = .disabled

  init() {
    message.parameters["limit"] = 50
  }
}

struct FollowingRequest: GETRequestable {
  var message = Message(resource: "me/following")
  var etagPolicy: EtagPolicy = .disabled

  init() {
    message.parameters["limit"] = 50
    message.parameters["type"] = "artist"
  }
}

struct AlbumsRequest: GETRequestable {
  var message = Message(resource: "me/albums")
  var etagPolicy: EtagPolicy = .disabled

  init() {
    message.parameters["limit"] = 50
  }
}

struct AlbumRequest: GETRequestable {
  var message = Message(resource: "albums")
  var etagPolicy: EtagPolicy = .disabled

  init(albumID: String) {
    message.resource = "albums/\(albumID)"
  }
}

struct TopRequest: GETRequestable {
  var message = Message(resource: "top")
  var etagPolicy: EtagPolicy = .disabled

  init(type: String) {
    message.resource = "me/top/\(type)"
  }
}

struct ArtistRequest: GETRequestable {
  var message = Message(resource: "")
  var etagPolicy: EtagPolicy = .disabled

  init(artistID: String) {
    message.resource = "artists/\(artistID)"
  }
}

struct ArtistAlbums: GETRequestable {
  var message = Message(resource: "")
  var etagPolicy: EtagPolicy = .disabled

  init(artistID: String) {
    message.resource = "artists/\(artistID)/albums"
    message.parameters["country"] = "no"
    message.parameters["album_type"] = "album,single"
  }
}

struct ArtistTopTracks: GETRequestable {
  var message = Message(resource: "")
  var etagPolicy: EtagPolicy = .disabled

  init(artistID: String) {
    message.resource = "artists/\(artistID)/top-tracks"
    message.parameters["country"] = "no"
  }
}

struct ArtistRelatedArtists: GETRequestable {
  var message = Message(resource: "")
  var etagPolicy: EtagPolicy = .disabled

  init(artistID: String) {
    message.resource = "artists/\(artistID)/related-artists"
    message.parameters["country"] = "no"
  }
}
