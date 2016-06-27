//
//  CocoaLibSpotify.h
//  CocoaLibSpotify
//
//  Created by Daniel Kennett on 3/7/11.
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

#if TARGET_OS_IPHONE

#import "SPErrorExtensions.h"
#import "SPURLExtensions.h"
#import "SPAlbum.h"
#import "SPArtist.h"
#import "SPImage.h"
#import "SPUser.h"
#import "SPSession.h"
#import "SPPlaylist.h"
#import "SPPlaylistFolder.h"
#import "SPPlaylistItem.h"
#import "SPTrack.h"
#import "SPPlaylistContainer.h"
#import "SPSearch.h"
#import "SPPostTracksToInboxOperation.h"
#import "SPArtistBrowse.h"
#import "SPAlbumBrowse.h"
#import "SPToplist.h"
#import "SPUnknownPlaylist.h"

#import "SPSignupViewController.h"
#import "SPLoginViewController.h"

#import "SPCircularBuffer.h"
#import "SPCoreAudioController.h"
#import "SPPlaybackManager.h"

#import "SPAsyncLoading.h"

#else

#import <CocoaLibSpotify/SPErrorExtensions.h>
#import <CocoaLibSpotify/SPURLExtensions.h>
#import <CocoaLibSpotify/SPAlbum.h>
#import <CocoaLibSpotify/SPArtist.h>
#import <CocoaLibSpotify/SPImage.h>
#import <CocoaLibSpotify/SPUser.h>
#import <CocoaLibSpotify/SPSession.h>
#import <CocoaLibSpotify/SPPlaylist.h>
#import <CocoaLibSpotify/SPPlaylistFolder.h>
#import <CocoaLibSpotify/SPPlaylistItem.h>
#import <CocoaLibSpotify/SPTrack.h>
#import <CocoaLibSpotify/SPPlaylistContainer.h>
#import <CocoaLibSpotify/SPSearch.h>
#import <CocoaLibSpotify/SPPostTracksToInboxOperation.h>
#import <CocoaLibSpotify/SPArtistBrowse.h>
#import <CocoaLibSpotify/SPAlbumBrowse.h>
#import <CocoaLibSpotify/SPToplist.h>
#import <CocoaLibSpotify/SPUnknownPlaylist.h>
#import <CocoaLibSpotify/SPCircularBuffer.h>
#import <CocoaLibSpotify/SPCoreAudioController.h>
#import <CocoaLibSpotify/SPPlaybackManager.h>
#import <CocoaLibSpotify/SPAsyncLoading.h>

#endif
