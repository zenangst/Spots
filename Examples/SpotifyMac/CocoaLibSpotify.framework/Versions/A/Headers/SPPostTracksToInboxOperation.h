//
//  SPPostTracksToInboxOperation.h
//  CocoaLibSpotify
//
//  Created by Daniel Kennett on 4/24/11.
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

/** This class provides functionality for sending tracks to another Spotify user. */

#import <Foundation/Foundation.h>
#import "CocoaLibSpotifyPlatformImports.h"

@class SPSession;
@protocol SPPostTracksToInboxOperationDelegate;

@interface SPPostTracksToInboxOperation : NSObject

///----------------------------
/// @name Creating and Initializing Track Post Operations
///----------------------------

/** Creates an SPPostTracksToInboxOperation for the given details.
 
 This convenience method is simply returns a new, autoreleased SPPostTracksToInboxOperation
 object. No caching is performed.
 
 @warning Tracks will be posted to the given user as soon as a SPPostTracksToInboxOperation
 object is created. Be sure you want to post the tracks before creating the object!
 
 @param tracksToSend An array of SPTrack objects to send.
 @param user The username of the user to send the tracks to.
 @param aFriendlyGreeting The message to send with the tracks, if any.
 @param aSession The session to send the tracks with.
 @param block The `SPErrorableOperationCallback` block to be called with an `NSError` if the operation failed or `nil` if the operation succeeded.
 @return Returns the created SPPostTracksToInboxOperation object. 
 */
+(SPPostTracksToInboxOperation *)sendTracks:(NSArray *)tracksToSend
									 toUser:(NSString *)user 
									message:(NSString *)aFriendlyGreeting
								  inSession:(SPSession *)aSession
								   callback:(SPErrorableOperationCallback)block;

/** Initializes an SPPostTracksToInboxOperation for the given details.
 
 @warning Tracks will be posted to the given user as soon as a SPPostTracksToInboxOperation
 object is created. Be sure you want to post the tracks before creating the object!
 
 @param tracksToSend An array of SPTrack objects to send.
 @param user The username of the user to send the tracks to.
 @param aFriendlyGreeting The message to send with the tracks, if any.
 @param aSession The session to send the tracks with.
 @param block The `SPErrorableOperationCallback` block to be called with an `NSError` if the operation failed or `nil` if the operation succeeded.
 @return Returns the created SPPostTracksToInboxOperation object. 
 */
-(id)initBySendingTracks:(NSArray *)tracksToSend
				  toUser:(NSString *)user 
				 message:(NSString *)aFriendlyGreeting
			   inSession:(SPSession *)aSession
				callback:(SPErrorableOperationCallback)block;

///----------------------------
/// @name Properties
///----------------------------

/** Returns the username of the user the tracks the operation is sending tracks to. */
@property (nonatomic, readonly, copy) NSString *destinationUser;

/** Returns the opaque structure used by the C LibSpotify API. 
 
 @warning This method *must* be called on the libSpotify thread. See the
 "Threading" section of the library's readme for more information.
 
 @warning This should only be used if you plan to directly use the 
 C LibSpotify API. The behaviour of CocoaLibSpotify is undefined if you use the C
 API directly on items that have CocoaLibSpotify objects associated with them. 
 */
@property (nonatomic, readonly, assign) sp_inbox *inboxOperation;

/** Returns the message being sent. */
@property (nonatomic, readonly, copy) NSString *message;

/** Returns the session the tracks are being sent in. */
@property (nonatomic, readonly, strong) SPSession *session;

/** Returns the tracks being sent. */
@property (nonatomic, readonly, copy) NSArray *tracks;

@end