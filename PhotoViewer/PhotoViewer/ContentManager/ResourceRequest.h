//
//  ResourceRequest.h
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Resource;

@interface ResourceRequest : NSObject<NSCopying>

@property(nonatomic, retain) Resource *resource;
@property(nonatomic, retain) id delegate;
@property(nonatomic, assign) BOOL supportPauseResume;

@end
