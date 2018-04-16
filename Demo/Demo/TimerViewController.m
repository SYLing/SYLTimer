//
//  TimerViewController.m
//  Demo
//
//  Created by 邵银岭 on 2018/4/16.
//  Copyright © 2018年 邵银岭. All rights reserved.
//

#import "TimerViewController.h"
#import "NSTimer+SYLTimer.h"

@interface TimerViewController ()

@property (nonatomic , strong) NSTimer *timer;

@end

@implementation TimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"定时器";
    
//    [self timerOne];
//    [self timerTwo];
//    [self timerThree];
//    [self timerFour];
//    [self timerFive];
//    [self timerSix];
//    [self timerSeven];
    [self timerNine];
    
}


- (void)timerOne{
    // 1.循环引用，当tiemr 为weak时崩溃
    //    @property (nonatomic , weak) NSTimer *timer;
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    // 不手动加入不会执行
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
}

- (void)timerTwo{
    
    // 2.target 用 __weak 修饰也解除不了循环引用
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:weakSelf selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
}

- (void)timerThree{
    // 3.自动加入runloop NSDefaultRunLoopMode
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    // NSTimer还会起作用,因为Runloop对NSTimer 有了强引用，指向NSTimer那块内存。
    self.timer = nil;
}


- (void)timerFour{
    
    __weak typeof(self) weakSelf = self;
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("SYLing", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue, ^{
        
        weakSelf.timer = [NSTimer timerWithTimeInterval:1.0 target:weakSelf selector:@selector(timerAction) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:weakSelf.timer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] run];
        // 在 touchesBegan:withEvent: 主线程中取消无法打印下面消息
        NSLog(@"SYLing");
    });
}


// 子线程中创建，子线程中销毁
- (void)timerFive{
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("SYLinging", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_group_async(group, queue, ^{
        
        self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        
        [self performSelector:@selector(myInvalidate) withObject:nil afterDelay:3.0];
        [[NSRunLoop currentRunLoop] run];
        
        // 在 touchesBegan:withEvent: 主线程中取消无法打印下面消息
        NSLog(@"SYLing");
    });
}

// 自定义创建方法解决循环引用
- (void)timerSix{
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer syl_timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer *timer) {
        [weakSelf timerAction];
    }];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
}

// iOS 10 以后的系统方法
- (void)timerSeven{
    
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [weakSelf timerAction];
    }];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

// GCD 定时器
- (void)timerNine {
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t queue = dispatch_queue_create("SYLingGCDTimer", DISPATCH_QUEUE_CONCURRENT);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    // leewayInSeconds 精准度
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        // code to be executed when timer fires
        timer;
        [weakSelf timerAction];
    });
    dispatch_resume(timer);
}
// 有点自欺欺人的写法
- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
    NSLog(@"timer 销毁了");
}

// 定时器执行的方法
- (void)timerAction
{
    NSLog(@"timerAction");
}

// 主动调用停止
- (void)myInvalidate{
    [self.timer invalidate];
    self.timer = nil;
}

// 主线程取消定时器
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self myInvalidate];
}

@end
