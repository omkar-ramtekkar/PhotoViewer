//
//  PhotoViewerModel.m
//  PhotoViewer
//
//  Created by Om on 18/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import "PhotoViewerModel.h"

@interface PhotoViewerModel()

@property(nonatomic, strong) NSArray *albums;

@end

@implementation PhotoViewerModel

@synthesize albums;

-(id) initWithAlbums:(NSArray*) allAlbums
{
    self = [super init];
    if (self)
    {
        self.albums = allAlbums;
    }
    
    return self;
}

@end
