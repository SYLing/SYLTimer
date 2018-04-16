//
//  NSTimer+SYLTimer.h
//  Demo
//
//  Created by 邵银岭 on 2018/4/16.
//  Copyright © 2018年 邵银岭. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (SYLTimer)

+ (instancetype)syl_timerWithTimeInterval:(NSTimeInterval)time repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block;

@end
