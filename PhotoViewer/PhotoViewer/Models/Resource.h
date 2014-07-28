//
//  ResourceEntity.h
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    enumImage = 1,
    enumAudio,
    enumVideo
} ResourceType;


@interface Resource : NSObject<NSCopying>

+(id) resourceWithURL:(NSURL*) url;

@property (nonatomic, copy) NSNumber * type;
@property (nonatomic, copy) NSString * url;
@property (nonatomic, copy) NSString * version;

@end
