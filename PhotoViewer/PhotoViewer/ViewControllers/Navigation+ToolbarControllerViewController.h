//
//  Navigation+ToolbarControllerViewController.h
//  PhotoViewer
//
//  Created by Om on 19/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Navigation_ToolbarControllerViewController : UINavigationController<UINavigationControllerDelegate>

@property(nonatomic, readonly) UIToolbar *primaryToolbar;
@property(nonatomic, readonly) UIToolbar *secondaryToolbar;

@end
