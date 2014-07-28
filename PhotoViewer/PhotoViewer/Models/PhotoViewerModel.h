//
//  PhotoViewerModel.h
//  PhotoViewer
//
//  Created by Om on 18/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

@interface PhotoViewerModel : NSObject

@property(nonatomic, readonly) NSArray *albums;

-(id) initWithAlbums:(NSArray*) albums;

@end
