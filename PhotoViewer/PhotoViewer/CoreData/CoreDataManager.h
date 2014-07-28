//
//  CoreDataManager.h
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Album;
@class PhotoViewerModel;

@interface CoreDataManager : NSObject
{
@private
    NSManagedObjectContext          *_managedObjectContext;
    NSPersistentStoreCoordinator    *_persistentStoreCoordinator;
    NSManagedObjectModel            *_managedObjectModel;
}

-(id) initWithDatabaseDir:(NSString*) dir;

+(NSSet*) getModelsFromEntitySet:(NSSet*) entities;
+(NSArray*) getModelsFromEntityArray:(NSArray*) entities;

-(BOOL) savePhotoViewerModel:(PhotoViewerModel*) model;

-(NSArray*) getAllAlbums;
-(NSArray*) getAllImages;

@end
