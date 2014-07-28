//
//  DownloadManager.h
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadOperationDelegate.h"

@class ResourceRequest;
@class Reachability;


@interface DownloadManager : NSObject<DownloadOperationDelegate>
{
@private
    NSOperationQueue    *_queue;
    Reachability        *_internetConnectionReachability;
    Reachability        *_wifiConnectionReachability;
    
    NSMutableDictionary *_runningOperations; //<Dictonary of ScreenName vs Array of running DownloadOperation>[NSString, NSArray]
    NSMutableDictionary *_pausedOperations; //<Dictonary of ScreenName vs Array of paused DownloadOperation>[NSString, NSArray]
}

+(DownloadManager*) sharedInstance;
-(void) releaseInstance;
-(BOOL) isInternetConnectionAvailable;

-(void) downloadResource:(ResourceRequest*) resourceRequest overriteIfExists:(BOOL) bOverrite context:(void*) context;

-(void) cancelResourceRequest:(ResourceRequest*) request context:(void*) context;
-(void) pauseResourceRequest:(ResourceRequest*) request context:(void*) context;
-(void) resumeResourceRequest:(ResourceRequest*) request context:(void*) context;

-(void) cancelAllResourceRequests:(void*) context;
-(void) pauseAllResourceRequests:(void*) context;
-(void) resumeAllResourceRequests:(void*) context;

@end
