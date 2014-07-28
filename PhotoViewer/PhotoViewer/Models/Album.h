//
//  Album.h
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Image;

@interface Album : NSObject<NSCopying>
{
    NSMutableArray *_images;
}

@property (nonatomic, strong) NSString * caption;
@property (nonatomic, strong) NSString * desc;
@property (nonatomic, readonly) NSArray *images;
@property (nonatomic, readonly) NSNumber *id;
@property (nonatomic, strong) Image *albumImage;

+(id) albumWithName:(NSString*) name andImages:(NSArray*) images;
-(id) initWithName:(NSString*) name andImages:(NSArray*) images;

-(BOOL) addImage:(Image*) anImage;
-(BOOL) addImages:(NSArray*) images;
-(BOOL) deleteImage:(Image*) anImage;

@end
