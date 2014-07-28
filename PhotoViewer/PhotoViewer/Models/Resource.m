//
//  ResourceEntity.m
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import "Resource.h"


@implementation Resource

@synthesize type;
@synthesize url;
@synthesize version;

+(id) resourceWithURL:(NSURL*) url
{
    Resource *resource = [[Resource alloc] init];
    resource.url = [url absoluteString];
    
    return resource;
}

-(BOOL) isEqual:(id)object
{
    if (![object isKindOfClass:[Resource class]])
    {
        return NO;
    }
    
    if (self == object)
    {
        return YES;
    }
    
    if ([self.url isKindOfClass:[NSURL class]] || [[object url]  isKindOfClass:[NSURL class]])
    {
        assert(false);
    }
    
    BOOL bEqual = [[self url] isEqual:[(Resource*)object url]];

    return bEqual;
}

- (id)copyWithZone:(NSZone *)zone
{
    Resource* copy = [[Resource alloc] init];
    if (copy)
    {
        copy.type = self.type;
        copy.url = self.url;
        copy.version = self.version;
    }
    
    return copy;
}

-(NSString*) description
{
    return [NSString stringWithFormat:@"Resource {url : %@ \n}",self.url];
}

@end
