//
//  SPCircularBuffer.h
//  Viva
//
//  Created by Daniel Kennett on 4/9/11.
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

/** This class is a simple implementation of a circular buffer, designed to match the behaviour of (Cocoa)LibSpotify.
 
 This class gets around the problem of filling the buffer too far ahead by having a maximum size. Once that
 size is reached, you cannot add more data without reading some out or clearing it and starting again. When 
 used with (Cocoa)LibSpotify, this isn't a problem as we can ask the library to re-deliver audio data at a later time.
 */

#import <Foundation/Foundation.h>

@interface SPCircularBuffer : NSObject {
@private
    void *buffer;
	NSUInteger maximumLength;
	NSUInteger dataStartOffset;
	NSUInteger dataEndOffset;
	BOOL empty;
}

/** Initialize a new buffer. 
 
 Initial size will be zero, with a maximum size as provided.
 
 @param size The maximum size of the buffer, in bytes. 
 @return Returns the newly created SPCircularBuffer.
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
