//
//  AlbumEntity.m
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import "AlbumEntity.h"
#import "ImageEntity.h"
#import "Album.h"
#import "CoreDataManager.h"


@implementation AlbumEntity

@dynamic caption;
@dynamic desc;
@dynamic id;
@dynamic images;
@dynamic albumImage;

-(id) getModel
{
    Album *anAlbum = [[Album alloc] initWithName:self.caption andImages: [[CoreDataManager getModelsFromEntitySet:self.images] allObjects]];
    anAlbum.albumImage = [self.albumImage getModel];
    anAlbum.desc = self.desc;
    
    return anAlbum;
}

@end
