//
//  ParserBase.h
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constant.h"
#import "ParserDelegate.h"

@interface ParserBase : NSObject<ParserDelegate>
{
@protected
    id                   _delegate;
    NSMutableDictionary *_infoDict;
    NSString            *_parserName;
    BOOL                _success;
    
}

@property(nonatomic, strong) id delegate;
@property(nonatomic, readonly) NSDictionary* infoDict;
@property(nonatomic, readonly) NSString* parserName;
@property(nonatomic, strong) NSData* data;
@property(nonatomic, assign) BOOL success;

-(id) initWithData:(NSData*) data;
-(void) parse;

@end
