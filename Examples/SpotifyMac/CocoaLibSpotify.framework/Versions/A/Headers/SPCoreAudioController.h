//
//  SPCoreAudioController.h
//  Viva
//
//  Created by Daniel Kennett on 04/02/2012.
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

// This class encapsulates a Core Audio graph that includes
// an audio format converter, a mixer for iOS volume control and a standard output.
// Clients just need to set the various properties and not worry about the details.

#import <Foundation/Foundation.h>
#import "CocoaLibSpotifyPlatformImports.h"
#import "SPSession.h"
#import <AudioToolbox/AudioToolbox.h>

@class SPCoreAudioController;

/** Provides delegate callbacks for SPCoreAudioController. */

@protocol SPCoreAudioControllerDelegate <NSObject>

/** Called repeatedly during audio playback when audio is pushed to the system's audio output.
 
 This can be used to keep track of how much audio has been played back for progress indicators and so on.
 
 @param controller The SPCoreAudioController that pushed audio.
 */
-(void)coreAudioController:(SPCoreAudioController *)controller didOutputAudioOfDuration:(NSTimeInterval)audioDuration;

@end

/** Provides an audio pipeline from CocoaLibSpotify to the system's audio output. */

@interface SPCoreAudioController : NSObject <SPSessionAudioDeliveryDelegate>

///----------------------------
/// @name Control
///----------------------------

/**
 Completely empties all audio that's buffered for playback. 
 
 This should be called when you need cancel all pending audio in order to,
 for example, play a new track.
 */
-(void)clearAudioBuffers;

///----------------------------
/// @name Customizing the audio pipeline
///----------------------------

/**
 Connects the given `AUNode` instances together to complete the audio pipeline for playback.
 
 If you wish to customise the audio pipeline, you can do so by overriding this method and inserting your 
 own `AUNode` instances between `sourceNode` and `destinationNode`.
 
 This method will be called whenever the audio pipeline needs to be (re)built.

 @warning If you override this method and connect the nodes yourself, do not call the `super`
 implementation. You can, however, conditionally decide whether to customise the queue and call `super`
 if you want the default behaviour.
 
 @param sourceOutputBusNumber The bus on which the source node will be providing audio data.
 @param sourceNode The `AUNode` which will provide audio data for the graph.
 @param destinationInputBusNumber The bus on which the destination node expects to receive audio data.
 @param destinationNode The `AUNode` which will carry the audio data to the system's audio output.
 @param graph The `AUGraph` containing the given nodes.
 @param error A pointer to an NSError instance to be filled with an `NSError` should a problem occur.
 @return `YES` if the connection was made successfully, otherwise `NO`.
 */
-(BOOL)connectOutputBus:(UInt32)sourceOutputBusNumber ofNode:(AUNode)sourceNode toInputBus:(UInt32)destinationInputBusNumber ofNode:(AUNode)destinationNode inGraph:(AUGraph)graph error:(NSError **)error;

/** 
 Called when custom nodes in the pipeline should be disposed.
 
 If you inserted your own `AUNode` instances into the audio pipeline, override this method to
 perform any cleanup needed.
 
 This method will be called whenever the audio pipeline is being torn down.
 
 @param graph The `AUGraph` that is being disposed. 
 */
-(void)disposeOfCustomNodesInGraph:(AUGraph)graph;

///----------------------------
/// @name Properties
///----------------------------

/**
 Returns the volume of audio playback, between `0.0` and `1.0`.
 
 This property only applies to audio played back through this class, not the system audio volume.
*/
@property (readwrite, nonatomic) double volume;

/** Whether audio output is enabled. */
@property (readwrite, nonatomic) BOOL audioOutputEnabled;

/** Returns the receiver's delegate. */
@property (readwrite, nonatomic, assign) __unsafe_unretained id <SPCoreAudioControllerDelegate> delegate;

@end
