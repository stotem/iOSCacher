//
//  ViewController.m
//  iOSCacher
//
//  Created by WuJianjun on 15/3/19.
//  Copyright (c) 2015年 FORWAY R&D. All rights reserved.
//

#import "ViewController.h"
#import "iOSCacher.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)getObject:(id)sender {
    NSString *key = ((AppDelegate*)[UIApplication sharedApplication].delegate).key;
    NSLog(@"key = %@",key);
    id obj = [[iOSCacher share]getFromDisk:key];
    NSLog(@"obj = %@", obj);
}

@end
