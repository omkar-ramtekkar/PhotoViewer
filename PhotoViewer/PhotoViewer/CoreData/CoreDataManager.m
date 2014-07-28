//
//  CoreDataManager.m
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//


#import "CoreDataManager.h"
#import "Image.h"
#import "Album.h"
#import "ImageEntity.h"
#import "AlbumEntity.h"
#import "PhotoViewerModel.h"


@interface CoreDataManager()


@property (nonatomic, strong) NSString *databaseDir;

-(void) _initialize;

-(NSArray*) _getListOfEntities:(NSString*) entityName
          withSortDesciptorKey:(NSString*) key
                    andContext:(NSManagedObjectContext*)context;

-(NSArray*) _getListOfImageEntities;
-(NSArray*) _getListOfImages;
-(NSArray*) _getListofAlbumEntities;
-(NSArray*) _getListofAlbums;

-(ImageEntity*) _getImageEntityForImage:(Image*) anImage andContext:(NSManagedObjectContext*)context;
-(NSArray*) _insertImages:(NSArray*) images andContext:(NSManagedObjectContext *) context;
-(ImageEntity*) _insertImage:(Image*) anImage andContext:(NSManagedObjectContext *) context;

@end


@implementation CoreDataManager

@synthesize databaseDir;

-(id) initWithDatabaseDir:(NSString*) dir
{
    self = [super init];
    if (self)
    {
        self.databaseDir = dir;
        [self _initialize];
    }
    
    return self;
}

-(void) _initialize
{
    BOOL bCreated = [[NSFileManager defaultManager] createDirectoryAtPath:self.databaseDir withIntermediateDirectories:YES attributes:nil error:nil];
    
    assert(bCreated);
    if (!bCreated)
    {
        bCreated = [[NSFileManager defaultManager] createDirectoryAtPath:self.databaseDir withIntermediateDirectories:YES attributes:nil error:nil];
        
        if (!bCreated)
        {
            assert(false);
            return;
        }
    }
    
    NSString* storePath = [self.databaseDir stringByAppendingPathComponent:@"photoviewer.sqlite"];
    
    NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    if(!_managedObjectModel)
    {
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    }
    assert(_managedObjectModel);
    
    if(!_persistentStoreCoordinator)
    {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: _managedObjectModel];
    }
    
    assert(_persistentStoreCoordinator);
    
    NSError *error = nil;
    
     NSPersistentStore *store = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:storeURL
                                                        options:nil
                                                      error:&error];
    
    if (!store)
    {
        NSLog(@"Can't _initialize Persistent Store : %@",error);
        //Try to migrate the core data
        error = nil;
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        
        store = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                          configuration:nil
                                                                    URL:storeURL
                                                                options:options
                                                                  error:&error];
        
        
        //If still not able to add data store then delete existing sqlite file and again try to create the store
        if( !store && [[NSFileManager defaultManager] removeItemAtPath:storePath error:nil])
        {
            error = nil;
            store = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                              configuration:nil
                                                                        URL:storeURL
                                                                    options:options
                                                                      error:&error];
        }
        
    }
    
    assert(store);
    
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
    [_managedObjectContext setUndoManager:nil];
    assert(_managedObjectContext);
}

#pragma mark -------------- Utilities -------------------

+(NSSet*) getModelsFromEntitySet:(NSSet*) entities
{
    return [NSSet setWithArray:[CoreDataManager getModelsFromEntityArray:[entities allObjects]]];
}


+(NSArray*) getModelsFromEntityArray:(NSArray*) entities
{
    if (!entities || [entities count] == 0)
    {
        return nil;
    }
    
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:[entities count]];
    for (id entity in entities)
    {
        if ([entity isKindOfClass:[NSManagedObject class]])
        {
            if ([entity respondsToSelector:@selector(getModel)])
            {
                [[entity managedObjectContext] lock];
                id model = [entity getModel];
                [[entity managedObjectContext] unlock];
                assert(model); //Why model is nil? Please check!
                if (model)
                {
                    [models addObject:model] ;
                }
            }
            else
            {
                assert(false);//Entity should have getModel() method
            }
        }
        else
        {
            assert(false);//Which entity is this? Please check!
        }
    }
    
    return models;
}

-(NSArray*) _getListOfEntities:(NSString*) entityName withSortDesciptorKey:(NSString*) key andContext:(NSManagedObjectContext*)context
{
    if (entityName == nil)
    {
        NSLog(@"Invalid Entity Name");
        return nil;
    }
    
    [context lock];
    [context.persistentStoreCoordinator lock];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    
    
    assert(entity);//Check why we are not able to create an entity
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setResultType:NSManagedObjectResultType];
    [request setEntity:entity];
    
    if (key)
    {
        NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:key ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDesc];
        [request setSortDescriptors:sortDescriptors];
    }
    
    
    NSError *error = nil;
    NSArray *entities = [context executeFetchRequest:request error:&error];
    
    if( error)
    {
        NSLog(@"Failed to fetch list of %@ : %@",entityName, error);
        entities = nil;
    }
    
    [context.persistentStoreCoordinator unlock];
    [context unlock];

    return entities;
}



#pragma mark ---- Private APIs ----

-(NSArray*) _getListofAlbumEntities
{
    return [self _getListOfEntities:@"AlbumEntity" withSortDesciptorKey:@"caption" andContext:_managedObjectContext];
}

-(NSArray*) _getListofAlbums
{
    return [CoreDataManager getModelsFromEntityArray:[self _getListofAlbumEntities]];
}

-(NSArray*) _getListOfImageEntities
{
    return [self _getListOfEntities:@"ImageEntity" withSortDesciptorKey:@"caption" andContext:_managedObjectContext];
}

-(NSArray*) _getListOfImages
{
    return [CoreDataManager getModelsFromEntityArray:[self _getListOfImageEntities]];
}


-(ImageEntity*) _getImageEntityForImage:(Image*) anImage andContext:(NSManagedObjectContext*)context
{
    [context lock];
    [context.persistentStoreCoordinator lock];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ImageEntity" inManagedObjectContext:context];
    
    
    assert(entity);//Check why we are not able to create an entity
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setResultType:NSManagedObjectResultType];
    [request setEntity:entity];
    [request  setFetchLimit:1];
    NSPredicate *condition = [NSPredicate predicateWithFormat:@"url == %@", anImage.url];
    [request setPredicate:condition];
    
    
    NSError *error = nil;
    NSArray *entities = [context executeFetchRequest:request error:&error];
    
    assert(entities.count <= 1);
    
    if( error)
    {
        NSLog(@"Failed to fetch list of ImageEntity : %@", error);
        entities = nil;
    }
    
    [context.persistentStoreCoordinator unlock];
    [context unlock];
    
    return [entities lastObject];
}


-(NSArray*) _insertImages:(NSArray*) images andContext:(NSManagedObjectContext *) context
{
    @try
    {
        NSMutableArray *imageEntities = [NSMutableArray arrayWithCapacity:images.count];
        
        for (Image *anImage in images)
        {
            [imageEntities addObject: [self _insertImage:anImage andContext:context]];
        }
        
        return imageEntities;
    }
    @catch (NSException *exception)
    {
        @throw exception;
    }
    
    return nil;
}


-(ImageEntity*) _insertImage:(Image*) anImage andContext:(NSManagedObjectContext*)context
{
    [context lock];
    [context.persistentStoreCoordinator lock];
    
    ImageEntity *anImageEntity = [self _getImageEntityForImage:anImage andContext:context];
    
    if (!anImageEntity)
    {
        anImageEntity = [NSEntityDescription insertNewObjectForEntityForName:@"ImageEntity" inManagedObjectContext:context];
    }
    
    anImageEntity.caption = anImage.caption;
    anImageEntity.url = [anImage.url absoluteString];
    anImageEntity.height = anImage.height;
    anImageEntity.width = anImage.width;
    anImageEntity.desc = anImage.desc;
    
    [context.persistentStoreCoordinator unlock];
    [context unlock];
    
    return anImageEntity;
}


-(AlbumEntity*) _addAlbum:(Album*) anAlbum andContext:(NSManagedObjectContext*)context
{
    [context lock];
    [context.persistentStoreCoordinator lock];
    
    AlbumEntity *anAlbumEntity = [NSEntityDescription insertNewObjectForEntityForName:@"AlbumEntity" inManagedObjectContext:context];
    
    @try
    {
        anAlbumEntity.albumImage = [self _insertImage:anAlbum.albumImage andContext:context];
        anAlbumEntity.caption = anAlbum.caption;
        [anAlbumEntity addImages:[NSSet setWithArray:[self _insertImages:anAlbum.images andContext:context]]];
        
        anAlbumEntity.id = anAlbum.id;
        anAlbumEntity.desc = anAlbum.desc;
        
        [self _saveContext:context];
    }
    @catch (NSException *exception)
    {
        @throw exception;
    }
    @finally
    {
        [context.persistentStoreCoordinator unlock];
        [context unlock];
    }
    
    return anAlbumEntity;
}

-(BOOL) _deleteAllAlbums
{
    BOOL bDeleteSuccess = YES;
    
    [_managedObjectContext lock];
    [_managedObjectContext.persistentStoreCoordinator lock];
    
    NSFetchRequest * allAlbumsRequest = [[NSFetchRequest alloc] init];
    [allAlbumsRequest setEntity:[NSEntityDescription entityForName:@"AlbumEntity" inManagedObjectContext:_managedObjectContext]];
    [allAlbumsRequest setIncludesPropertyValues:NO];
    
    NSError * error = nil;
    NSArray * albums = [_managedObjectContext executeFetchRequest:allAlbumsRequest error:&error];
    
    //error handling goes here
    for (NSManagedObject * album in albums)
    {
        [_managedObjectContext deleteObject:album];
    }
    
    NSError *saveError = nil;
    [_managedObjectContext save:&saveError];
    
    if (saveError)
    {
        [_managedObjectContext rollback];
        bDeleteSuccess = NO;
    }
    
    [_managedObjectContext unlock];
    [_managedObjectContext.persistentStoreCoordinator unlock];
    
    return bDeleteSuccess;
}


-(BOOL) _saveContext:(NSManagedObjectContext*) context
{
    BOOL bSuccess = YES;
    if ([context hasChanges])
    {
        NSError *error = nil;
        [context save:&error];
        
        if (error)
        {
            NSLog(@"CoreDataManager : Unable to save context, error : %@",error);
            //Discard all the changes
            [context rollback];
            
            @throw [NSException exceptionWithName:@"SaveContextError" reason:@"Unable to save context changes" userInfo:nil];
        }
    }
    
    return bSuccess;
}



#pragma mark ------ Public APIs --------------

-(BOOL) addAlbum:(Album*) anAlbum
{
    @try
    {
        [self _addAlbum:anAlbum andContext:_managedObjectContext];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Unable to insert an Album");
        NSLog(@"Details : %@", exception);
        return NO;
    }
    
    return YES;
}



-(NSArray*) getAllAlbums
{
    return [self _getListofAlbums];
}

-(NSArray*) getAllImages
{
    return [self _getListOfImages];
}

-(BOOL) savePhotoViewerModel:(PhotoViewerModel*) model
{
    [self _deleteAllAlbums];
    
    for (Album *album in model.albums)
    {
        [self addAlbum:album];
    }
    
    return YES;
}


@end
