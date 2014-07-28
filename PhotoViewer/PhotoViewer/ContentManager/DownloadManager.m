//
//  DownloadManager.m
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import "DownloadManager.h"
#import "DownloadOperation.h"
#import "Resource.h"
#import "ResourceRequest.h"
#import "AppStore.h"
#import "Reachability.h"
#import "Constant.h"
#import "Reachability.h"

static DownloadManager* downloadManager_g = nil;


NSString* GetDownloadDirPath()
{
    static NSString *downloadDirPath_g = nil;
    if (downloadDirPath_g)
    {
        return downloadDirPath_g;
    }
    else
    {
        //Offline Dir Path
        NSString *libraryDirPath = (NSString*)[[[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject] path];
        downloadDirPath_g = [[libraryDirPath stringByAppendingPathComponent:@"Downloads"] copy];
    }
    return downloadDirPath_g;
}


@interface DownloadManager()

-(void) initialize;

@end


@implementation DownloadManager

+(DownloadManager*) sharedInstance
{
    if (downloadManager_g)
    {
        return downloadManager_g;
    }
    else
    {
        static dispatch_once_t pred;
        dispatch_once(&pred,^{
            downloadManager_g = [[DownloadManager alloc] init];
            assert(downloadManager_g);
            [downloadManager_g initialize];
        });
        
        return downloadManager_g;
    }
}

-(void) initialize
{    
    _queue = [[NSOperationQueue alloc] init];
    [_queue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    [_queue setName:@"ResourceDownloadQueue"];
    
    _runningOperations = [[NSMutableDictionary alloc] init];
    _pausedOperations = [[NSMutableDictionary alloc] init];
    
    _internetConnectionReachability = [Reachability reachabilityForInternetConnection];
    _wifiConnectionReachability = [Reachability reachabilityForLocalWiFi];
}


-(void) releaseInstance
{
    downloadManager_g = nil;
}


-(BOOL) isInternetConnectionAvailable
{
    BOOL bReachable =  ([_internetConnectionReachability currentReachabilityStatus] != NotReachable);
    bReachable |=  ([_wifiConnectionReachability currentReachabilityStatus] != NotReachable);

    return bReachable;
}



-(void) downloadResource:(ResourceRequest*) resourceRequest overriteIfExists:(BOOL) bOverrite context:(void*) context
{
    NSString *screenName = (__bridge NSString*) context;
    assert(screenName);
    
    BOOL bAvailable = [[AppStore sharedAppStore] isResourceAvailable:resourceRequest.resource];
    BOOL bDownload = NO;
    
    if (bOverrite && bAvailable)
    {
        bDownload = YES;
    }
    else if(bAvailable)
    {
        //Return an existing resource
        if ([resourceRequest.delegate respondsToSelector:@selector(downloadDidFinish:)])
        {
            DownloadOperation *dummyOperation = [[DownloadOperation alloc] initWithRequest:resourceRequest];
            [resourceRequest.delegate downloadDidFinish:dummyOperation];
        }
        else
        {
            bDownload = YES;
        }
    }
    else
    {
        //Download Resource
        bDownload = YES;
    }
    
    if (bDownload && (([_internetConnectionReachability currentReachabilityStatus] != NotReachable) ||
                      ([_wifiConnectionReachability currentReachabilityStatus] != NotReachable)) )
    {
        //Check for existing download operation going for same resource
        DownloadOperation *newOperation = [[DownloadOperation alloc] initWithRequest:resourceRequest];
        newOperation.supportPauseResume = resourceRequest.supportPauseResume;
        
        NSArray *queuedOperations = [_queue operations];
        
        DownloadOperation *queuedOperation = nil;
        NSUInteger index = [queuedOperations indexOfObject:newOperation];
        if (index != NSNotFound)
        {
            queuedOperation = [queuedOperations objectAtIndex:index];
        }
        
        //If we have an existing operation in queue then just add the delegate, if not then add it to operation queue.
        if(queuedOperation)
        {
            NSLog(@"Existing Operartion - for request %@", queuedOperation.request);
            for (DownloadOperation *op in _queue.operations)
            {
                @synchronized(op)
                {
                    [op removeDelegate:resourceRequest.delegate];
                }
            }
            
            [queuedOperation addDelegate:resourceRequest.delegate];
        }
        else
        {
            //Now check if the operation is in paused operatinos
            NSArray *pausedOperations = [_pausedOperations objectForKey:screenName];
            DownloadOperation *pausedOperation = nil;
            index = [pausedOperations indexOfObject:newOperation];
            if (index != NSNotFound)
            {
                pausedOperation = [pausedOperations objectAtIndex:index];
            }
            
            if (pausedOperation)
            {
                NSLog(@"Existing Operartion in Paused Queue - for request %@", pausedOperation.request);
                //Now we need to resume the paused operation, before that get all delegates of paused operation and
                //update the newOperation delegates.
                NSSet *delegates = pausedOperation.delegates;
                for (id delegate in delegates)
                {
                    [newOperation addDelegate:delegate];
                }
            }
            
            //CAUTION! : Do not remove pausedOperation from pausedOperations here, it will be removed while observing the keypaths
            
            //TODO - Changing screen name to a common screen, let all images download
            screenName = @"DownloadAllScreen";
            //screenName = [NSString stringWithString:screenName];
            [newOperation addObserver:self forKeyPath:@"isFinished" options:0 context:(__bridge void *)([screenName copy])];
            [newOperation addObserver:self forKeyPath:@"isPaused" options:0 context:(__bridge void *)([screenName copy])];
            [newOperation addObserver:self forKeyPath:@"isExecuting" options:0 context:(__bridge void *)([screenName copy])];
            @synchronized(_queue)
            {
                NSLog(@"Operation Added to Queue for request : %@", newOperation.request);
                
                //Reset previous current delegate from existing operations
                for (DownloadOperation *op in _queue.operations)
                {
                    @synchronized(op)
                    {
                        for (id delegate in newOperation.delegates)
                        {
                            [op removeDelegate:delegate];
                        }
                    }
                }
                
                [_queue addOperation:newOperation];
            }
        }
    }
}

-(void) cancelResourceRequest:(ResourceRequest*) request context:(void*) context
{
    NSString *screenName = (__bridge NSString*) context;
    assert(screenName);
    
    @synchronized(_runningOperations)
    {
        DownloadOperation *op = [[DownloadOperation alloc] initWithRequest:request];
        NSMutableArray *runningOperations = [_runningOperations objectForKey:screenName];
        
        NSOperation *operationToCancel = nil;
        
        for (NSOperation *operation in runningOperations)
        {
            if ([operation isEqual:op])
            {
                operationToCancel = operation;
                break;
            }
        }
        
        if (operationToCancel)
        {
            [operationToCancel cancel];
        }
    }
}

-(void) pauseResourceRequest:(ResourceRequest*) request context:(void*) context
{
    NSString *screenName = (__bridge NSString*) context;
    assert(screenName);
    assert(request.supportPauseResume);//Request should support pause-resume
    
    @synchronized(_runningOperations)
    {
        DownloadOperation *op = [[DownloadOperation alloc] initWithRequest:request];
        NSMutableArray *runningOperations = [_runningOperations objectForKey:screenName];
        DownloadOperation *operationToPause = nil;
        
        for (DownloadOperation *operation in runningOperations)
        {
            if ([operation isEqual:op])
            {
                operationToPause = operation;
                break;
            }
        }
        
        if (operationToPause)
        {
            [operationToPause pause];
        }
    }
}

-(void) resumeResourceRequest:(ResourceRequest*) request context:(void*) context
{
    NSString *screenName = (__bridge NSString*) context;
    assert(screenName);
    
    assert(request.supportPauseResume);//Request should support pause-resume
    
    @synchronized(_pausedOperations)
    {
        DownloadOperation *op = [[DownloadOperation alloc] initWithRequest:request];
        NSMutableArray *pausedOperations = [_pausedOperations objectForKey:screenName];
        
        DownloadOperation *operationToResume = nil;
        
        for (DownloadOperation *operation in pausedOperations)
        {
            if ([operation isEqual:op])
            {
                operationToResume = operation;
                break;
            }
        }
        
        if (operationToResume)
        {
            [self downloadResource:operationToResume.request overriteIfExists:NO context:context];
            //[_queue addOperation:[DownloadOperation operationWithDownloadOperation:operationToResume]];
        }
    }
}

-(void) cancelAllResourceRequests:(void*) context
{
    NSString *screenName = (__bridge NSString*) context;
    assert(screenName);
    
    @synchronized(_runningOperations)
    {
        NSMutableArray* runningOperations = [_runningOperations objectForKey:screenName];
        
        //PRECAUTION : Use temporary array for iterating operations, since [operation cancel] will cause other flow which
        //may cause _runningOperations to modify.
        NSMutableArray *tempArrayStore = [NSMutableArray arrayWithArray:runningOperations];
        
        for (NSOperation *operation in tempArrayStore)
        {
            [operation cancel];
        }
    }
}

-(void) pauseAllResourceRequests:(void*) context
{
    NSString *screenName = (__bridge NSString*) context;
    assert(screenName);
    
    @synchronized(_runningOperations)
    {
        NSMutableArray *runningOperations = [_runningOperations objectForKey:screenName];
        //PRECAUTION : Use temporary array for iterating operations, since [operation pause] will cause other flow which
        //may cause _runningOperations to modify.
        
        NSMutableArray *tempArrayStore = [NSMutableArray arrayWithArray:runningOperations];
        for (DownloadOperation *operation in tempArrayStore)
        {
            [operation pause];
        }
    }
}

-(void) resumeAllResourceRequests:(void*) context
{
    NSString *screenName = (__bridge NSString*) context;
    assert(screenName);
    
    @synchronized(_pausedOperations)
    {
        NSMutableArray *pausedOperations = [_pausedOperations objectForKey:screenName];
        //PRECAUTION : Use temporary array for iterating operations, since [_queue addOperation:operation] will cause other flow which
        //may cause _pausedOperations to modify.
        NSMutableArray *tempArrayStore = [NSMutableArray arrayWithArray:pausedOperations];
        
        for (DownloadOperation *operation in tempArrayStore)
        {
            [self downloadResource:operation.request overriteIfExists:NO context:context];
        }
    }
}


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object 
                         change:(NSDictionary *)change context:(void *)context
{
    @synchronized(self)
    {
        NSString *screenName = [NSString stringWithString:(__bridge NSString*) context];;
        DownloadOperation *operation = (DownloadOperation*) object;
        
        assert(screenName);
        assert(operation);
        
        if ([keyPath isEqualToString:@"isFinished"])
        {
            //If DownloadOperation changes its state to finished then remove it from runningOperations array
            assert(operation);
            if (operation)
            {
                if(operation.isFinished && !operation.isCancelled && !operation.isPaused)
                {
                    [self downloadDidFinish:object];
                    
                    NSMutableArray *runningOperations = [_runningOperations objectForKey:screenName];
                    [runningOperations removeObject:operation];
                    
                    NSLog(@"Download Manager : %@  Finished", operation);
                }
            }
            
            [operation removeObserver:self forKeyPath:@"isFinished" context:context];
            [operation removeObserver:self forKeyPath:@"isPaused" context:context];
            [operation removeObserver:self forKeyPath:@"isExecuting" context:context];
        }
        else if([keyPath isEqualToString:@"isPaused"])
        {
            //If DownloadOperation changes its state to paused then add it to pausedOperations array
            //Note : Paused is a two state operation
            //1. calcel the execution
            //2. Mark the operation status as paused
            //So do not remove it from runningOperatinos array here, it will be taken care by above if
            NSMutableArray *pausedOperations = [_pausedOperations objectForKey:screenName];
            
            if(operation.isPaused)
            {
                if (!pausedOperations)
                {
                    pausedOperations = [NSMutableArray array];
                    [_pausedOperations setObject:pausedOperations forKey:screenName];
                }
                
                [pausedOperations addObject:operation];
                NSLog(@"Download Manager : %@ Paused", operation);
            }
            else
            {
                [pausedOperations removeObject:operation];
            }
        }
        else if([keyPath isEqualToString:@"isExecuting"])
        {
            NSMutableArray *runningOperations = [_runningOperations objectForKey:screenName];
            
            if(operation.isExecuting)
            {
                if(!runningOperations)
                {
                    runningOperations = [NSMutableArray array];
                    [_runningOperations setObject:runningOperations forKey:screenName];
                }
                [runningOperations addObject:operation];
                
                NSMutableArray *pausedOperations = [_pausedOperations objectForKey:screenName];
                [pausedOperations removeObject:operation];
            }
            else
            {
                [runningOperations removeObject:operation];
            }
            
        }
    }
    
    //Dissolve the keyvalue  change here
    //Note: Do not pass it to super class, otherwise it will throw an exception
}

-(void) downloadDidFinish:(DownloadOperation*) operation
{
    if (operation)
    {
        NSNotification* notification = [NSNotification notificationWithName:kNotificationResourceDownloaded object:operation];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}


-(void) dealloc
{    
    [_queue cancelAllOperations];//Cancel all operations before killing the app
    
    [_runningOperations removeAllObjects];
    
    [_pausedOperations removeAllObjects];
    
    _queue = nil;
    _runningOperations = nil;
    _pausedOperations = nil;
    
    _internetConnectionReachability = nil;
    _wifiConnectionReachability = nil;
}

@end
