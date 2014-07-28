//
//  UpdatingImageView.m
//  PhotoViewer
//
//  Created by Om on 17/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//


#import "UpdatingImageView.h"
#import "DownloadOperation.h"
#import "AppStore.h"
#import "ResourceRequest.h"
#import "Resource.h"
#import "DownloadManager.h"
#import "ImageUtility.h"

static UIImage* UIImagePlaceHolder = nil;
static NSCache* imageCache = nil;
static Resource *PlaceholderImageResource = nil;


@interface UpdatingImageView()

@property(nonatomic, strong) UIActivityIndicatorView *activity;

@end

@implementation UpdatingImageView

@dynamic url;
@synthesize useCacheIfExists = _useCacheIfExists;
@synthesize placeholderImage = _placeholder;
@synthesize activity;
@synthesize screenName;

+(void) initialize
{
    if([self isSubclassOfClass:[UpdatingImageView class]])
    {
        if(!UIImagePlaceHolder)
        {
            UIImagePlaceHolder = [UIImage imageNamed:@"ImageNotAvailable.png"];
            PlaceholderImageResource = [[Resource alloc] init];
            PlaceholderImageResource.url = [[NSBundle mainBundle] pathForResource:@"ImageNotAvailable" ofType:@"png"];
        }
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            imageCache = [[NSCache alloc] init];
            [imageCache setCountLimit:10];
        });
    }
}


-(UIImage*)getImageFromCacheForUrl:(NSString*)url
{
    @synchronized(imageCache)
    {
        return [imageCache objectForKey:url];
    }
}

-(BOOL)setResourceForImage:(Resource*)imgResource
{
    UIImage *cachedImage = [self getImageFromCacheForUrl:imgResource.url];
    BOOL bSuccess = NO;
    if (cachedImage && CGSizeEqualToSize(cachedImage.size, [self calculateImageScallingSizeForImage:cachedImage]))
    {
        self.image = [self getImageFromCacheForUrl:imgResource.url];
        bSuccess = YES;
    }
    else
    {
        UIImage *img = [[AppStore sharedAppStore] imageForResource:imgResource];
        if (img) {
            UIImage* scaledImage = [ImageUtility scaleImageToSize:img size: [self calculateImageScallingSizeForImage:img]];
            if (scaledImage) {
                @synchronized(imageCache)
                {
                    [imageCache setObject:scaledImage forKey:imgResource.url];
                }
                self.image = scaledImage;
                bSuccess = YES;
            }
        }
    }
    
    //if (bSuccess)
    {
        [self setNeedsDisplayInRect:self.frame];
    }
    
    return bSuccess;
}

-(CGSize) calculateImageScallingSizeForImage:(UIImage*) image
{
    CGFloat xScaleFactor = self.frame.size.width / image.size.width;
    CGFloat yScaleFactor = self.frame.size.height / image.size.height;
    
    CGFloat minScaleFactor = MIN(xScaleFactor, yScaleFactor);
    
    return CGSizeMake(image.size.width * minScaleFactor, image.size.height * minScaleFactor);
}



-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.useCacheIfExists = YES;
        self.screenName = @"InvalidScreen";
    }
    
    return self;
}


-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    _useCacheIfExists = YES;
    return self;
}

-(void) startActivity
{
    if (!self.activity)
    {
        self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        self.activity.hidesWhenStopped = YES;
        self.activity.color = [UIColor whiteColor];
    }
    
    self.activity.center = self.center;
    self.activity.frame = self.bounds;
    [self addSubview:self.activity];

    if (!self.activity.isAnimating)
    {
        [self.activity startAnimating];
    }

}

-(void) stopActivity
{
    [self.activity stopAnimating];
    [self.activity removeFromSuperview];
}


-(void) setUrl:(NSURL *)url
{
    _url = [url copy];
    
    if (!_url)
    {
        return;
    }
    
    BOOL bDownload = NO;
    
    self.contentMode = UIViewContentModeCenter;
    
    if (_useCacheIfExists)
    {
        Resource *resource = [Resource resourceWithURL:self.url];
        resource.type = [NSNumber numberWithInt:enumImage];
        bDownload = ![self setResourceForImage: resource];
    }

    if (bDownload)
    {
        [self startActivity];
        self.image = UIImagePlaceHolder;
        
        Resource* resource = [[Resource alloc] init];
        resource.url = [[self url] absoluteString];
        resource.type = [NSNumber numberWithInt:enumImage];
        
        ResourceRequest* request = [[ResourceRequest alloc] init];
        request.resource = resource;
        request.delegate = self;
        request.supportPauseResume = YES;
        
        assert(self.screenName);//Why screen name is nil? Please set it before setting the url.
        
        
        [[DownloadManager sharedInstance] downloadResource:request overriteIfExists:_useCacheIfExists context:(__bridge void *)([self.screenName copy])];
    }
}

-(NSURL*) url
{
    return [_url copy];
}

-(void) downloadDidFail:(DownloadOperation*) operation withErro:(NSError*) error
{
    self.image = UIImagePlaceHolder;
}

-(void) downloadDidStart:(DownloadOperation*) operation
{
    self.image = UIImagePlaceHolder;
}

-(void) downloadDidFinish:(DownloadOperation*) operation
{
    Resource *resource = operation.request.resource;

    assert(resource);
    if (resource)
    {
        [self setResourceForImage:resource];
    }
    else
    {
        self.image = UIImagePlaceHolder;
    }
    [self stopActivity];
}

-(void) downloadProgressDidUpdate:(DownloadOperation*) operation
{
    UIImage *image = [UIImage imageWithData:operation.responseData];
    if (image) {
        UIImage* scaledImage = [ImageUtility scaleImageToSize:image size: [self calculateImageScallingSizeForImage:image]];
        if (scaledImage) {
            self.image = scaledImage;
        }
    }
}

-(void) dealloc
{
    _url = nil;
    _placeholder = nil;
    self.screenName = nil;
}

@end
