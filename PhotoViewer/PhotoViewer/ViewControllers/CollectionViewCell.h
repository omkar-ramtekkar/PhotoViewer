//
//  CollectionViewCell.h
//  PhotoViewer
//
//  Created by Om on 19/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UpdatingImageView;

@interface CollectionViewCell : UICollectionViewCell

@property(nonatomic, strong) IBOutlet UpdatingImageView *imageView;

@end
