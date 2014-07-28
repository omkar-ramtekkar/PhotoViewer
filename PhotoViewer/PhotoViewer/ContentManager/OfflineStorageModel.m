//
//  OfflineStorageModel.m
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import "OfflineStorageModel.h"
#import "Resource.h"
#import "DownloadOperation.h"
#import "ResourceRequest.h"
#import "CoreDataManager.h"

static NSUInteger OFFLINE_STORAGE_CAPACITY = 10485760; //default 10 MB


@interface OfflineStorageModel()


@property(nonatomic, strong) NSString *dirPath;
@property(nonatomic, strong) NSCache *imageCache;

-(void) initialize;
-(id) getDataForResource:(Resource*) resorce;
-(void) resourceDownloaded:(NSNotification*) notitification;
-(void) handleLowMemoryWarining:(NSNotification*) note;
-(id) createDataForResource:(Resource*) resource;
-(void) registerNotifications;
-(void) unregisterNotifications;

@end


@implementation OfflineStorageModel

-(id) initWithOfflineDirectory:(NSString*)offlineDirPath andOfflineCapacity:(NSUInteger) megabytes
{
    self = [super init];
    
    if (self)
    {
        self.dirPath = offlineDirPath;
        [self initialize];
    }
    
    return self;
}

-(void) initialize
{
    assert(!_imageCache);
    
    //Allocate
    _imageCache = [[NSCache alloc] init];
    
    //Configure
    [_imageCache setCountLimit:20];
    [_imageCache setTotalCostLimit:OFFLINE_STORAGE_CAPACITY];
    
    
    //Offline Dir Path
    NSString *docDirPath = self.dirPath;
    
    self.dirPath = [[docDirPath stringByAppendingPathComponent:@"Resources"] copy];
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:self.dirPath withIntermediateDirectories:YES attributes:nil error:&error];
    
    [self registerNotifications];

}



-(void) registerNotifications
{
    [self unregisterNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resourceDownloaded:) name:kNotificationResourceDownloaded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLowMemoryWarining:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

-(void) unregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setOfflineStorageCapacity:(NSUInteger) megabytes
{
    assert(megabytes > kOfflineStorageLimit); //should not be greater than kOfflineStorageLimit
    if (megabytes > kOfflineStorageLimit)
    {
        OFFLINE_STORAGE_CAPACITY = kOfflineStorageDefaultSize * 1024 * 1024;
    }
    else
    {
        OFFLINE_STORAGE_CAPACITY = megabytes * 1024 * 1024;
    }
}

- (NSUInteger) getOfflineStorageCapacity
{
    return OFFLINE_STORAGE_CAPACITY;
}


-(NSString*) getPhysicalPathForResource:(Resource*) resource
{
    NSString *filename = [resource.url lastPathComponent];
    assert(filename);
    
    NSString *filePath = [self.dirPath stringByAppendingPathComponent:filename];

    return filePath;
}

-(BOOL) isResourceAvailable:(Resource*) resource
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self getPhysicalPathForResource:resource]];
}

-(id) getDataForResource:(Resource*) resource
{
    if([self isResourceAvailable:resource])
    {
        id resourceData = nil;
        switch ([resource.type integerValue])
        {
            case enumImage:
                resourceData = [_imageCache objectForKey:resource.url];
                break;
            default:
                assert(false);
        }
        
        if (!resourceData)
        {
            resourceData = [self createDataForResource:resource];
        }
        
        return resourceData;
    }
    
    return nil;
}

-(BOOL) deleteResource:(Resource*) resource
{
    BOOL bAvailable = [self isResourceAvailable:resource];
    BOOL bSuccess = YES;
    if (bAvailable)
    {
        NSError *error = nil;
        BOOL bDeleteSuccess = [[NSFileManager defaultManager] removeItemAtPath:[self getPhysicalPathForResource:resource] error:&error];
        if (!bDeleteSuccess)
        {
            NSLog(@"OfflineStorageModel : Unable to delete the resource file - error : %@", error);
            bSuccess = NO;
        }
    }
    
    switch ([resource.type integerValue])
    {
        case enumImage:
            @synchronized(_imageCache)
        {
            [_imageCache removeObjectForKey:resource.url];
        }
            break;
        default:
            assert(false);//Handle Case
    }
    
    return bSuccess;
}


-(BOOL) saveData:(NSData*) data forResource:(Resource*) resource
{
    assert(data && resource);
    
    NSString *physicalPath = [self getPhysicalPathForResource:resource];
    [[NSFileManager defaultManager] removeItemAtPath:physicalPath error:nil];
    
    return [data writeToFile:physicalPath atomically:YES];
}

-(id) createDataForResource:(Resource*) resource
{
    switch ([resource.type integerValue])
    {
        case enumImage:
        {
            UIImage *img = [[UIImage alloc] initWithContentsOfFile:[self getPhysicalPathForResource:resource]];
            assert(img);
            if (img)
            {
                [_imageCache setObject:img forKey:resource.url];
            }
            return img;
        }
        
        default:
            assert(false);//Why control is coming here?
                          //Check Resource type value
            return nil;
    }
}

-(void) resourceDownloaded:(NSNotification*) notitification
{
    DownloadOperation *operation = [notitification object];
    if (operation && operation.responseData && operation.request)
    {
        [self saveData:operation.responseData forResource:operation.request.resource];
    }
}

-(void) handleLowMemoryWarining:(NSNotification*) note
{
    [_imageCache removeAllObjects];
}

-(id) getDataAssociatedWithResource:(Resource*) resource
{
    return [self getDataForResource:resource];
}


-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
