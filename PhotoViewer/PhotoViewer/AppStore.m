//
//  AppStore.m
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import "Constant.h"
#import "AppStore.h"
#import "Resource.h"
#import "Album.h"
#import "Image.h"
#import "OfflineStorageModel.h"
#import "CoreDataManager.h"
#import "PhotoViewerModel.h"
#import "ParserFactory.h"
#import "ParserBase.h"

static AppStore *appStore_g = nil;

NSString* GetDocumentDirPath()
{
    static NSString *docDirPath_g = nil;
    if (docDirPath_g)
    {
        return docDirPath_g;
    }
    else
    {
        //Offline Dir Path
        docDirPath_g = [[(NSURL*)[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path] copy];
    }
    return docDirPath_g;
}

NSString* GetDatabaseDirPath()
{
    static NSString *databaseDirPath_g = nil;
    if (databaseDirPath_g)
    {
        return databaseDirPath_g;
    }
    else
    {
        //database Dir Path
        NSString *libraryDirPath = [(NSURL*)[[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject] path];
        databaseDirPath_g  = [[libraryDirPath stringByAppendingPathComponent:@"Database"] copy];
    }
    return databaseDirPath_g;
}



@interface AppStore()

@property (nonatomic, strong) OfflineStorageModel *offlineStorage;
@property (nonatomic, strong) CoreDataManager *coreDataManager;
@property (nonatomic, strong) PhotoViewerModel *model;

-(void) initialize;

@end

@implementation AppStore

+(AppStore*) sharedAppStore
{
    if (appStore_g)
    {
        return appStore_g;
    }
    else
    {
        static dispatch_once_t pred;
        dispatch_once(&pred,^{
            appStore_g = [[AppStore alloc] init];
            assert(appStore_g);
            [appStore_g initialize];
        });
        
        return appStore_g;
    }
}

+(void) releaseAppStore
{
    appStore_g = nil;
}

+(void) postNotificationWithName:(NSString*) notificationName
{
    NSNotification *notification = [NSNotification notificationWithName:notificationName object:nil];
    [AppStore postNotification:notification];
}

+(void) postNotification:(NSNotification*) notification
{
    NSLog(@"Notification Post : %@", notification.name);
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
}


-(NSArray*) allAlbums
{
    return self.model.albums;
}

-(NSArray*) allImages
{
    NSMutableArray *allImages = [NSMutableArray array];

    for (Album *album in self.allAlbums)
    {
        [allImages addObjectsFromArray:album.images];
    }
    
    return allImages;
}

-(void) initialize
{
    if ([[NSThread currentThread] isMainThread])
    {
        [self performSelectorInBackground:@selector(initialize) withObject:nil];
        return;
    }
    
    self.offlineStorage = [[OfflineStorageModel alloc] initWithOfflineDirectory:GetDocumentDirPath() andOfflineCapacity:kOfflineStorageDefaultSize];
    
    self.coreDataManager = [[CoreDataManager alloc] initWithDatabaseDir:GetDatabaseDirPath()];
    
    [self initializeModel];
}

-(void) initializeModel
{
    NSArray *albums = [self.coreDataManager getAllAlbums];
    
    if ([albums count])
    {
        self.model = [[PhotoViewerModel alloc] initWithAlbums:albums];
    }
    else
    {
        NSURL *url = [[NSURL alloc] initWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:kServerBaseURLKey]];
        
        NSData *jsonData = [NSData dataWithContentsOfURL:url];
        
        ParserBase *parser = [ParserFactory createParserForService:kServiceNameGetAlbums withData:jsonData];
        [parser parse];
        
        NSArray *albums = [parser.infoDict objectForKey:kParserOutputData];
        
        self.model = [[PhotoViewerModel alloc] initWithAlbums:albums];
        
        [self.coreDataManager savePhotoViewerModel:self.model];
    }
    
    [AppStore postNotificationWithName:kNotificationModelIntialized];
}

-(UIImage*) imageForResource:(Resource*) resource
{
    return [self.offlineStorage getDataAssociatedWithResource:resource];
}

-(UIImage*) imageForURL:(NSURL*) url
{
    Resource *resource = [Resource resourceWithURL:url];
    resource.type = [NSNumber numberWithInt:enumImage];
    return [self imageForResource: resource];
}

-(BOOL) isResourceAvailable:(Resource*) resource
{
    return [self.offlineStorage isResourceAvailable:resource];
}

@end
