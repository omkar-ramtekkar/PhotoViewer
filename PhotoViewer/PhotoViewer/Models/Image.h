//
//  Image.h
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Image : NSObject<NSCopying>

+(id) imageWithURL:(NSURL*) url;
+(id) imageWithDict:(NSDictionary*) infoDict;

@property (nonatomic, copy) NSURL * url;
@property (nonatomic, copy) NSNumber * height;
@property (nonatomic, copy) NSNumber * width;
@property (nonatomic, copy) NSString * caption;
@property (nonatomic, copy) NSString * desc;

@end
