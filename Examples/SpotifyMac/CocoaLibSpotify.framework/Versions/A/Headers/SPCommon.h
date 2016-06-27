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

/* 
 This file contains protocols and other things needed throughout the library.
 */

typedef void (^SPErrorableOperationCallback)(NSError *error);

/** Call the given block synchronously on the libSpotify thread, or inline if already on that thread.

 This helper allows you to perform synchronous code on the libSpotify thread.
 It helps avoid deadlocks by checking if you're already on the thread and just calls the
 block inline if that's the case.

 @param block The block to execute.
 */
extern inline void SPDispatchSyncIfNeeded(dispatch_block_t block);

/** Call the given block asynchronously on the libSpotify thread.

 This helper allows you to perform asynchronous operations on the libSpotify thread.

 @param block The block to execute.
 */
extern inline void SPDispatchAsync(dispatch_block_t block);

/** Throw an assertion if the current execution is not on the libSpotify thread.

 This helper macro assists debugging operations on the libSpotify thread.
 */
#define SPAssertOnLibSpotifyThread() NSAssert(CFRunLoopGetCurrent() == [SPSession libSpotifyRunloop], @"Not on correct thread!");

@class SPTrack;
@protocol SPSessionPlaybackDelegate;
@protocol SPSessionAudioDeliveryDelegate;

@protocol SPPlaylistableItem <NSObject>
-(NSString *)name;
-(NSURL *)spotifyURL;
@end

@protocol SPSessionPlaybackProvider <NSObject>

@property (nonatomic, readwrite, getter=isPlaying) BOOL playing;
@property (nonatomic, readwrite, assign) __unsafe_unretained id <SPSessionPlaybackDelegate> playbackDelegate;
@property (nonatomic, readwrite, assign) __unsafe_unretained id <SPSessionAudioDeliveryDelegate> audioDeliveryDelegate;

-(void)preloadTrackForPlayback:(SPTrack *)aTrack callback:(SPErrorableOperationCallback)block;
-(void)playTrack:(SPTrack *)aTrack callback:(SPErrorableOperationCallback)block;
-(void)seekPlaybackToOffset:(NSTimeInterval)offset;
-(void)unloadPlayback;

@end
