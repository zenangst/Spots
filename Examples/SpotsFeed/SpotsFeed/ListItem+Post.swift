import UIKit
import Brick

extension ViewModel {

  var post: Post {
    get {
      let item = self
      let avatarURL = NSURL(string: item.image)!
      let author = Author(name: item.title, avatar: avatarURL)

      var mediaItems = [Media]()
      if let strings = item.meta["media"] as? [String] {
        for mediaString in strings {
          let url = NSURL(string: mediaString)!
          let media = Media(kind: Media.Kind.Image, source: url)
          mediaItems.append(media)
        }
      }

      return Post(id: 0, text: item.subtitle, publishDate: "", author: author, media: mediaItems)
    }
  }

}
