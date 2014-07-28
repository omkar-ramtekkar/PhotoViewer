//
//  ParserBase.m
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import "ParserBase.h"
#import "ParserDelegate.h"
#import "Constant.h"


@implementation ParserBase

@synthesize delegate = _delegate;
@synthesize infoDict = _infoDict;
@synthesize parserName = _parserName;

-(id) initWithData:(NSData*) data
{
    self = [super init];
    if (self)
    {
        _delegate = nil;
        _parserName = nil;
        _infoDict = [[NSMutableDictionary alloc] init];
        _data = [data copy];
        _success = NO;
    }
    
    return self;
}

-(void) parse
{
    @throw @"Not Implemented";
}


-(void) parserDidStart:(ParserBase*) parser
{
    _success = NO;
    if([self.delegate respondsToSelector:@selector(parserDidStart:)])
    {
        [self.delegate parserDidStart:self];
    }
}

-(void) parserDidFinish:(ParserBase*) parser
{
    _success = YES;
    if([self.delegate respondsToSelector:@selector(parserDidFinish:)])
    {
        [self.delegate parserDidFinish:self];
    }
}

-(void) parserDidFailWithError:(ParserBase*) parser error:(NSError*) error
{
    _success = NO;
    if([self.delegate respondsToSelector:@selector(parserDidFailWithError:error:)])
    {
        [self.delegate parserDidFailWithError:self error:error];
    }
}

@end
