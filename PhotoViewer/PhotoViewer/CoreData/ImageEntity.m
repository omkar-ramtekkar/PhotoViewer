//
//  ImageEntity.m
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import "ImageEntity.h"
#import "Image.h"


@implementation ImageEntity

@dynamic url;
@dynamic height;
@dynamic width;
@dynamic caption;
@dynamic desc;


-(id) getModel
{
    Image *image = [[Image alloc] init];
    image.url       = [NSURL URLWithString:self.url];
    image.height    = self.height;
    image.width     = self.width;
    image.caption   = self.caption;
    image.desc      = self.desc;
    
    return image;
}

@end
