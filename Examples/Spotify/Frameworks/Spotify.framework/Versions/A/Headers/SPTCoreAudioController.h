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

// This class encapsulates a Core Audio graph that includes
// an audio format converter, a mixer for iOS volume control and a standard output.
// Clients just need to set the various properties and not worry about the details.

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIApplication.h>
#endif

@class SPTCoreAudioController;
@class SPTCoreAudioDevice;

/** Provides delegate callbacks for SPTCoreAudioController. */

@protocol SPTCoreAudioControllerDelegate <NSObject>

@optional

/** Called repeatedly during audio playback when audio is pushed to the system's audio output.
 
 This can be used to keep track of how much audio has been played back for progress indicators and so on.
 
 @param controller The SPTCoreAudioController that pushed audio.
 @param audioDuration The duration of the audio that was pushed to the output device.
 */
-(void)coreAudioController:(SPTCoreAudioController *)controller didOutputAudioOfDuration:(NSTimeInterval)audioDuration;

@end

/** Provides an audio pipeline from SPTAudioStreamingController to the system's audio output. */

@interface SPTCoreAudioController : NSObject

///----------------------------
/// @name Control
///----------------------------

/**
 Completely empties all audio that's buffered for playback. 
 
 This should be called when you need cancel all pending audio in order to,
 for example, play a new track.
 */
-(void)clearAudioBuffers;

/**
 Attempts to deliver the passed audio frames passed to the audio output pipeline.
 
 @param audioFrames A buffer containing the audio frames. 
 @param frameCount The number of frames included in the buffer.
 @param audioDescription A description of the audio contained in `audioFrames`.
 @return Returns the number of frames actually delievered to the audio pipeline. If this is less than `frameCount`, 
  you need to retry delivery again later as the internal buffers are full.
 */
-(NSInteger)attemptToDeliverAudioFrames:(const void *)audioFrames ofCount:(NSInteger)frameCount streamDescription:(AudioStreamBasicDescription)audioDescription;

/** Returns the number of bytes in the audio buffer. */
-(uint32_t)bytesInAudioBuffer;

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
@property (readwrite, nonatomic, weak) id <SPTCoreAudioControllerDelegate> delegate;

#if !TARGET_OS_IPHONE

/** Returns the available audio output devices. Mac only. */
@property (readonly, nonatomic, copy) NSArray *availableOutputDevices;

/** Returns the current output device. Set to `nil` to use the system default. Mac only. */
@property (readwrite, nonatomic, strong) SPTCoreAudioDevice *currentOutputDevice;

#endif

#if TARGET_OS_IPHONE

/** Current background playback task reference. */
@property (readwrite, nonatomic) UIBackgroundTaskIdentifier backgroundPlaybackTask;

#endif
 
@end
