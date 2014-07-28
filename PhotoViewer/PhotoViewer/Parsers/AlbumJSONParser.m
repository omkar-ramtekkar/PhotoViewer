//
//  AlbumJSONParser.m
//  PhotoViewer
//
//  Created by Om on 18/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import "AlbumJSONParser.h"
#import "ParserFactory.h"
#import "Album.h"
#import "Image.h"
#import "Constant.h"

@implementation AlbumJSONParser

-(id) initWithData:(NSData*) data
{
    self = [super initWithData:data];
    if (self)
    {
        _parserName = kServiceNameGetAlbums;
    }
    
    return self;
}


-(id) parseJSONObjects:(id) data
{
    //As of now, we are only creating one Album
    //TODO : Read complete json data and create avaialble albums
    
    NSDictionary *jsonObjectDict = nil;
    if ([data isKindOfClass:[NSArray class]] && [data count])
    {
        jsonObjectDict = [data objectAtIndex:0];
    }
    else if([data isKindOfClass:[NSDictionary class]])
    {
        jsonObjectDict = data;
    }
    
    NSArray *jsonAllImages = [jsonObjectDict objectForKey:@"img_det"];
    
    NSMutableArray *allImages = [NSMutableArray array];
    
    for (NSDictionary *imageInfoDict in jsonAllImages)
    {
        Image *anImage = [Image imageWithDict:imageInfoDict];
        if (anImage)
        {
            [allImages addObject: anImage];
        }
    }
    
    Album *album = [[Album alloc] initWithName:[jsonObjectDict objectForKey:@"category_title"] andImages:allImages];
    album.albumImage = [Image imageWithURL:[NSURL URLWithString:[jsonObjectDict objectForKey:@"image_url"]]];
    
    return [NSArray arrayWithObject:album];
}

@end
