//
//  JSONParser.m
//  PhotoViewer
//
//  Created by Om on 18/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import "JSONParser.h"

@implementation JSONParser

-(id) parseJSONObjects:(id) data
{
    @throw @"Not Implemented";
}

-(void) parse
{
    NSError *localError = nil;
    
    [super parserDidStart:self];
    
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:&localError];
    
    if (localError)
    {
        [super parserDidFailWithError:self error:localError];
    }
    else
    {
        id data = [self parseJSONObjects: parsedObject];
        [_infoDict setObject:data forKey:kParserOutputData];
    }
    
    [super parserDidFinish:self];
}

@end
