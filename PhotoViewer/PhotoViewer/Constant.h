//
//  Constant.h
//  PhotoViewer
//
//  Created by Sonali Biranwar on 08/04/13.
//  Copyright (c) 2013 persistent. All rights reserved.
//



NSString* GetDownloadDirPath();
NSString* GetDeviceUDID();
NSString* GetImageUrlPostfix();


#pragma mark --------------- Utitility Constants ---------------
#define kOfflineStorageLimit                100 //100 MB
#define kOfflineStorageDefaultSize          50  //50 MB
#define kDownloadUpdateNotificationDelta    25  //Send update notification after each 25% download


#pragma mark ------------- Notifications ---------

#define kNotificationResourceDownloaded     @"kNotificationResourceDownloaded"
#define kNotificationModelIntialized        @"kNotificationModelIntialized"


#pragma mark --------------- Service Constants ---------------
#define kMaxRetryAttemp         1
#define kServerBaseURLKey       @"GenwiWebServiceURLKey"
#define kServiceNameGetAlbums   @"kServiceNameGetAlbums"
#define kServiceNameGetImages   @"kServiceNameGetImages"


#pragma mark --------------- Parser Constants ---------------
#define kParserOutputData       @"data"
#define kParserName             @"parsername"
#define kServiceOutputData      kParserOutputData
#define kServiceName            kParserName
