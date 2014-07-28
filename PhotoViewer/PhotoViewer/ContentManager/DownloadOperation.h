//
//  DownloadOperation.h
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ResourceRequest;

@interface DownloadOperation : NSOperation
{
@protected
    BOOL            _bFinished;
    BOOL            _bExecuting;
    BOOL            _bIsConcurrent;
    BOOL            _bPaused;
    NSUInteger      _progress;
    
    NSMutableSet    *_delegates;
    
    NSMutableData   *_responseData;
    NSURLConnection *_urlConnection;
    ResourceRequest *_resourceRequest;
    NSUInteger       _expectedContentLength;
    NSFileHandle    *_temporaryFile;
    NSString        *_partialDownloadFile;
}

@property(nonatomic, assign) BOOL concurrent;
@property(assign, nonatomic) BOOL supportPauseResume;

@property(readonly, nonatomic) NSData *responseData;
@property(readonly, assign) NSUInteger progress;
@property(readonly, nonatomic) ResourceRequest *request;
@property(readonly, nonatomic) NSString *partialDownloadFile;
@property(readonly, nonatomic) BOOL isPaused;
@property(readonly, nonatomic) NSSet *delegates;

-(id) initWithRequest:(ResourceRequest*) request;
+(DownloadOperation*) operationWithDownloadOperation:(DownloadOperation*) operation;

-(void) addDelegate:(id) delegate;
-(void) removeDelegate:(id) delegate;

-(BOOL) pause;

@end
