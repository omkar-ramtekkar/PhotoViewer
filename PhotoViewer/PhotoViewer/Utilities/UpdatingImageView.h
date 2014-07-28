//
//  UpdatingImageView.h
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "DownloadOperationDelegate.h"

@interface UpdatingImageView : UIImageView<DownloadOperationDelegate>
{
@private
    NSURL *_url;
    UIImage *_placeholder;
}

@property(nonatomic, copy) NSURL *url;
@property(nonatomic, assign) BOOL useCacheIfExists;
@property(nonatomic, retain) UIImage *placeholderImage;
@property(nonatomic, copy) NSString *screenName;

@end
