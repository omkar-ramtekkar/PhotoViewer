//
//  ParserFactory.h
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ParserBase;

@interface ParserFactory : NSObject

+(ParserBase*) createParserForService:(NSString*) serviceName withData:(NSData*) data;

@end
