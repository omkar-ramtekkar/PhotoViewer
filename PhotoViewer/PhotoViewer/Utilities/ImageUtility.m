//
//  ImageUtility.m
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import "ImageUtility.h"


@interface ImageUtility()

+(UIImage*) _scaleImage:(UIImage*)anImage toSize:(CGSize) size;
+(BOOL) isValidScaleFactor:(CGFloat) scale forImage:(UIImage*) anImage;
+(BOOL) isValidImageSize:(CGSize) size;

@end

@implementation ImageUtility


+(UIImage*) scaleImage:(UIImage*)anImage withScaleFactor:(CGFloat) scale
{
    
    BOOL bValid = [ImageUtility isValidScaleFactor:scale forImage:anImage];
    assert(bValid);
    
    UIImage* newScaledImage = nil;
    
    if (bValid)
    {
        CGSize imageSize = anImage.size;
        CGSize newImageSize = CGSizeMake(imageSize.width * scale, imageSize.height * scale);
        
        newScaledImage = [ImageUtility _scaleImage:anImage toSize:newImageSize];
    }
    
    return newScaledImage;
}


+(UIImage*) scaleImageToSize:(UIImage*)anImage size:(CGSize) size
{
    return [ImageUtility _scaleImage:anImage toSize:size];
}

+(UIImage*) scaleImageToThumbnailSize:(UIImage*)anImage
{
    CGSize thumbnailSize = CGSizeMake(200, 200);
    UIScreen* mainScreen = [UIScreen mainScreen];
    if (mainScreen.scale > 1.0f)
    {
        thumbnailSize.height *= mainScreen.scale;
        thumbnailSize.width *= mainScreen.scale;
    }
    
    return [ImageUtility _scaleImage:anImage toSize: thumbnailSize];
}

+(UIImage*) scaleImageToIconSize:(UIImage*)anImage
{
    CGSize iconSize = CGSizeMake(60, 60);
    UIScreen* mainScreen = [UIScreen mainScreen];
    if (mainScreen.scale > 1.0f)
    {
        iconSize.height *= mainScreen.scale;
        iconSize.width *= mainScreen.scale;
    }
    
   return [ImageUtility _scaleImage:anImage toSize:iconSize];
}


+(UIImage*) _scaleImage:(UIImage*)anImage toSize:(CGSize) size
{
    UIGraphicsBeginImageContext(size);
    [anImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* newScaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newScaledImage;
}


+(BOOL) isValidScaleFactor:(CGFloat) scale forImage:(UIImage*) anImage
{
    BOOL bValid = NO;
    if(scale != 0.0f)
    {
        UIScreen* mainScreen = [UIScreen mainScreen];
        CGSize deviceScreenSize = mainScreen.bounds.size;
        
        CGSize imageSize = anImage.size;
        
        CGSize newImageSize = CGSizeMake(imageSize.width * scale, imageSize.height * scale);
        
        //Verify newImageSize is greater than current device screen size
        if (newImageSize.width <= deviceScreenSize.width && newImageSize.height <= deviceScreenSize.height)
        {
            bValid = YES;
        }
    }
    
    return bValid;
}

+(BOOL) isValidImageSize:(CGSize) size
{
    BOOL bValid = NO;
    
    if (size.width > 0 && size.height > 0)
    {
        UIScreen* mainScreen = [UIScreen mainScreen];
        CGSize deviceScreenSize = mainScreen.bounds.size;
        
        //Verify newImageSize is greater than current device screen size
        if (size.width <= deviceScreenSize.width && size.height <= deviceScreenSize.height)
        {
            bValid = YES;
        }
    }
    
    return bValid;
}

@end
