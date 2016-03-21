//
//  YZZViewController.m
//  testpdfreader
//
//  Created by Kai Zou on 2013-01-18.
//  Copyright (c) 2013 APL. All rights reserved.
//

#import "YZZViewController.h"

@interface YZZViewController ()

@end

@implementation YZZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)loadView {
    [super loadView];
    // Creates an instance of a UIWebView
    UIWebView *aWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 00, 320,450)];
    // Sets the scale of web content the first time it is displayed in a web view
    aWebView.scalesPageToFit = YES;
    [aWebView setDelegate:self];

    //Create a URL object.
    NSURL *urlString = [NSURL URLWithString:@"http://oreilly.com/catalog/objectcpr/chapter/ch01.pdf"];

    //URL Requst Object

    NSURLRequest *requestObj = [NSURLRequest requestWithURL:urlString];

    //load the URL into the web view.

    [aWebView loadRequest:requestObj];

    [self.view addSubview:aWebView];

//    [aWebView release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
