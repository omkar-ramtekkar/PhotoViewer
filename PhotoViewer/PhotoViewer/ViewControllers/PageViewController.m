//
//  PageViewController.m
//  PhotoViewer
//
//  Created by Om on 18/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import "PageViewController.h"
#import "ImageDetailViewController.h"
#import "AppStore.h"
#import "Album.h"
#import "Image.h"

@interface PageViewController ()

@property(nonatomic, strong) NSMutableArray* imageViewControllers;

@end

@implementation PageViewController

@synthesize currentIndex;
@synthesize imageViewControllers;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.dataSource = self;
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationController setToolbarHidden:NO animated:YES];
    self.title = NSLocalizedString(@"Photo", nil);
    Album *album = [[[AppStore sharedAppStore] allAlbums] lastObject];
    
    self.imageViewControllers = [NSMutableArray arrayWithCapacity:album.images.count];
    
    for (Image *image in album.images)
    {
        ImageDetailViewController *detailViewController = [[ImageDetailViewController alloc] initWithNibName:@"ImageDetailViewController" bundle:nil];
        detailViewController.view.frame = self.view.frame;
        detailViewController.image = [image copy];
        
        [self.imageViewControllers addObject:detailViewController];
    }
    
    [self setViewControllers:[NSArray arrayWithObject:[self.imageViewControllers objectAtIndex:self.currentIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.imageViewControllers indexOfObject:viewController];
    if (index == NSNotFound)
    {
        return nil;
    }
    else
    {
        @try {
            return [self.imageViewControllers objectAtIndex:index-1];
        }
        @catch (NSException *exception)
        {
            return nil;
        }
        
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.imageViewControllers indexOfObject:viewController];
    if (index == NSNotFound)
    {
        return nil;
    }
    else
    {
        @try {
            return [self.imageViewControllers objectAtIndex:index+1];
        }
        @catch (NSException *exception)
        {
            return nil;
        }
        
    }
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.imageViewControllers count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return self.currentIndex;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
