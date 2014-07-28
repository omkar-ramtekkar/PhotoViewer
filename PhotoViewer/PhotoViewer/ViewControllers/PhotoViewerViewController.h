//
//  PhotoViewerViewController.h
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PhotoViewerStyle) {
    PhotoViewerAlbumStyle = 0,
    PhotoViewerImageStyle
};

@class Album;

@interface PhotoViewerViewController : UIViewController

@property (nonatomic, strong) NSArray *albums;
@property (nonatomic, assign) CGSize cellSize;
@property (nonatomic, assign) PhotoViewerStyle style;
@property (nonatomic, strong) IBOutlet UICollectionView * collectionView;

@end
