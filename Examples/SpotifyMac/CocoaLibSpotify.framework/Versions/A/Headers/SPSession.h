//
//  SPSession.h
//  CocoaLibSpotify
//
//  Created by Daniel Kennett on 2/14/11.
/*
Copyright (c) 2011, Spotify AB
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Spotify AB nor the names of its contributors may 
      be used to endorse or promote products derived from this software 
      without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL SPOTIFY AB BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <Foundation/Foundation.h>
#import "CocoaLibSpotifyPlatformImports.h"

@class SPPlaylist;
@class SPPlaylistFolder;
@class SPPlaylistContainer;
@class SPTrack;
@class SPUser;
@class SPSearch;
@class SPAlbum;
@class SPArtist;
@class SPImage;
@class SPPostTracksToInboxOperation;
@class SPUnknownPlaylist;
@protocol SPSessionDelegate;
@protocol SPSessionPlaybackDelegate;
@protocol SPSessionAudioDeliveryDelegate;
@protocol SPPostTracksToInboxOperationDelegate;
@protocol SPSessionPlaybackProvider;

/** This class provides core functionality for interacting with Spotify. You must have a valid, logged-in
 SPSession object before using any other part of the API.
 
 To log in and use CocoaLibSpotify, you need two things:
 
 - An application key, available at the [Spotify Developer Site](http://developer.spotify.com/).
 - A user account with the Premium subscription level.
 
 Playback
 
 Please note that CocoaLibSpotify does _not_ push audio data to the system's audio
 output. To hear tracks, you need to push the raw audio data provided to your application
 as you see fit. See the SimplePlayback sample project for an example of how to do this.
 */
@interface SPSession : NSObject <SPSessionPlaybackProvider, SPAsyncLoading>

/** Executes the given block on the libspotify thread.
 
 Any methods in CocoaLibSpotify that publicly expose parts of the libSpotify C API *or* direct calls 
 to libSpotify's C functions must be called on the libspotify thead by passing a block to this method.
 This thread is dedicated to libSpotify and is separate from the application's main thread.
 
 Methods in CocoaLibSpotify that require execution on this thread are documented as such, and will throw an
 assertion if called from any other thread. libSpotify C functions will not throw an assertion - instead
 you're likely to trigger an apparently random crash in the future since the library is not thread-safe.
 
 Examples for using this thread properly can be found in the project's README file.
 
 @param block The block to execute.
 */
+(void)dispatchToLibSpotifyThread:(dispatch_block_t)block;

/** Executes the given block on the libspotify thread.

 Any methods in CocoaLibSpotify that publicly expose parts of the libSpotify C API *or* direct calls
 to libSpotify's C functions must be called on the libspotify thead by passing a block to this method.
 This thread is dedicated to libSpotify and is separate from the application's main thread.

 Methods in CocoaLibSpotify that require execution on this thread are documented as such, and will throw an
 assertion if called from any other thread. libSpotify C functions will not throw an assertion - instead
 you're likely to trigger an apparently random crash in the future since the library is not thread-safe.

 Examples for using this thread properly can be found in the project's README file.

 @param block The block to execute.
 @param wait If `YES`, this method will block until the block has completed executing. This is not recommended.
 */
+(void)dispatchToLibSpotifyThread:(dispatch_block_t)block waitUntilDone:(BOOL)wait;

/** Returns the runloop that is running libspotify.
 
 Calls to the libspotify C API and certain CocoaLibSpotify methods must be made on this
 runloop. See +[SPSession dispatchToLibSpotifyThread:] to a convenient way to do this.
 
 @see +[SPSession dispatchToLibSpotifyThread:]
 @return The runloop running libspotify.
 */
+(CFRunLoopRef)libSpotifyRunloop;

/** Returns `YES` if the Spotify client is installed on the current device/machine. */
+(BOOL)spotifyClientInstalled;

/** Attempts to launch the Spotify client. Returns `YES` if successful. */
+(BOOL)launchSpotifyClientIfInstalled;

/** Returns a shared SPSession object. 
 
 This is a convenience method for creating and storing a single SPSession instance.
 
 @warning The C API that CocoaLibSpotify uses (LibSpotify) doesn't 
 support using multiple sessions in the same process. While you can either create and 
 store your SPSession object using this convenience method or yourself using -[SPSession init],
 make sure you only have _one_ instance of SPSession active in your process at a time.

 @warning This will return `nil` until +[SPSession initializeSharedSessionWithApplicationKey:userAgent:loadingPolicy:error:] is
 successfully called.
 */
+(SPSession *)sharedSession;

/** Initializes the shared SPSession object.

 Your application key and user agent must be valid to create an SPSession object.
 
 @warning The C API that CocoaLibSpotify uses (LibSpotify) doesn't
 support using multiple sessions in the same process. While you can either create and
 store your SPSession object using this convenience method or yourself using +[SPSession initWithApplicationKey:userAgent:loadingPolicy:error:],
 make sure you only have _one_ instance of SPSession active in your process at a time.

 @param appKey Your application key as an NSData.
 @param userAgent Your application's user agent (for example, com.yourcompany.MyGreatApp).
 @param policy The loading policy to use.
 @param error An error pointer to be filled with an NSError should a login problem occur.
 @return `YES` the the shared session was initialized correctly, otherwise `NO`.
 */
+(BOOL)initializeSharedSessionWithApplicationKey:(NSData *)appKey
									   userAgent:(NSString *)userAgent
								   loadingPolicy:(SPAsyncLoadingPolicy)policy
										   error:(NSError **)error;

/** The "debug" build ID of libspotify.

 This could be useful to display somewhere deep down in the user interface in
 case you (or Spotify) would like to know the exact version running. 
 
 @return Returns an NSString representing the build ID of the currently running version of libspotify.
 */
+(NSString *)libSpotifyBuildId;

///----------------------------
/// @name Logging In and Setup
///----------------------------

/** Initialize a new SPSession object.
 
 Your application key and user agent must be valid to create an SPSession object. This is SPSession's designated initializer.

 @param appKey Your application key as an NSData.
 @param userAgent Your application's user agent (for example, com.yourcompany.MyGreatApp).
 @param policy The loading policy to use.
 @param error An error pointer to be filled with an NSError should a login problem occur.
 @return Returns a newly initialised SPSession object.
 */
-(id)initWithApplicationKey:(NSData *)appKey
				  userAgent:(NSString *)userAgent
			  loadingPolicy:(SPAsyncLoadingPolicy)policy
					  error:(NSError **)error;

/** Attempt to login to the Spotify service.
 
 Login success or fail methods will be called on the session's delegate.
 
@warning You must have successfully logged in to the Spotify service before using 
 most other API methods.
 
 @param userName The username of the user who wishes to log in.
 @param password The password for the user who wishes to log in.
 */
-(void)attemptLoginWithUserName:(NSString *)userName
                       password:(NSString *)password;

/** Attempt to login to the Spotify service using an existing login credentials blob. 
 
 Login success or fail methods will be called on the session's delegate.
 
 @warning You must have successfully logged in to the Spotify service before using 
 most other API methods.
 
 @param userName The username of the user who wishes to log in.
 @param credential A login credential string previously provided by the `-session:didGenerateLoginCredentials:forUserName:` delegate method.
 */
-(void)attemptLoginWithUserName:(NSString *)userName
             existingCredential:(NSString *)credential;

/** The username used to log in to this session.
 
 @param block The block to be called with the username that was used to login to the current session, or 
 `nil` if the session is not logged in.
 */
-(void)fetchLoginUserName:(void (^)(NSString *loginUserName))block;

/** Manually flush libSpotify's caches.
 
 This method will force libSpotify to flush its caches. If you're writing an iOS application, call
 this when your application is put into the background to ensure correct operation.
 
 @param completionBlock The block to be called when the operation has completed.
 */
-(void)flushCaches:(void (^)())completionBlock;

/** Log out from the Spotify service.
 
 This method will cleanly log out from the Spotify service and clear any in-memory caches. 
 Called automatically when the instance is deallocated.
 
 @param completionBlock The block to be called when the logout process has completed.
 */
-(void)logout:(void (^)())completionBlock;

/** Returns the current connection state.
 
 Possible values: 
 
 SP_CONNECTION_STATE_LOGGED_OUT 	
 User not yet logged in.
 
 SP_CONNECTION_STATE_OFFLINE
 User is logged in but in offline mode.
 
 SP_CONNECTION_STATE_LOGGED_IN 	
 Logged in against a Spotify access point.
 
 SP_CONNECTION_STATE_DISCONNECTED 	
 Was logged in, but has now been disconnected.
 
 SP_CONNECTION_STATE_UNDEFINED 	
 The connection state is undefined.
 */
@property (nonatomic, readonly) sp_connectionstate connectionState;

/** Set the maximum cache size, in megabytes. 
 
 Set to 0 (the default) to automatically manage the cache, using at most 10% of the free disk space.
 
 @param maximumCacheSizeMB The maxiumum cache size, in MB, or 0 to automatically manage disk space.
 */
-(void)setMaximumCacheSizeMB:(size_t)maximumCacheSizeMB;

/** Set the preferred audio bitrate for playback.
 
 The default is to play the highest quality stream available. 
 
 @param bitrate The preferred bitrate for streaming. 
 */
-(void)setPreferredBitrate:(sp_bitrate)bitrate;

///----------------------------
/// @name Properties
///----------------------------

/** Returns the current delegate object. */
@property (nonatomic, readwrite, assign) __unsafe_unretained id <SPSessionDelegate> delegate;

/** Returns the opaque structure used by the C LibSpotify API. 
 
 @warning This method *must* be called on the libSpotify thread. See the
 "Threading" section of the library's readme for more information.
 
 @warning This should only be used if you plan to directly use the 
 C LibSpotify API. The behaviour of CocoaLibSpotify is undefined if you use the C
 API directly on items that have CocoaLibSpotify objects associated with them. 
 */
@property (nonatomic, readonly) sp_session *session;

/** Returns the user agent value the session was initialized with. */
@property (nonatomic, copy, readonly) NSString *userAgent;

/** Returns the loading policy of the session. */
@property (nonatomic, readonly) SPAsyncLoadingPolicy loadingPolicy;

///----------------------------
/// @name Social and Scrobbling
///----------------------------

/** Returns `YES` if the session is currently a "Private" session - that is, scrobbling to 
 social services is temporarily disabled.

 @warning *Important:* This may change back to `NO` after a long period of inactivity.
*/ 
@property (nonatomic, readwrite, getter=isPrivateSession) BOOL privateSession;

/** Sets the scrobbling status for the given social service. 
 
 @param state The desired scrobbling state. Note: Setting global status isn't yet supported.
 @param service The social service to set scrobbling state for.
 @param block The `SPErrorableOperationCallback` block to be called with an `NSError` if the operation failed or `nil` if the operation succeeded.
 */
-(void)setScrobblingState:(sp_scrobbling_state)state forService:(sp_social_provider)service callback:(SPErrorableOperationCallback)block;

/** Sets the scrobbling credientials for the given social service.
 
 Call `setScrobblingState:forService:callback:` to force a new connection after changing details. If the credentials 
 are invalid, the `session:didEncounterScrobblingError:` method on your `SPSessionDelegate` will be called with more information.
 
 @param userName The username for the service (i.e., Last.fm).
 @param password The password for the service.
 @param service The social service to set credentials for.
 @param block The `SPErrorableOperationCallback` block to be called with an `NSError` if the operation failed or `nil` if the operation succeeded.
 */
-(void)setScrobblingUserName:(NSString *)userName password:(NSString *)password forService:(sp_social_provider)service callback:(SPErrorableOperationCallback)block;

/** Gets the scrobbling status for the given social service.
 
 @param service The social service to get status for.
 @param block The block to be called with the scrobbling state of the given service, or an `NSError` if a problem occurred.
 */
-(void)fetchScrobblingStateForService:(sp_social_provider)service callback:(void (^)(sp_scrobbling_state state, NSError *error))block;

/** Gets whether scrobbling is allowed for the given service.
 
 If this method returns `NO` for a given service, it cannot be scrobbled to. UI for setting up scrobbling
 for the service should either be disabled or hidden in this case.
 
 @param service The social service to get status for.
 @param block The block to be called with the scrobbling state for the given service, or an `NSError` if a problem occurred.
 */
-(void)fetchScrobblingAllowedForService:(sp_social_provider)service callback:(void (^)(BOOL scrobblingAllowed, NSError *error))block;

///----------------------------
/// @name Offline Syncing
///----------------------------

/** Returns `YES` if tracks are currently being downloaded for offline playback, otherwise `NO`. */
@property (nonatomic, readonly, getter=isOfflineSyncing) BOOL offlineSyncing;

/** Returns the number of tracks still waiting to be downloaded for offline playback. */
@property (nonatomic, readonly) NSUInteger offlineTracksRemaining;

/** Returns the number of playlists still waiting to be downloaded for offline playback. */
@property (nonatomic, readonly) NSUInteger offlinePlaylistsRemaining;

/** Returns a dictionary containing information about any offline sync activity. See Contants for keys. */
@property (nonatomic, readonly, copy) NSDictionary *offlineStatistics;

/** Get the time until the user needs to reconnect to Spotify to renew offline syncing keys.

 @param block The block to be called with the remaining time.
 */
-(void)fetchOfflineKeyTimeRemaining:(void (^)(NSTimeInterval remainingTime))block;

/** Returns the last error encountered during offline syncing, or `nil` if there is no problem. */
@property (nonatomic, readonly, strong) NSError *offlineSyncError;

/** Returns `YES` if the session has finished loading.
 
 The session is considered loaded when the `inboxPlaylist`, `starredPlaylist`, 
 `user`, `locale` and `userPlaylists` properties are set.
 */ 
@property (nonatomic, readonly, getter=isLoaded) BOOL loaded;

///----------------------------
/// @name User Content
///----------------------------

/** Returns the logged in user's inbox playlist.
 
 The inbox playlist contains tracks sent to the user by other Spotify users, and is 
 updated as new tracks are sent to the user. 
 */
@property (nonatomic, readonly, strong) SPPlaylist *inboxPlaylist;

/** Returns the locale of the logged-in user. */
@property (nonatomic, readonly, strong) NSLocale *locale;

/** Returns the logged in user's starred playlist.
 
 The starred playlist contains tracks starred by the user, and is updated as new tracks are
 starred or unstarred.
 */ 
@property (nonatomic, readonly, strong) SPPlaylist *starredPlaylist;

/** Returns the current logged in user. */
@property (nonatomic, readonly, strong) SPUser *user;

/** Returns an SPPlaylistContainer object that contains the user's playlists.
 
 @see SPPlaylistContainer
 */
@property (nonatomic, readonly, strong) SPPlaylistContainer *userPlaylists;

/** Send tracks to another Spotify user.
 
 @warning Tracks will be posted to the given user as soon as this
 method is called. Be sure you want to post the tracks before doing so!
 
 @param tracks An array of SPTrack objects to send.
 @param targetUserName The username of the user to send the tracks to.
 @param aFriendlyMessage The message to send with the tracks, if any.
 @param block The `SPErrorableOperationCallback` block to be called with an `NSError` if the operation failed or `nil` if the operation succeeded.
 @return Returns an SPPostTracksToInboxOperation object representing the operation.
 @see SPPostTracksToInboxOperation
 */
-(SPPostTracksToInboxOperation *)postTracks:(NSArray *)tracks 
							  toInboxOfUser:(NSString *)targetUserName
								withMessage:(NSString *)aFriendlyMessage
								   callback:(SPErrorableOperationCallback)block;

///----------------------------
/// @name Accessing Content by URL
///----------------------------

/** Get an SPAlbum object representing the given URL, or `nil` if the URL is not a valid album URL. 
 
 @param url The URL of the album.
 @param block The block to be called with the album, or `nil` if given an invalid URL.
 */
-(void)albumForURL:(NSURL *)url callback:(void (^)(SPAlbum *album))block;

/** Get an SPArtist object representing the given URL, or `nil` if the URL is not a valid artist URL.
 
 @param url The URL of the artist.
 @param block The block to be called with the artist, or `nil` if given an invalid URL.
 */
-(void)artistForURL:(NSURL *)url callback:(void (^)(SPArtist *artist))block;

/** Returns an SPImage object representing the given URL, or `nil` if the URL is not a valid image URL.
 
 @param url The URL of the image.
 @param block The block to be called with the image, or `nil` if given an invalid URL.
 */
-(void)imageForURL:(NSURL *)url callback:(void (^)(SPImage *image))block;

/** Returns an SPPlaylist object representing the given URL, or `nil` if the URL is not a valid playlist URL.
 
 @param url The URL of the playlist.
 @param block The block to be called with the playlist, or `nil` if given an invalid URL.
 */
-(void)playlistForURL:(NSURL *)url callback:(void (^)(SPPlaylist *playlist))block;

/** Returns an SPSearch object representing the given URL, or `nil` if the URL is not a valid search URL. 
 
 @param url The URL of the search query.
 @param block The block to be called with the search, or `nil` if given an invalid URL.
 */
-(void)searchForURL:(NSURL *)url callback:(void (^)(SPSearch *search))block;

/** Returns an SPTrack object representing the given URL, or `nil` if the URL is not a valid track URL. 
 
 @param url The URL of the track.
 @param block The block to be called with the track, or `nil` if given an invalid URL.
 */
-(void)trackForURL:(NSURL *)url callback:(void (^)(SPTrack *track))block;

/** Returns an SPUser object representing the given URL, or `nil` if the URL is not a valid user URL. 
 
 @param url The URL of the user.
 @param block The block to be called with the user, or `nil` if given an invalid URL.
 */
-(void)userForURL:(NSURL *)url callback:(void (^)(SPUser *user))block;

/** Returns an object representation of the given Spotify URL.
 
@warning This method *must* be called on the libSpotify thread. See the
 "Threading" section of the library's readme for more information.

 @param aSpotifyUrlOfSomeKind A Spotify URL (starting `spotify:`).
 @param linkType An optional pointer to an `sp_linktype` that will be filled with the type of object returned.
 @return Returns the created object, or nil if the URL is invalid.
 */
 -(id)objectRepresentationForSpotifyURL:(NSURL *)aSpotifyUrlOfSomeKind linkType:(sp_linktype *)linkType;

/** Returns an object representation of the given Spotify URL.

 This method works just like -albumForURL:, -artistForURL: and so on, except that it works out 
 what the given URL represents and returns that for you.
 
 @param aSpotifyUrlOfSomeKind A Spotify URL (starting `spotify:`).
 @param block The block to be called with the `sp_linktype` and object representation of the URL, or `nil` if given an invalid URL.
 */
-(void)objectRepresentationForSpotifyURL:(NSURL *)aSpotifyUrlOfSomeKind callback:(void (^)(sp_linktype linkType, id objectRepresentation))block;

///----------------------------
/// @name Accessing Arbitrary Content
///----------------------------

/** Create and cache an SPPlaylist for the given sp_playlist struct from the C LibSpotify API.
 
 This method caches SPPlaylist objects using the same cache the +[SPPlaylist playlist...] 
 convenience methods use.
 
 @warning This method *must* be called on the libSpotify thread. See the
 "Threading" section of the library's readme for more information.
 
 @param playlist The sp_playlist struct.
 @return Returns the created or cached SPPlaylist object.
 */
-(SPPlaylist *)playlistForPlaylistStruct:(sp_playlist *)playlist;

/** Create and cache an SPPlaylistFolder for the given folder ID from the C LibSpotify API.
 
 This method caches SPPlaylistFolder objects by ID.
 
 @warning This method *must* be called on the libSpotify thread. See the
 "Threading" section of the library's readme for more information.
 
 @param playlistId The folder ID.
 @param aContainer The SPPlaylistContainer that contains the given folder.
 @return Returns the created or cached SPPlaylistFolder object.
 */
-(SPPlaylistFolder *)playlistFolderForFolderId:(sp_uint64)playlistId inContainer:(SPPlaylistContainer *)aContainer;

/** Create and cache an SPUnknownPlaylist (subclass of SPPlaylist) for the given sp_playlist struct from the C LibSpotify API.
 
 This method caches SPUnknownPlaylist objects using the same cache the +[SPPlaylist playlist...] 
 convenience methods use.
 
 @param playlist The sp_playlist struct.
 @return Returns the created or cached SPUnknownPlaylist object.
 */
-(SPUnknownPlaylist *)unknownPlaylistForPlaylistStruct:(sp_playlist *)playlist;

/** Create and cache an SPTrack for the given sp_track struct from the C LibSpotify API.
 
 This method caches SPTrack objects using the same cache the +[SPTrack track...] 
 convenience methods use.
 
 @warning This method *must* be called on the libSpotify thread. See the
 "Threading" section of the library's readme for more information.
 
 @param track The sp_track struct.
 @return Returns the created or cached SPTrack object.
 */
-(SPTrack *)trackForTrackStruct:(sp_track *)track;

/** Create and cache an SPUser for the given sp_user struct from the C LibSpotify API.
 
 This method caches SPUser objects using the same cache the +[SPUser user...] 
 convenience methods use.
 
 @warning This method *must* be called on the libSpotify thread. See the
 "Threading" section of the library's readme for more information.
 
 @param user The sp_user struct.
 @return Returns the created or cached SPUser object.
 */
-(SPUser *)userForUserStruct:(sp_user *)user;

///----------------------------
/// @name Audio Playback
///----------------------------

/** Returns `YES` if the session is employing volume normalization (that is, attempts to keep the 
 sound level of each track the same), otherwise `NO`.
 
 @warning This property currently has no effect on iOS platforms.
 */
@property (nonatomic, readwrite, getter=isUsingVolumeNormalization) BOOL usingVolumeNormalization;

/** Returns `YES` if the session is currently playing a track, otherwise `NO`. */
@property (nonatomic, readwrite, getter=isPlaying) BOOL playing;

/** Returns the session's playback delegate object.
 
 The playback delegate is responsible for dealing with playback events from CocoaLibSpotify, such as
 playback ending or being paused because the account is being used for playback elsewhere.
 */
@property (nonatomic, readwrite, assign) __unsafe_unretained id <SPSessionPlaybackDelegate> playbackDelegate;

/** Returns the session's audio delivery delegate object.
 
 The audio delivery delegate is responsible for pushing raw audio data provided by the session
 to the system's audio output. See the SimplePlayback sample project for an example of how to do this.
*/
@property (nonatomic, readwrite, assign) __unsafe_unretained id <SPSessionAudioDeliveryDelegate> audioDeliveryDelegate;

/** Preloads playback assets for the given track.
 
 For smooth changes between tracks, you can use this method to start loading track playback 
 data before the track needs to be played. The Spotify client does this a few seconds before moving 
 to the next track during normal playback.
 
 @param aTrack The track to preload.
 @param block A block to be called when operation has successfully begun. The error parameter will be non-`nil` is an error occurred.
 */
-(void)preloadTrackForPlayback:(SPTrack *)aTrack callback:(SPErrorableOperationCallback)block;

/** Start playing the given track.
 
 @param aTrack The track to play.
 @param block A block to be called when operation has successfully begun. The error parameter will be non-`nil` is an error occurred.
 */
-(void)playTrack:(SPTrack *)aTrack callback:(SPErrorableOperationCallback)block;

/** Seek the current playback position to the given time. 
 
 @param offset The time at which to seek to. Must be between 0.0 and the duration of the playing track.
 */
-(void)seekPlaybackToOffset:(NSTimeInterval)offset;

/** Unload playback resources from memory. 
 
 Call this when you're done playing to free up some memory. Called automatically on
 instance deallocation. 
 */
-(void)unloadPlayback;

@end

/** General delegate callbacks from SPSession. For playback-related callbacks, see SPSessionPlaybackDelegate. */

@protocol SPSessionDelegate <NSObject>
@optional

///----------------------------
/// @name Logging In and Out
///----------------------------

/** Called when the given session has logged in successfully.
 
 @param aSession The session that logged in. 
 */
-(void)sessionDidLoginSuccessfully:(SPSession *)aSession;

/** Called when a set of login credentials has been generated for the user, typically just after login.
 
 If you wish to store login credentials for multiple users, store the credentials given by this
 delegate method rather than their passwords (it's against the libSpotify Terms and Conditions to store
 Spotify passwords yourself). These credentials are safe to store without encryption, such as in `NSUserDefaults`.
 
 To use these credentials to log in, use `-attemptLoginWithUserName:existingCredential:rememberCredentials:`.
 
 @param aSession The session that logged in. 
 @param credential The login credential.
 @param userName The username for the given credential.
 */
-(void)session:(SPSession *)aSession didGenerateLoginCredentials:(NSString *)credential forUserName:(NSString *)userName;

/** Called when the given session could not log in successfully.
 
 @param aSession The session that failed to log in. 
 @param error An NSError object describing the failure.
 */
-(void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error;

/** Called when the given session has logged out.
 
 @param aSession The session that logged out. 
 */
-(void)sessionDidLogOut:(SPSession *)aSession;

///----------------------------
/// @name Communicating With The User
///----------------------------

/** Called when the Spotify service would like to display a message to the user. 
 
 In the desktop client, these are shown in a blueish toolbar just below the search box.
 
 @param aSession The session that received the message. 
 @param aMessage The message to be displayed..
 */
-(void)session:(SPSession *)aSession recievedMessageForUser:(NSString *)aMessage;

///----------------------------
/// @name Metadata
///----------------------------

/** Called when metadata has been updated.
 
 If you have cached metadata yourself, you should purge your caches and fetch new versions.
 
 @param aSession The session updated its metadata.
 */
-(void)sessionDidChangeMetadata:(SPSession *)aSession;

///----------------------------
/// @name Networking and Debug
///----------------------------

/** Called when there is a connection error, and CocoaLibSpotify has problems reconnecting
 to the Spotify service. Can be called multiple times (as long as the problem is present).
 
 @param aSession The session that encountered a problem. 
 @param error An NSError object describing the failure.
 */
-(void)session:(SPSession *)aSession didEncounterNetworkError:(NSError *)error;

/** Called when there is an error enountered when scrobbling plays to, for example, Last.fm.
 
 @param aSession The session that encountered a problem. 
 @param error An NSError object describing the failure.
 */
-(void)session:(SPSession *)aSession didEncounterScrobblingError:(NSError *)error;

/** Called when a log-worthy message is generated by the Spotify service.
 
 @warning This method will be called very frequently if implemented. Please
 refrain from mindlessly logging these to the console in a release application to aid the user's 
 sainity.
 
 @param aSession The session that is sending the log message. 
 @param aMessage The message to be logged.
 */
-(void)session:(SPSession *)aSession didLogMessage:(NSString *)aMessage;

#if TARGET_OS_IPHONE

/** Called when the session needs to present a view controller to allow the user to login, sign up
 or confirm Facebook access permissions.
 
 @warning While this typically happens around login, it can happen at any point. When this method
 is called, your application should make sure it's in a state appropriate for displaying a login view.
 
 @param aSession The session needing to display UI.
 @return A view controller appropriate for the given session to present a modal view controller over.
 */
-(UIViewController *)viewControllerToPresentLoginViewForSession:(SPSession *)aSession;

#endif

@end

/** Delegate callbacks from SPSession specifically to do with audio playback. */

@protocol SPSessionPlaybackDelegate <NSObject>
@optional

/** Called when playback was paused because the Spotify account was used elsewhere.
 
 @param aSession The session that paused playback. 
 */
-(void)sessionDidLosePlayToken:(id <SPSessionPlaybackProvider>)aSession;

/** Called when playback stopped naturally at the end of a track.
 
 @param aSession The session that stopped playback. 
 */
-(void)sessionDidEndPlayback:(id <SPSessionPlaybackProvider>)aSession;

/** Called when playback stopped due to a streaming error. 
 
 @param aSession The session that stopped playback. 
 @param error The error that occurred.
 */
-(void)session:(id <SPSessionPlaybackProvider>)aSession didEncounterStreamingError:(NSError *)error;

/** Called when audio data has been decompressed and should be pushed to the audio buffers. 
 
 See the SimplePlayback sample project for an example of how to implement audio playback.
 
 @warning This method is deprecated and will only be called if the -audioDeliveryDelegate property is NOT set.
 
 @deprecated
 
 @warning This function is called from an internal session thread - you need to have 
 proper synchronization!
 
 @warning If this method is called with a frameCount of 0, an "audio discontinuity" has occurred - 
 for example, the user has seeked playback to another part of the track. You should clear audio buffers and prepare
 for new audio.
 
 @warning This function must never block. If your output buffers are full you must 
 return 0 to signal that the library should retry delivery in a short while.
 
 @param aSession The session providing the audio data.
 @param audioFrames A buffer containing the audio data.
 @param frameCount The number of frames in the buffer.
 @param audioFormat An sp_audioformat struct containing information about the audio format.
 @return Number of frames consumed. This value can be used to rate limit 
 the output from the library if your output buffers are saturated. Delivery will 
 be retried in about 100ms.
 */
-(NSInteger)session:(id <SPSessionPlaybackProvider>)aSession shouldDeliverAudioFrames:(const void *)audioFrames ofCount:(NSInteger)frameCount format:(const sp_audioformat *)audioFormat;

@end

/**
 Delegate callbacks from SPSession specifically to do with delivering audio to the audio device. 
 This protocol replaces the audio delivery method in `SPSessionPlaybackDelegate`.
 */

@protocol SPSessionAudioDeliveryDelegate <NSObject>

/** Called when audio data has been decompressed and should be pushed to the audio buffers. 
 
 See the SimplePlayback sample project for an example of how to implement audio playback.
 
 @warning This function is called from an internal session thread - you need to have 
 proper synchronization!
 
 @warning If this method is called with a frameCount of 0, an "audio discontinuity" has occurred - 
 for example, the user has seeked playback to another part of the track. You should clear audio buffers and prepare
 for new audio.
 
 @warning This function must never block. If your output buffers are full you must 
 return 0 to signal that the library should retry delivery in a short while.
 
 @param aSession The session providing the audio data.
 @param audioFrames A buffer containing the audio data.
 @param frameCount The number of frames in the buffer.
 @param audioDescription An AudioStreamBasicDescription containing information about the audio format.
 @return Number of frames consumed. This value can be used to rate limit 
 the output from the library if your output buffers are saturated. Delivery will 
 be retried in about 100ms.
 */
-(NSInteger)session:(id <SPSessionPlaybackProvider>)aSession shouldDeliverAudioFrames:(const void *)audioFrames ofCount:(NSInteger)frameCount streamDescription:(AudioStreamBasicDescription)audioDescription;

@end


///----------------------------
/// @name Offline Sync Statistics Keys
///----------------------------

/** @constant The number of tracks that have been copied as an `NSNumber`. */
static NSString * const SPOfflineStatisticsCopiedTrackCountKey = @"SPOfflineStatisticsCopiedTrackCount";

/** The data size of tracks, in bytes, that have been copied as an `NSNumber`. */
static NSString * const SPOfflineStatisticsCopiedTrackSizeKey = @"SPOfflineStatisticsCopiedTrackSize";

/** The number of tracks that were already offline synced before this operation started as an `NSNumber`. */
static NSString * const SPOfflineStatisticsDoneTrackCountKey = @"SPOfflineStatisticsDoneTrackCount";

/** The data size of tracks, in bytes, that were already offline synced before this operation started as an `NSNumber`. */
static NSString * const SPOfflineStatisticsDoneTrackSizeKey = @"SPOfflineStatisticsDoneTrackSize";

/** The number of tracks that are left to sync as an `NSNumber`. */
static NSString * const SPOfflineStatisticsQueuedTrackCountKey = @"SPOfflineStatisticsQueuedTrackCount";

/** The data size of tracks, in bytes, that are left to sync as an `NSNumber`. */
static NSString * const SPOfflineStatisticsQueuedTrackSizeKey = @"SPOfflineStatisticsQueuedTrackSize";

/** The number of tracks that failed to be offline synced as an `NSNumber`. */
static NSString * const SPOfflineStatisticsFailedTrackCountKey = @"SPOfflineStatisticsFailedTrackCount";

/** The number of tracks that will not be copied as an `NSNumber`. */
static NSString * const SPOfflineStatisticsWillNotCopyTrackCountKey = @"SPOfflineStatisticsWillNotCopyTrackCount";

/** Whether tracks are currently being synced as a boolean `NSNumber`. */
static NSString * const SPOfflineStatisticsIsSyncingKey = @"SPOfflineStatisticsIsSyncing";

///----------------------------
/// @name NSNotification Keys
///----------------------------

/** @constant Sent when the user failed to log into the Spotify service. */
static NSString * const SPSessionLoginDidFailNotification = @"SPSessionLoginDidFailNotification";

/** @constant The userinfo key containing the error detailing the login failure reason in `SPSessionLoginDidFailNotification`. */
static NSString * const SPSessionLoginDidFailErrorKey = @"error";

/** @constant Sent when the user successfully logged in to the Spotify service. */
static NSString * const SPSessionLoginDidSucceedNotification = @"SPSessionLoginDidSucceedNotification";

/** @constant Sent when the user logged out from the Spotify service. */
static NSString * const SPSessionDidLogoutNotification = @"SPSessionDidLogoutNotification";

/** @constant Sent when metadata is updated somewhere in the object model. */
static NSString * const SPSessionDidUpdateMetadataNotification = @"SPSPSessionDidUpdateMetadataNotification";
