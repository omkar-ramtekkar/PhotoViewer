//
//  ImageEntity.h
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ImageEntity : NSManagedObject

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSString * desc;

-(id) getModel;

@end
