//
//  ViewController.m
//  Demo
//
//  Created by 邵银岭 on 2018/4/16.
//  Copyright © 2018年 邵银岭. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.navigationController pushViewController:[NSClassFromString(@"TimerViewController") new] animated:YES];
}

@end
