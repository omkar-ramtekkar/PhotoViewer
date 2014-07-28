//
//  Navigation+ToolbarControllerViewController.m
//  PhotoViewer
//
//  Created by Om on 19/01/14.
//  Copyright (c) 2014 Genwi. All rights reserved.
//

#import "Navigation+ToolbarControllerViewController.h"
#define TOOLBAR_HEIGHT  44

@interface Navigation_ToolbarControllerViewController ()

@property(nonatomic, assign) UIView *layoutView;
@property(nonatomic, assign) UIToolbar *primaryToolbar;
@property(nonatomic, strong) UIToolbar *secondaryToolbar;

@end

@implementation Navigation_ToolbarControllerViewController

@synthesize layoutView;
@synthesize primaryToolbar;
@synthesize secondaryToolbar;

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
    self.delegate = self;
    
    self.layoutView = self.toolbar.superview;
    
    [super viewDidLoad];
    
    [self setupToolbars];
    
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    //Setup Primary toolbar
    {
        self.primaryToolbar = self.toolbar;
        UIBarButtonItem *toggleButton = [[UIBarButtonItem alloc] initWithTitle:@"Toggle" style:0 target:self action:@selector(toggleToolbar:)];
        
        [self.toolbar setTintColor:[UIColor redColor]];
        [self.toolbar setBackgroundColor:[UIColor redColor]];
        [self.toolbar setItems:@[toggleButton] animated:YES];
    }
    
    [super viewDidAppear:animated];
}

-(void) setupToolbars
{
    [self setToolbarHidden:NO animated:YES];
    
    //Note - Do not set primary toolbar here, it will not have any effect
    //Setup Secondary toolbar
    {
        self.secondaryToolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        
        self.secondaryToolbar.backgroundColor = [UIColor greenColor];
            
        self.secondaryToolbar.barStyle = UIBarStyleDefault;
            
            UIBarButtonItem *toggleButton = [[UIBarButtonItem alloc] initWithTitle:@"Toggle" style:0 target:self action:@selector(toggleToolbar:)];
            
        self.secondaryToolbar.tintColor = [UIColor greenColor];
        self.secondaryToolbar.backgroundColor = [UIColor greenColor];
        [self.secondaryToolbar setItems:[NSArray arrayWithObject:toggleButton] animated:YES];
        
        self.secondaryToolbar.frame = CGRectMake(0, CGRectGetMaxY(self.navigationBar.frame), self.view.bounds.size.width, TOOLBAR_HEIGHT);
                    
        [self.layoutView addSubview: self.secondaryToolbar];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UIView *containerView = viewController.view.superview;
    containerView.frame =
    CGRectMake(CGRectGetMinX(containerView.frame),
               CGRectGetMaxY(self.secondaryToolbar.frame),
               CGRectGetWidth(containerView.frame),
               CGRectGetMinY(self.primaryToolbar.frame) - CGRectGetMaxY(self.secondaryToolbar.frame));
    
    viewController.view.frame = CGRectMake(CGRectGetMinX(viewController.view.frame), 0, CGRectGetWidth(viewController.view.frame), CGRectGetHeight(containerView.frame));
    [containerView layoutIfNeeded];
}

-(void) toggleToolbar:(id) sender
{
    CGRect tempRect = self.primaryToolbar.frame;
    self.primaryToolbar.frame = self.secondaryToolbar.frame;
    self.secondaryToolbar.frame = tempRect;
}


@end
