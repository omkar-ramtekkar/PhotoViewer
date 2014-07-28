//
//  ImageJSONParser.m
//  PhotoViewer
//
//  Created by Om on 18/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import "ImageJSONParser.h"

@implementation ImageJSONParser

-(id) initWithData:(NSData*) data
{
    self = [super initWithData:data];
    if (self)
    {
        _parserName = kServiceNameGetImages;
    }
    
    return self;
}


-(id) parseJSONObjects:(id) data
{
    @throw @"Not Implemented";
}

@end
