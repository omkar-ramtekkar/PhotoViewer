//
//  PhotoViewerViewController.m
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import "PhotoViewerViewController.h"
#import "AppStore.h"
#import "Album.h"
#import "Image.h"
#import "UpdatingImageView.h"
#import "PageViewController.h"
#import "CollectionViewCell.h"
#import "DownloadManager.h"

#define MAX_CELL_WIDTH      150
#define MAX_CELL_HEIGHT     202
#define MIN_COLOUM_NUMBER   3
#define CELL_INSET          5
#define CELL_BORDER         2

@interface PhotoViewerViewController ()

@property(nonatomic, strong) Album *album;

@end

@implementation PhotoViewerViewController

@synthesize album;
@synthesize collectionView;
@synthesize cellSize;
@synthesize style;
@synthesize albums;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.style = PhotoViewerAlbumStyle;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupCollectionView];

    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CollectionViewCell"];
    
    [self registerNotifications];
    
    if (self.style == PhotoViewerAlbumStyle)
    {
        self.albums = [[AppStore sharedAppStore] allAlbums];
    }
    else
    {
        self.album = [[[[AppStore sharedAppStore] allAlbums] lastObject] copy];
    }
    
    [self checkAndAlertForInternetConnectivity];
    
}


-(void) checkAndAlertForInternetConnectivity
{
    if (!self.album.images.count && ![[DownloadManager sharedInstance] isInternetConnectionAvailable])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Internet connection not available", nil) message: NSLocalizedString(@"Please check internet connection", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        [alert show];
    }
}

-(void) setupCollectionView
{
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    [self.collectionView setAllowsMultipleSelection:NO];
    
    
    CGRect screenFrame = self.collectionView.frame;
    
    /**
     * Usable screen width is the remaining screen width after removing following
     * Each Cell Inset Spacing
     * Section Spacing
     */
    
    CGFloat usableScreenWidth = screenFrame.size.width - /*Cell Spacing*/(CELL_INSET * (MIN_COLOUM_NUMBER - 1) * 2) - (CELL_INSET * 2)/*Section Spacing*/;
    
    CGFloat columnSize = usableScreenWidth / MIN_COLOUM_NUMBER;
    
    if (columnSize > MAX_CELL_WIDTH)
    {
        columnSize = MAX_CELL_WIDTH;
    }
    
    CGFloat aspectRatio = (columnSize / MAX_CELL_WIDTH);
    
    self.cellSize = CGSizeMake(columnSize, MAX_CELL_HEIGHT * aspectRatio);
}

-(void) registerNotifications
{
    [self unregisterNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCollectionView:) name:kNotificationModelIntialized object:nil];
}

-(void) unregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) refreshCollectionView:(NSNotification*) note
{
    if (self.style == PhotoViewerAlbumStyle)
    {
        self.albums = [[AppStore sharedAppStore] allAlbums];
    }
    else
    {
        self.album = [[[[AppStore sharedAppStore] allAlbums] lastObject] copy];
    }
    
    [self.collectionView reloadData];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(CELL_INSET, CELL_INSET, CELL_INSET, CELL_INSET);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return CELL_INSET;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return CELL_INSET;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.style == PhotoViewerAlbumStyle ? self.albums.count : self.album.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
        
    Image *photo = nil;
    
    if (self.style == PhotoViewerAlbumStyle)
    {
        photo = [[self.albums objectAtIndex:indexPath.row] albumImage];
    }
    else
    {
        photo = [self.album.images objectAtIndex:indexPath.row];
    }

    cell.imageView.frame = cell.bounds;
    
    cell.imageView.screenName = NSStringFromClass(self.class);
    cell.imageView.url = photo.url;
    
    cell.layer.borderWidth = CELL_BORDER;
    cell.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    return cell;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.style == PhotoViewerAlbumStyle)
    {
        PhotoViewerViewController *imageStyleViewController = [[PhotoViewerViewController alloc] initWithNibName:@"PhotoViewerViewController" bundle:nil];
        
        imageStyleViewController.style = PhotoViewerImageStyle;
        imageStyleViewController.title = NSLocalizedString(@"Photos", nil);
        
        [self.navigationController pushViewController:imageStyleViewController animated:YES];
    }
    else
    {
        PageViewController *pageviewController = [[PageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        
        pageviewController.currentIndex = indexPath.row;
        
        
        [self.navigationController pushViewController:pageviewController animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
