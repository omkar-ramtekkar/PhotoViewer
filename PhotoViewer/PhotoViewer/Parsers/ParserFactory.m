//
//  ParserFactory.m
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import "ParserFactory.h"
#import "ErrorParser.h"
#import "AlbumJSONParser.h"
#import "ImageJSONParser.h"
#import "Constant.h"

@implementation ParserFactory

+(ParserBase*) createParserForService:(NSString*) serviceName withData:(NSData*) data
{
    assert(serviceName && data);
    
    if (serviceName && data)
    {
        if ([serviceName isEqualToString:kServiceNameGetAlbums])
        {
            return [[AlbumJSONParser alloc] initWithData:data];
        }
        else if ([serviceName isEqualToString:kServiceNameGetImages])
        {
            return [[ImageJSONParser alloc] initWithData:data];
        }
        else
        {
            assert(false);//Add parser for service
        }
    }
    else
    {
        NSLog(@"Invalid Argument to Parser Factory : Unable to create parser");
        assert(false);
    }
    
    return nil;
}

+(ParserBase*) createErrorParserWithData:(NSData*) data
{
    return [[ErrorParser alloc] initWithData:data];
}

@end
