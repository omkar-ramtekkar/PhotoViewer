//
//  AppStore.h
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Resource;

@interface AppStore : NSObject

+(AppStore*) sharedAppStore;
+(void) releaseAppStore;
+(void) postNotificationWithName:(NSString*) notificationName;
+(void) postNotification:(NSNotification*) notification;

-(NSArray*) allAlbums;
-(NSArray*) allImages;
-(UIImage*) imageForResource:(Resource*) resource;
-(UIImage*) imageForURL:(NSURL*) url;
-(BOOL) isResourceAvailable:(Resource*) resource;

@end
