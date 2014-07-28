//
//  ParserDelegate.h
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ParserBase;

@protocol ParserDelegate <NSObject>

-(void) parserDidStart:(ParserBase*) parser;
-(void) parserDidFinish:(ParserBase*) parser;
-(void) parserDidFailWithError:(ParserBase*) parser error:(NSError*) error;

@end
