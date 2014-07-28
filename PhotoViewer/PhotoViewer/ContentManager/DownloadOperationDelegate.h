//
//  DownloadOperationDelegate.h
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DownloadOperation;

@protocol DownloadOperationDelegate <NSObject>

@optional

-(void) downloadDidFail:(DownloadOperation*) operation withErro:(NSError*) error;

-(void) downloadDidStart:(DownloadOperation*) operation;
-(void) downloadDidFinish:(DownloadOperation*) operation;
-(void) downloadProgressDidUpdate:(DownloadOperation*) operation;

@end
