//
//  ImageDetailViewController.h
//  PhotoViewer
//
//  Created by Om on 18/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Image;
@class UpdatingImageView;

@interface ImageDetailViewController : UIViewController

@property(nonatomic, strong) Image *image;
@property(nonatomic, strong) IBOutlet UpdatingImageView *imageView;

@end
