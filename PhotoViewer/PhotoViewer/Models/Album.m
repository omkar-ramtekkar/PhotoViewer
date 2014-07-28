//
//  Album.m
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import "Album.h"
#import "Image.h"

@interface Album()

@property (nonatomic, strong) NSNumber *id;

@end

@implementation Album

@synthesize caption;
@synthesize desc;
@synthesize images = _images;
@synthesize albumImage;
@synthesize id;

+(id) albumWithName:(NSString*) name andImages:(NSArray*) images
{
    return [[Album alloc] initWithName:name andImages:images];
}

-(id) initWithName:(NSString*) name andImages:(NSArray*) images
{
    self = [super init];
    if (self)
    {
        self.caption = name;
        _images = [[NSMutableArray alloc] initWithArray:images];
    }
    
    return self;
}

-(id) copyWithZone:(NSZone *)zone
{
    Album *album = [[Album alloc] initWithName:self.caption andImages:[self.images copy]];
    album.id = [self.id copy];
    album.desc = [self.desc copy];
    album.albumImage = [self.albumImage copy];
    
    return album;
}

-(BOOL) addImage:(Image*) anImage
{
    if (!_images)
    {
        _images = [[NSMutableArray alloc] init];
    }
    
    [_images addObject:anImage];
    
    return YES;
}

-(BOOL) addImages:(NSArray*) images
{
    if (!_images)
    {
        _images = [[NSMutableArray alloc] initWithCapacity:images.count];
    }
    
    [_images addObjectsFromArray:images];
    
    return YES;
}

-(BOOL) deleteImage:(Image*) anImage
{
    @throw @"Not Implemented";
}

@end
