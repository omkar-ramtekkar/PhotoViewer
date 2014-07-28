//
//  OfflineStorageModel.h
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import <limits.h>

@class Resource;

@interface OfflineStorageModel : NSObject


-(id) initWithOfflineDirectory:(NSString*)offlineDirPath andOfflineCapacity:(NSUInteger) megabytes;

- (void) setOfflineStorageCapacity:(NSUInteger) megabytes;
- (NSUInteger) getOfflineStorageCapacity;

-(BOOL) isResourceAvailable:(Resource*) resource;
-(id) getDataAssociatedWithResource:(Resource*) resource;

-(BOOL) deleteResource:(Resource*) resource;
-(BOOL) saveData:(NSData*) data forResource:(Resource*) resource;


@end
