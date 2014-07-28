//
//  ImageUtility.h
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constant.h"

@interface ImageUtility : NSObject

/**
 * Scale current image using given scale factor
 * Note : It will retain the aspect ratio
 */
+(UIImage*) scaleImage:(UIImage*)anImage withScaleFactor:(CGFloat) scale;

/**
 * Scale current image to given size
 * Note : It will not maintain the aspect ratio
 */
+(UIImage*) scaleImageToSize:(UIImage*)anImage size:(CGSize) size;

/**
 * Scale current image to standard thumbnail size
 * iPhone,iPad - 200*200, iPhone, iPad - Retina - 400*400
 * Note : It will not maintain the aspect ratio
 */
+(UIImage*) scaleImageToThumbnailSize:(UIImage*)anImage;

/**
 * Scale current image to standard icon size
 * iPhone,iPad - 60*60, iPhone, iPad - Retina - 120*120
 * Note : It will not maintain the aspect ratio
 */
+(UIImage*) scaleImageToIconSize:(UIImage*)anImage;

#if EnableUTC
+(void) test;
#endif

@end
