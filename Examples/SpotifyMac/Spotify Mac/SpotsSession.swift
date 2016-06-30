import OhMyAuth
import Malibu

struct MeRequest : GETRequestable {
  var message = Message(resource: "/v1/me")
}

public struct SpotsSession {

  let spotifyClientID = "a73161d177934f639fe3b3506d5a1005"
  var userID: Int = 0

  public var isActive: Bool {
    return accessToken != nil
  }

  public var service: AuthService {
    return AuthContainer.serviceNamed("spots")!
  }

  public var accessToken: String? {
    return service.locker.accessToken
  }

  func login() {
    let authString = "https://accounts.spotify.com/authorize/?client_id=\(spotifyClientID)&response_type=code&redirect_uri=spots%3A%2F%2Fcallback&scope=user-read-private%20user-read-email%20user-top-read%20user-library-read%20user-follow-read%20playlist-read-collaborative"
    NSWorkspace.sharedWorkspace().openURL(NSURL(string: authString)!)
  }

  func auth(url: NSURL) {
    if let URLComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false),
      code = URLComponents.queryItems?.filter({ $0.name == "code" }).first?.value {
      AuthContainer.serviceNamed("spots")?.accessToken(parameters: ["code":code]) { accessToken, error in
        NSLog("error: \(error)")
        NSLog("accessToken: \(accessToken)")
      }
      return
    }
  }

}
