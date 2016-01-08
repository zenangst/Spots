/*
 Copyright 2015 Spotify AB

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <Foundation/Foundation.h>

///----------------------------
/// @name Scope constants, see: https://developer.spotify.com/web-api/using-scopes/
///----------------------------

/** Scope that lets you stream music. */
FOUNDATION_EXPORT NSString * const SPTAuthStreamingScope;

/** Scope that lets you read private playlists of the authenticated user. */
FOUNDATION_EXPORT NSString * const SPTAuthPlaylistReadPrivateScope;

/** Scope that lets you modify public playlists of the authenticated user. */
FOUNDATION_EXPORT NSString * const SPTAuthPlaylistModifyPublicScope;

/** Scope that lets you modify private playlists of the authenticated user. */
FOUNDATION_EXPORT NSString * const SPTAuthPlaylistModifyPrivateScope;

/** Scope that lets you follow artists and users on behalf of the authenticated user. */
FOUNDATION_EXPORT NSString * const SPTAuthUserFollowModifyScope;

/** Scope that lets you get a list of artists and users the authenticated user is following. */
FOUNDATION_EXPORT NSString * const SPTAuthUserFollowReadScope;

/** Scope that lets you read user's Your Music library. */
FOUNDATION_EXPORT NSString * const SPTAuthUserLibraryReadScope;

/** Scope that lets you modify user's Your Music library. */
FOUNDATION_EXPORT NSString * const SPTAuthUserLibraryModifyScope;

/** Scope that lets you read the private user information of the authenticated user. */
FOUNDATION_EXPORT NSString * const SPTAuthUserReadPrivateScope;

/** Scope that lets you get the birthdate of the authenticated user. */
FOUNDATION_EXPORT NSString * const SPTAuthUserReadBirthDateScope;

/** Scope that lets you get the email address of the authenticated user. */
FOUNDATION_EXPORT NSString * const SPTAuthUserReadEmailScope;

FOUNDATION_EXPORT NSString * const SPTAuthSessionUserDefaultsKey;

@class SPTSession;

/**
 This class provides helper methods for authenticating users against the Spotify OAuth
 authentication service.
 */
@interface SPTAuth : NSObject

/** The authentication result callback
 @param error An `NSError` object if an error occurred, is `nil` if no error.
 @param session An `SPTSession` object containing information about the user.
 */
typedef void (^SPTAuthCallback)(NSError *error, SPTSession *session);

///----------------------------
/// @name Convenience Getters
///----------------------------

/**
 Returns a pre-created `SPTAuth` instance for convenience.

 @return A pre-created default `SPTAuth` instance.
 */
+(SPTAuth *)defaultInstance;


///----------------------------
/// @name Environment settings
///----------------------------

/**
 Your client ID.
 */
@property (strong, readwrite) NSString *clientID;

/**
 Your redirect URL.
 */
@property (strong, readwrite) NSURL *redirectURL;

/**
 Required scopes for the app, used by authentication steps
 */
@property (strong, readwrite) NSArray *requestedScopes;

/**
 The current session, Note: setting this will persist it in `NSUserDefaults standardUserDefaults` if
 a `sessionUserDefaultsKey` is set.
 */
@property (strong, readwrite) SPTSession *session;

/**
 User defaults key, if you want to automatically save the session from user defaults when it changes.
 */
@property (strong, readwrite) NSString *sessionUserDefaultsKey;

/**
 Your token swap URL, if not specified the authentication flow will be limited to implicit grant flow.
 */
@property (strong, readwrite) NSURL *tokenSwapURL;

/**
 Your token refresh URL, if not specified the refresh token flow will be disabled.
 */
@property (strong, readwrite) NSURL *tokenRefreshURL;

/**
 Returns true if there's a valid token swap url specified.
 */
@property (readonly) BOOL hasTokenSwapService;

/**
 Returns true if there's a valid token refresh url specified.
 */
@property (readonly) BOOL hasTokenRefreshService;

///----------------------------
/// @name Starting Authentication
///----------------------------

/**
 A URL that, when opened, will begin the Spotify authentication process.
 */
@property (readonly) NSURL *loginURL;


/**
 Returns a URL that, when opened, will begin the Spotify authentication process.

 @warning You must open this URL with the system handler to have the auth process
 happen in Safari. Displaying this inside your application is against the Spotify ToS.

 @param clientId Your client ID as declared in the Spotify Developer Centre.
 @param redirectURL Your callback URL as declared in the Spotify Developer Centre.
 @param scopes The custom scopes to request from the auth API.
 @param responseType Authentication response code type, defaults to "code", use "token" if you want to bounce directly to the app without refresh tokens.
 @return The URL to pass to `UIApplication`'s `-openURL:` method.
 */
+ (NSURL *)loginURLForClientId:(NSString *)clientId withRedirectURL:(NSURL *)redirectURL scopes:(NSArray *)scopes responseType:(NSString *)responseType;

///----------------------------
/// @name Handling Authentication Callback URLs
///----------------------------

/**
 Find out if the given URL appears to be a Spotify authentication URL.

 This method is useful if your application handles multiple URL types. You can pass every URL
 you receive through here to filter them.

 @param callbackURL The complete callback URL as triggered in your application.
 @return Returns `YES` if the callback URL appears to be a Spotify auth callback, otherwise `NO`.
 */
-(BOOL)canHandleURL:(NSURL *)callbackURL;

/**
 Handle a Spotify authentication callback URL, returning a Spotify username and OAuth credential.

 This URL is obtained when your application delegate's `application:openURL:sourceApplication:annotation:`
 method is triggered. Use `-[SPTAuth canHandleURL:]` to easily filter out other URLs that may be
 triggered.

 @param url The complete callback URL as triggered in your application.
 @param block The callback block to be triggered when authentication succeeds or fails.
 */
-(void)handleAuthCallbackWithTriggeredAuthURL:(NSURL *)url callback:(SPTAuthCallback)block;

/**
 Check if "flip-flop" application authentication is supported.
 @return YES if supported, NO otherwise.
 */
+(BOOL)supportsApplicationAuthentication;

/**
 Check if Spotify application is installed.
 @return YES if installed, NO otherwise.
 */
+(BOOL)spotifyApplicationIsInstalled;

///----------------------------
/// @name Renewing Sessions
///----------------------------

/**
 Request a new access token using an existing SPTSession object containing a refresh token.

 If no token refresh service has been specified the callback will return `nil` as session.

 @param session An SPTSession object with a valid refresh token.
 @param block The callback block that will be invoked when the request has been performed.
 */
-(void)renewSession:(SPTSession *)session callback:(SPTAuthCallback)block;


@end
