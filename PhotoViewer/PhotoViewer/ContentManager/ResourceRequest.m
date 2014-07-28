//
//  ResourceRequest.m
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import "ResourceRequest.h"
#import "Resource.h"

@implementation ResourceRequest

@synthesize resource = _resource;
@synthesize delegate = _delegate;
@synthesize supportPauseResume = _supportPauseResume;


-(BOOL) isEqual:(id)object
{
    if (![object isKindOfClass:[ResourceRequest class]])
    {
        return NO;
    }
    
    if (self == object)
    {
        return YES;
    }
    
    return [self.resource isEqual:[object resource]];
}

- (id)copyWithZone:(NSZone *)zone
{
    ResourceRequest* copy = [[ResourceRequest alloc] init];
    if (copy)
    {
        copy.resource = [self.resource copy];
        copy.delegate = self.delegate;
        copy.supportPauseResume = self.supportPauseResume;
    }
    
    return copy;
}


-(NSString*) description
{
    return [NSString stringWithFormat:@"ResourceRequest \n%@",[self.resource description]];
}

@end
