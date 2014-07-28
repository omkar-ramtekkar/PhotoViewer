//
//  Image.m
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import "Image.h"

@implementation Image

@synthesize url;
@synthesize height;
@synthesize width;
@synthesize caption;
@synthesize desc;


+(id) imageWithURL:(NSURL*) url
{
    assert(url);
    
    if (url)
    {
        Image *image = [[Image alloc] init];
        image.url = url;
        
        return image;
    }
    
    return nil;
}

-(id) copyWithZone:(NSZone *)zone
{
    Image *image = [[Image alloc] init];
    image.url = self.url;
    image.desc = self.desc;
    image.caption = self.caption;
    image.width = self.width;
    image.height = self.height;
    
    return image;
}

+(id) imageWithDict:(NSDictionary*) infoDict
{
    return [Image imageWithURL: [NSURL URLWithString:[infoDict objectForKey:@"link"]]];
}

@end
