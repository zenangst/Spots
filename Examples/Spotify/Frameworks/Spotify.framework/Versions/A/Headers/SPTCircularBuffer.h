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

/** This class is a simple implementation of a circular buffer, designed to match the behaviour of the iOS SDK.
 
 This class gets around the problem of filling the buffer too far ahead by having a maximum size. Once that
 size is reached, you cannot add more data without reading some out or clearing it and starting again. When 
 used with the iOS SDK, this isn't a problem as we can ask the library to re-deliver audio data at a later time.
 */

#import <Foundation/Foundation.h>

@interface SPTCircularBuffer : NSObject

/** Initialize a new buffer. 
 
 Initial size will be zero, with a maximum size as provided.
 
 @param size The maximum size of the buffer, in bytes. 
 @return Returns the newly created SPTCircularBuffer.
 */
-(id)initWithMaximumLength:(NSUInteger)size;

/** Clears all data from the buffer. */
-(void)clear;

/** Attempt to copy new data into the buffer.
 
 Data is copied using the following heuristic:
 
 - If dataLength <= (maximumLength - length), copy all data.
 - Otherwise, copy (maximumLength - length) bytes.
 
 @param data A buffer containing the data to be copied in.
 @param dataLength The length of the data, in bytes.
 @return Returns the amount of data copied into the buffer, in bytes. If this number is 
 smaller than dataLength, only this number of bytes was copied in from the start of the given buffer.
 */
-(NSUInteger)attemptAppendData:(const void *)data ofLength:(NSUInteger)dataLength;

/** Attempt to copy new data into the buffer.

 Data is copied using the following heuristic:

 - If dataLength <= (maximumLength - length), copy all data.
 - Otherwise, copy (maximumLength - length) bytes.
 - Number of bytes copied will be rounded to the largest number less than dataLength that can be
   integrally be divided by chunkSize.

 @param data A buffer containing the data to be copied in.
 @param dataLength The length of the data, in bytes.
 @param chunkSize Ensures the number of bytes copies in is a multiple of this number.
 @return Returns the amount of data copied into the buffer, in bytes. If this number is
 smaller than dataLength, only this number of bytes was copied in from the start of the given buffer.
 */
-(NSUInteger)attemptAppendData:(const void *)data ofLength:(NSUInteger)dataLength chunkSize:(NSUInteger)chunkSize;

/** Read data out of the buffer into a pre-allocated buffer.
 
 @param desiredLength The desired number of bytes to copy out.
 @param outBuffer A pointer to a buffer, which must be malloc'ed with at least `desiredLength` bytes. 
 @return Returns the amount of data copied into the given buffer, in bytes.
 */
-(NSUInteger)readDataOfLength:(NSUInteger)desiredLength intoAllocatedBuffer:(void **)outBuffer;

/** Returns the amount of data currently in the buffer, in bytes. */
@property (readonly) NSUInteger length;

/** Returns the maximum amount of data that the buffer can hold, in bytes. */
@property (readonly, nonatomic) NSUInteger maximumLength;

@end
