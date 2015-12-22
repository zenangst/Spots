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
#import <CoreGraphics/CoreGraphics.h>
#import "SPTTypes.h"
#import "SPTDiskCache.h"
#import "SPTDiskCaching.h"
#import "SPTPlayOptions.h"

/** A volume value, in the range 0.0..1.0. */
typedef double SPTVolume;

/** The playback bitrates availabe. */
typedef NS_ENUM(NSUInteger, SPTBitrate) {
	/** The lowest bitrate, roughly equivalent to ~96kbit/sec. */
	SPTBitrateLow = 0,
	/** The normal bitrate, roughly equivalent to ~160kbit/sec.  */
	SPTBitrateNormal = 1,
	/** The highest bitrate, roughly equivalent to ~320kbit/sec. */
	SPTBitrateHigh = 2,
};

FOUNDATION_EXPORT NSString * const SPTAudioStreamingMetadataTrackName DEPRECATED_ATTRIBUTE;
FOUNDATION_EXPORT NSString * const SPTAudioStreamingMetadataTrackURI;
FOUNDATION_EXPORT NSString * const SPTAudioStreamingMetadataArtistName DEPRECATED_ATTRIBUTE;
FOUNDATION_EXPORT NSString * const SPTAudioStreamingMetadataArtistURI DEPRECATED_ATTRIBUTE;
FOUNDATION_EXPORT NSString * const SPTAudioStreamingMetadataAlbumName DEPRECATED_ATTRIBUTE;
FOUNDATION_EXPORT NSString * const SPTAudioStreamingMetadataAlbumURI DEPRECATED_ATTRIBUTE;
FOUNDATION_EXPORT NSString * const SPTAudioStreamingMetadataTrackDuration DEPRECATED_ATTRIBUTE;

@class SPTSession;
@class SPTCoreAudioController;
@protocol SPTAudioStreamingDelegate;
@protocol SPTAudioStreamingPlaybackDelegate;

/** This class manages audio streaming from Spotify.

 \note There must be only one concurrent instance of this class in your app.
 */
@interface SPTAudioStreamingController : NSObject

///----------------------------
/// @name Initialisation and Setup
///----------------------------

// Hide parameterless init
-(id)init __attribute__((unavailable("init not available, use initWithClientId")));
+(id)new __attribute__((unavailable("new not available, use alloc and initWithClientId")));

/** Initialise a new `SPAudioStreamingController`.
 
 @param clientId Your client id.
 @return Returns an initialised `SPAudioStreamingController` instance.
 */
-(id)initWithClientId:(NSString *)clientId;

/** Initialise a new `SPAudioStreamingController` with a custom audio controller.
 
 @param clientId Your client id.
 @param audioController Audio controller.
 @return Returns an initialised `SPAudioStreamingController` instance.
 */
-(id)initWithClientId:(NSString *)clientId audioController:(SPTCoreAudioController *)audioController;

/** Log into the Spotify service for audio playback.
 
 Audio playback will not be available until the receiver is successfully logged in.
 
 @param session The session to log in with. Must be valid and authenticated with the
 `SPTAuthStreamingScope` scope.
 @param block The callback block to be executed when login succeeds or fails. In the cause of
 failure, an `NSError` object will be passed.
 */
-(void)loginWithSession:(SPTSession *)session callback:(SPTErrorableOperationCallback)block;

/** Log out of the Spotify service

 @param block The callback block to be executed when logout succeeds or fails. In the cause of
 failure, an `NSError` object will be passed.
 */
-(void)logout:(SPTErrorableOperationCallback)block;

///----------------------------
/// @name Properties
///----------------------------

/** Returns `YES` if the receiver is logged into the Spotify service, otherwise `NO`. */
@property (nonatomic, readonly) BOOL loggedIn;

/** The receiver's delegate, which deals with session events such as login, logout, errors, etc. */
@property (nonatomic, weak) id <SPTAudioStreamingDelegate> delegate;

/** The receiver's playback delegate, which deals with audio playback events. */
@property (nonatomic, weak) id <SPTAudioStreamingPlaybackDelegate> playbackDelegate;

/**
 * @brief The object responsible for caching of audio data.
 * @discussion The object is an instance of a class that implements the `SPTDiskCaching` protocol.
 * If `nil`, no caching will be performed.
 * @see `SPTDiskCaching`
 */
@property (nonatomic, strong) id <SPTDiskCaching> diskCache;

///----------------------------
/// @name Controlling Playback
///----------------------------

/** Set playback volume to the given level.

 @param volume The volume to change to, as a value between `0.0` and `1.0`.
 @param block The callback block to be executed when the command has been
 received, which will pass back an `NSError` object if an error ocurred.
 @see -volume
 */
-(void)setVolume:(SPTVolume)volume callback:(SPTErrorableOperationCallback)block;

/** Set the target streaming bitrate.
 
 The library will attempt to stream audio at the given bitrate. If the given
 bitrate is not available, the closest match will be used. This process is
 completely transparent, but you should be aware that data usage isn't guaranteed.
 
 @param bitrate The bitrate to target.
 @param block The callback block to be executed when the command has been
 received, which will pass back an `NSError` object if an error ocurred.
 */
-(void)setTargetBitrate:(SPTBitrate)bitrate callback:(SPTErrorableOperationCallback)block;

/** Seek playback to a given location in the current track.

 @param offset The time to seek to.
 @param block The callback block to be executed when the command has been
 received, which will pass back an `NSError` object if an error ocurred.
 @see -currentPlaybackPosition
 */
-(void)seekToOffset:(NSTimeInterval)offset callback:(SPTErrorableOperationCallback)block;

/** Set the "playing" status of the receiver.

 @param playing Pass `YES` to resume playback, or `NO` to pause it.
 @param block The callback block to be executed when the command has been
 received, which will pass back an `NSError` object if an error ocurred.
 @see -isPlaying
 */
-(void)setIsPlaying:(BOOL)playing callback:(SPTErrorableOperationCallback)block;

/** Play a Spotify URI.
 
 Supported URI types: Tracks, Albums and Playlists

 @see -playURIs:withOptions:callback:

 @param uri The URI to play.
 @param block The callback block to be executed when the playback command has been
 received, which will pass back an `NSError` object if an error ocurred.
 */
-(void)playURI:(NSURL *)uri callback:(SPTErrorableOperationCallback)block DEPRECATED_ATTRIBUTE;

/** Play a Spotify URI.
 
 Supported URI types: Tracks, Albums and Playlists

 This function is deprecated and will be removed in the next version.

 @see -playURIs:withOptions:callback:

 @param uri The URI to play.
 @param index The track to start playing from if an album or playlist
 @param block The callback block to be executed when the playback command has been
 received, which will pass back an `NSError` object if an error ocurred.
 */
-(void)playURI:(NSURL *)uri fromIndex:(int)index callback:(SPTErrorableOperationCallback)block DEPRECATED_ATTRIBUTE;

/** Play a list of Spotify URIs.
 
 Supported URI types: Tracks

 This function is deprecated and will be removed in the next version.

 @see -playURIs:withOptions:callback:

 @param uris The list of URI's to play.
 @param index The track to start playing from if an album or playlist
 @param block The callback block to be executed when the playback command has been
 received, which will pass back an `NSError` object if an error ocurred.
 */
-(void)playURIs:(NSArray *)uris fromIndex:(int)index callback:(SPTErrorableOperationCallback)block;

/** Play a list of Spotify URIs.

 Supported URI types: Tracks

 @param uris The list of URI's to play (at most 100 tracks)
 @param options A `SPTPlayOptions` containing extra information about the play request such as which track to play and from which starting position within the track.
 @param block The callback block to be executed when the playback command has been
 received, which will pass back an `NSError` object if an error ocurred.
 */
-(void)playURIs:(NSArray *)uris withOptions:(SPTPlayOptions *)options callback:(SPTErrorableOperationCallback)block;

/** Set the current list of tracks.
 
 Supported URI types: Tracks

 This function is deprecated and will be removed in the next version.

 @see -replaceURIs:withCurrentTrack:callback:
 
 @param uris The list of URI's to play.
 @param block The callback block to be executed when the tracks are set, or an `NSError` object if an error ocurred.
 */
-(void)setURIs:(NSArray *)uris callback:(SPTErrorableOperationCallback)block DEPRECATED_ATTRIBUTE;

/** Replace the current list of tracks without stopping playback.

 Supported URI types: Tracks

 @param uris The list of URI's to play.
 @param index The current track in the list.
 @param block The callback block to be executed when the tracks are set, or an `NSError` object if an error ocurred.
 */
-(void)replaceURIs:(NSArray *)uris withCurrentTrack:(int)index callback:(SPTErrorableOperationCallback)block;

/** Start playing the current list of tracks from a specific position.

 This function is deprecated and will be removed in the next version.

 @see -playURIs:withOptions:callback:

 @param index The track to start playing from if an album or playlist
 @param block The callback block to be executed when the playback command has been
 received, which will pass back an `NSError` object if an error ocurred.
 */
-(void)playURIsFromIndex:(int)index callback:(SPTErrorableOperationCallback)block DEPRECATED_ATTRIBUTE;

/** Play a track provider.
 
 Supported types: SPTTrack, SPTAlbum and SPTPlaylist

 This function is deprecated and will be removed in the next version.

 @see -playURIs:withOptions:callback:

 @param provider A track provider.
 @param block The callback block to be executed when the playback command has been
 received, which will pass back an `NSError` object if an error ocurred.
 */
-(void)playTrackProvider:(id<SPTTrackProvider>)provider callback:(SPTErrorableOperationCallback)block DEPRECATED_ATTRIBUTE;

/** Play a track provider.
 
 Supported types: SPTTrack, SPTAlbum and SPTPlaylist

 This function is deprecated and will be removed in the next version.

 @see -playURIs:withOptions:callback:

 @param provider A track provider.
 @param index How many tracks to skip.
 @param block The callback block to be executed when the playback command has been
 received, which will pass back an `NSError` object if an error ocurred.
 */
-(void)playTrackProvider:(id<SPTTrackProvider>)provider fromIndex:(int)index callback:(SPTErrorableOperationCallback)block DEPRECATED_ATTRIBUTE;

/** Queue a Spotify URI.
 
 Supported URI types: Tracks

 This function is deprecated and will be removed in the next version.

 @see -playURIs:withOptions:callback:

 @param uri The URI to queue.
 @param block The callback block to be executed when the playback command has been
 received, which will pass back an `NSError` object if an error ocurred.
 */
-(void)queueURI:(NSURL *)uri callback:(SPTErrorableOperationCallback)block DEPRECATED_ATTRIBUTE;

/** Queue a Spotify URI.
 
 Supported URI types: Tracks

 This function is deprecated and will be removed in the next version.

 @see -playURIs:withOptions:callback:

 @param uri The URI to queue.
 @param clear Clear the queue before adding URI
 @param block The callback block to be executed when the playback command has been
 received, which will pass back an `NSError` object if an error ocurred.
 */
-(void)queueURI:(NSURL *)uri clearQueue:(BOOL)clear callback:(SPTErrorableOperationCallback)block DEPRECATED_ATTRIBUTE;

/** Queue a list of Spotify URIs.
 
 Supported URI types: Tracks

 This function is deprecated and will be removed in the next version.

 @see -playURIs:withOptions:callback:
 @see -replaceURIs:withCurrentTrack:callback:

 @param uris The array of URIs to queue.
 @param clear Clear the queue before adding URIs
 @param block The callback block to be executed when the playback command has been
 received, which will pass back an `NSError` object if an error ocurred.
 */
-(void)queueURIs:(NSArray *)uris clearQueue:(BOOL)clear callback:(SPTErrorableOperationCallback)block;

/** Queue a track provider.
 
 Supported types: SPTTrack

 This function is deprecated and will be removed in the next version.

 @see -playURIs:withOptions:callback:

 @param provider A track provider.
 @param clear Clear the queue before adding
 @param block The callback block to be executed when the playback command has been
 received, which will pass back an `NSError` object if an error ocurred.
 */
-(void)queueTrackProvider:(id<SPTTrackProvider>)provider clearQueue:(BOOL)clear callback:(SPTErrorableOperationCallback)block DEPRECATED_ATTRIBUTE;

/** Start playing back queued items

 @see -playURIs:withOptions:callback:

 This function is deprecated and will be removed in the next version.

 @param block The callback block to be executed when the playback has been
 started, which will pass back an `NSError` object if an error ocurred.
 */
-(void)queuePlay:(SPTErrorableOperationCallback)block DEPRECATED_ATTRIBUTE;

/** Remove all queued items

 This function is deprecated and will be removed in the next version.
 @see -replaceURIs:withCurrentTrack:callback:
 
 @param block The callback block to be executed when the queue is empty or an `NSError` object if an error ocurred.
 */
-(void)queueClear:(SPTErrorableOperationCallback)block DEPRECATED_ATTRIBUTE;

/** Stop playback and clear the queue and list of tracks.
 
 @param block The callback block to be executed when playback stopped empty or an `NSError` object if an error ocurred.
 */
-(void)stop:(SPTErrorableOperationCallback)block;

/** Go to the next track in the queue.
 
 @param block The callback block to be executed when the command has been
 received, which will pass back an `NSError` object if an error ocurred.
 */
-(void)skipNext:(SPTErrorableOperationCallback)block;

/** Go to the previous track in the queue
 
 @param block The callback block to be executed when the command has been
 received, which will pass back an `NSError` object if an error ocurred.
 */
-(void)skipPrevious:(SPTErrorableOperationCallback)block;

/** Returns basic metadata about a track relative to the currently playing song, or `nil` if it doesn't exist or is unknown.
 
 Passing an index of zero would mean the currently playing song, passing -1 is the previous one, passing 1 is the next one.
 
 Metadata is under the following keys:
 
 - `SPTAudioStreamingMetadataTrackName`: The track's name.
 - `SPTAudioStreamingMetadataTrackURI`: The track's Spotify URI.
 - `SPTAudioStreamingMetadataArtistName`: The track's artist's name.
 - `SPTAudioStreamingMetadataArtistURI`: The track's artist's Spotify URI.
 - `SPTAudioStreamingMetadataAlbumName`: The track's album's name.
 - `SPTAudioStreamingMetadataAlbumURI`: The track's album's URI.
 - `SPTAudioStreamingMetadataTrackDuration`: The track's duration as an `NSTimeInterval` boxed in an `NSNumber`.

 @param index The relative index of the track in the current track list.
 @param block A block which receives an `NSDictionary` object containing the metadata.
 */
-(void)getRelativeTrackMetadata:(int)index callback:(void (^)(NSDictionary *))block DEPRECATED_ATTRIBUTE;

/** Returns basic metadata about a specific track in the current track list, or `nil` if it doesn't exist or is unknown.
 
 Metadata is under the following keys:
 
 - `SPTAudioStreamingMetadataTrackName`: The track's name.
 - `SPTAudioStreamingMetadataTrackURI`: The track's Spotify URI.
 - `SPTAudioStreamingMetadataArtistName`: The track's artist's name.
 - `SPTAudioStreamingMetadataArtistURI`: The track's artist's Spotify URI.
 - `SPTAudioStreamingMetadataAlbumName`: The track's album's name.
 - `SPTAudioStreamingMetadataAlbumURI`: The track's album's URI.
 - `SPTAudioStreamingMetadataTrackDuration`: The track's duration as an `NSTimeInterval` boxed in an `NSNumber`.
 @param index The absolute index of the track in the current track list.
 @param block A block which receives an `NSDictionary` object containing the metadata.
 */
-(void)getAbsoluteTrackMetadata:(int)index callback:(void (^)(NSDictionary *))block DEPRECATED_ATTRIBUTE;

///----------------------------
/// @name Playback State
///----------------------------

/** Returns basic metadata about the currently playing track, or `nil` if there is no track playing.
 
 Metadata is under the following keys:
 
 - `SPTAudioStreamingMetadataTrackName`: The track's name.
 - `SPTAudioStreamingMetadataTrackURI`: The track's Spotify URI.
 - `SPTAudioStreamingMetadataArtistName`: The track's artist's name.
 - `SPTAudioStreamingMetadataArtistURI`: The track's artist's Spotify URI.
 - `SPTAudioStreamingMetadataAlbumName`: The track's album's name.
 - `SPTAudioStreamingMetadataAlbumURI`: The track's album's URI.
 - `SPTAudioStreamingMetadataTrackDuration`: The track's duration as an `NSTimeInterval` boxed in an `NSNumber`.
 */
@property (nonatomic, readonly, copy) NSDictionary *currentTrackMetadata DEPRECATED_ATTRIBUTE;

/** Returns `YES` if the receiver is playing audio, otherwise `NO`. */
@property (nonatomic, readonly) BOOL isPlaying;

/** Returns `YES` if repeat is on, otherwise `NO`. */
@property (nonatomic, readonly) SPTVolume volume;

/** Returns `YES` if the receiver expects shuffled playback, otherwise `NO`. */
@property (nonatomic, readwrite) BOOL shuffle;

/** Returns `YES` if the receiver expects repeated playback, otherwise `NO`. */
@property (nonatomic, readwrite) BOOL repeat;

/** Returns the current approximate playback position of the current track. */
@property (nonatomic, readonly) NSTimeInterval currentPlaybackPosition;

/** Returns the length of the current track. */
@property (nonatomic, readonly) NSTimeInterval currentTrackDuration;

/** Returns the current track URI, playing or not. */
@property (nonatomic, readonly) NSURL *currentTrackURI;

/** Returns the currenly playing track index */
@property (nonatomic, readonly) int currentTrackIndex;

/** Returns the current streaming bitrate the receiver is using. */
@property (nonatomic, readonly) SPTBitrate targetBitrate;

/** Current position in track list, @see currentTrackIndex */
@property (nonatomic, readwrite) int trackListPosition DEPRECATED_ATTRIBUTE;

@property (nonatomic, readonly) int trackListSize;

/** Number of queued items */
@property (nonatomic, readonly) int queueSize DEPRECATED_ATTRIBUTE;

@end


/// Defines events relating to the connection to the Spotify service.
@protocol SPTAudioStreamingDelegate <NSObject>

@optional

/** Called when the streaming controller logs in successfully.
 @param audioStreaming The object that sent the message.
 */
-(void)audioStreamingDidLogin:(SPTAudioStreamingController *)audioStreaming;

/** Called when the streaming controller logs out.
 @param audioStreaming The object that sent the message.
 */
-(void)audioStreamingDidLogout:(SPTAudioStreamingController *)audioStreaming;

/** Called when the streaming controller encounters a temporary connection error.
 
 You should not throw an error to the user at this point. The library will attempt to reconnect without further action.

 @param audioStreaming The object that sent the message.
 */
-(void)audioStreamingDidEncounterTemporaryConnectionError:(SPTAudioStreamingController *)audioStreaming;

/** Called when the streaming controller encounters a fatal error.
 
 At this point it may be appropriate to inform the user of the problem.

 @param audioStreaming The object that sent the message.
 @param error The error that occurred.
 */
-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didEncounterError:(NSError *)error;

/** Called when the streaming controller recieved a message for the end user from the Spotify service.

 This string should be presented to the user in a reasonable manner.

 @param audioStreaming The object that sent the message.
 @param message The message to display to the user.
 */
-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveMessage:(NSString *)message;

/** Called when network connectivity is lost.
 @param audioStreaming The object that sent the message.
 */
-(void)audioStreamingDidDisconnect:(SPTAudioStreamingController *)audioStreaming;

/** Called when network connectivitiy is back after being lost.
 @param audioStreaming The object that sent the message.
 */
-(void)audioStreamingDidReconnect:(SPTAudioStreamingController *)audioStreaming;

@end


/// Defines events relating to audio playback.
@protocol SPTAudioStreamingPlaybackDelegate <NSObject>

@optional

/** Called when playback status changes.
 @param audioStreaming The object that sent the message.
 @param isPlaying Set to `YES` if the object is playing audio, `NO` if it is paused.
 */
-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying;

/** Called when playback is seeked "unaturally" to a new location.
 @param audioStreaming The object that sent the message.
 @param offset The new playback location.
 */
-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didSeekToOffset:(NSTimeInterval)offset;

/** Called when playback volume changes.
 @param audioStreaming The object that sent the message.
 @param volume The new volume.
 */
-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeVolume:(SPTVolume)volume;

/** Called when shuffle status changes.
 @param audioStreaming The object that sent the message.
 @param isShuffled Set to `YES` if the object requests shuffled playback, otherwise `NO`.
 */
-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeShuffleStatus:(BOOL)isShuffled;

/** Called when repeat status changes.
 @param audioStreaming The object that sent the message.
 @param isRepeated Set to `YES` if the object requests repeated playback, otherwise `NO`.
 */
-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeRepeatStatus:(BOOL)isRepeated;

/** Called when playback moves to a new track.
 @param audioStreaming The object that sent the message.
 @param trackMetadata Metadata for the new track. See -currentTrackMetadata for keys.
 */
-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeToTrack:(NSDictionary *)trackMetadata;

/** Called when the streaming controller fails to play a track.
 
 This typically happens when the track is not available in the current users' region, if you're playing
 multiple tracks the playback will start playing the next track automatically
 
 @param audioStreaming The object that sent the message.
 @param trackUri The URI of the track that failed to play.
 */
-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didFailToPlayTrack:(NSURL *)trackUri;

/** Called when the streaming controller begins playing a new track.
 
 @param audioStreaming The object that sent the message.
 @param trackUri The URI of the track that started to play.
 */
-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStartPlayingTrack:(NSURL *)trackUri;

/** Called before the streaming controller begins playing another track.
 
 @param audioStreaming The object that sent the message.
 @param trackUri The URI of the track that stopped.
 */
-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStopPlayingTrack:(NSURL *)trackUri;

/** Called when the audio streaming object requests playback skips to the next track.
 @param audioStreaming The object that sent the message.
 */
-(void)audioStreamingDidSkipToNextTrack:(SPTAudioStreamingController *)audioStreaming;

/** Called when the audio streaming object requests playback skips to the previous track.
 @param audioStreaming The object that sent the message.
 */
-(void)audioStreamingDidSkipToPreviousTrack:(SPTAudioStreamingController *)audioStreaming;

/** Called when the audio streaming object becomes the active playback device on the user's account.
 @param audioStreaming The object that sent the message.
 */
-(void)audioStreamingDidBecomeActivePlaybackDevice:(SPTAudioStreamingController *)audioStreaming;

/** Called when the audio streaming object becomes an inactive playback device on the user's account.
 @param audioStreaming The object that sent the message.
 */
-(void)audioStreamingDidBecomeInactivePlaybackDevice:(SPTAudioStreamingController *)audioStreaming;

/** Called when the streaming controller lost permission to play audio.

 This typically happens when the user plays audio from their account on another device.

 @param audioStreaming The object that sent the message.
 */
-(void)audioStreamingDidLosePermissionForPlayback:(SPTAudioStreamingController *)audioStreaming;

/** Called when the streaming controller popped a new item from the playqueue.
 
 @param audioStreaming The object that sent the message.
 */
-(void)audioStreamingDidPopQueue:(SPTAudioStreamingController *)audioStreaming;

@end
