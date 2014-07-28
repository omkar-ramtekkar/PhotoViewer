//
//  AlbumEntity.h
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ImageEntity;

@interface AlbumEntity : NSManagedObject

@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) ImageEntity *albumImage;

-(id) getModel;

@end

@interface AlbumEntity (CoreDataGeneratedAccessors)

- (void)addImagesObject:(ImageEntity *)value;
- (void)removeImagesObject:(ImageEntity *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
