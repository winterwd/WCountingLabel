//
//  WCountingLable.m
//  WCountingLable
//
//  Created by winter on 2017/2/9.
//  Copyright © 2017年 wd. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WCountingLable.h"

#pragma mark - WLabelCounter

#ifndef kLabelCounterRate
#define kLabelCounterRate 3
#endif

@protocol WLabelCounter <NSObject>
- (CGFloat)update:(CGFloat)t;
@end

@interface WLabelCounterLiear : NSObject<WLabelCounter>
@end

@interface WLabelCounterEaseIn : NSObject<WLabelCounter>
@end

@interface WLabelCounterEaseOut : NSObject<WLabelCounter>
@end

@interface WLabelCounterEaseInOut : NSObject<WLabelCounter>
@end

@implementation WLabelCounterLiear

- (CGFloat)update:(CGFloat)t
{
    return t;
}

@end

@implementation WLabelCounterEaseIn

- (CGFloat)update:(CGFloat)t
{
    // powf(float x, float y）;计算以x为底数的y次幂
    return powf(t, kLabelCounterRate);
}

@end

@implementation WLabelCounterEaseOut

- (CGFloat)update:(CGFloat)t
{
    return 1.0 - powf((1.0-t), kLabelCounterRate);
}

@end

@implementation WLabelCounterEaseInOut

- (CGFloat)update:(CGFloat)t
{
    t *= 2;
    if (t < 1)
        return 0.5f * powf (t, kLabelCounterRate);
    else
        return 0.5f * (2.0f - powf(2.0 - t, kLabelCounterRate));

}

@end

#pragma mark - WCountingLable

@interface WCountingLable ()

@property (nonatomic, copy) NSString *preFormat;
@property (nonatomic, copy) NSString *midFormat;
@property (nonatomic, copy) NSString *sufFormat;

@property (nonatomic, assign) CGFloat startingValue;
@property (nonatomic, assign) CGFloat destinationValue;

@property (nonatomic, assign) NSTimeInterval progress;
@property (nonatomic, assign) NSTimeInterval lastUpdate;
@property (nonatomic, assign) NSTimeInterval totalTime;

@property (nonatomic, strong) CADisplayLink *timer;
@property (nonatomic, strong) id<WLabelCounter> counter;
@end

@implementation WCountingLable

#pragma mark - method

- (void)countFrom:(CGFloat)startValue to:(CGFloat)endValue
{
    if (self.animationDuration == 0.0f) {
        self.animationDuration = 2.0;
    }
    
    [self countFrom:startValue to:endValue duration:self.animationDuration];
}

- (void)countFrom:(CGFloat)startValue to:(CGFloat)endValue duration:(NSTimeInterval)duration
{
    self.startingValue = startValue;
    self.destinationValue = endValue;
    
    // remove old timers
    [self.timer invalidate];
    self.timer = nil;
    
    if (duration == 0.0) {
        // no animation
        [self setTextValue:endValue];
        [self runCompletionBlock];
        return;
    }
    
    // animation
    [self animationWith:duration];
}

- (void)countFromCurrentValueTo:(CGFloat)endValue
{
    [self countFrom:[self currentVale] to:endValue];
}

- (void)countFromCurrentValueTo:(CGFloat)endValue duration:(NSTimeInterval)duration
{
    [self countFrom:[self currentVale] to:endValue duration:duration];
}

- (void)countFromZeroTo:(CGFloat)endValue
{
    [self countFrom:0.0f to:endValue];
}

- (void)countFromZeroTo:(CGFloat)endValue duration:(NSTimeInterval)duration
{
    [self countFrom:0.0f to:endValue duration:duration];
}

#pragma mark - private method

- (void)setFormat:(NSString *)format
{
    _format = format;

    // 更新 显示格式
    [self setNumberStyle:self.numberStyle];
}

- (void)setNumberStyle:(NSNumberFormatterStyle)numberStyle
{
    _numberStyle = numberStyle;
    
    if (self.format.length > 0) {
        NSRange rangeD = [self.format rangeOfString:@"%(.*)d" options:NSRegularExpressionSearch];
        NSRange rangeI = [self.format rangeOfString:@"%(.*)i" options:NSRegularExpressionSearch];
        NSRange rangeF = [self.format rangeOfString:@"%(.*)f" options:NSRegularExpressionSearch];
        
        NSRange range = NSMakeRange(0, 0);
        if (rangeD.location != NSNotFound) {
            range = rangeD;
        }
        else if (rangeI.location != NSNotFound) {
            range = rangeI;
        }
        else if (rangeF.location != NSNotFound) {
            range = rangeF;
        }
        self.midFormat = [self.format substringWithRange:range];
        
        NSArray *formats = [self.format componentsSeparatedByString:self.midFormat];
        if (formats.count > 1) {
            self.preFormat = [formats firstObject];
            self.sufFormat  =[formats lastObject];
        }
        else if (formats.count == 1){
            self.preFormat = [formats firstObject];
        }
    }
    else {
        self.midFormat = self.format = @"%d";
        self.preFormat = @"";
        self.sufFormat = @"";
    }
}

- (void)setTextValue:(CGFloat)value
{
    if (self.attributedFormatBlock != nil) {
        self.attributedText = self.attributedFormatBlock(value);
    }
    else if (self.formatBlock != nil) {
        self.text = self.formatBlock(value);
    }
    else {
        // 检查是否是 int 类型
        BOOL forInt = ([self.format rangeOfString:@"%(.*)d" options:NSRegularExpressionSearch].location != NSNotFound || [self.format rangeOfString:@"%(.*)i"].location != NSNotFound);
        self.text = [self valueStringWith:value forInt:forInt];
    }
}

- (NSString *)valueStringWith:(CGFloat)value forInt:(BOOL)forInt
{
    if (self.numberStyle == NSNumberFormatterNoStyle) {
        if (forInt) {
            return [NSString stringWithFormat:self.format, (int)value];
        }
        else {
            return [NSString stringWithFormat:self.format, value];
        }
    }
    else {
        NSString *valueString = nil;
        if (forInt) {
            valueString = [NSString stringWithFormat:self.midFormat, (int)value];
        }
        else {
            valueString = [NSString stringWithFormat:self.midFormat, value];
        }
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        NSNumber *number = [formatter numberFromString:valueString];
        formatter.numberStyle = self.numberStyle;
        NSString *newString = [formatter stringFromNumber:number];
        return [NSString stringWithFormat:@"%@%@%@", self.preFormat,newString,self.sufFormat];
    }
}

- (CGFloat)currentVale
{
    if (self.progress >= self.totalTime) {
        return self.destinationValue;
    }
    
    CGFloat percent = self.progress / self.totalTime;
    CGFloat updateVal = [self.counter update:percent];
    return self.startingValue + (updateVal * (self.destinationValue - self.startingValue));
}

- (void)runCompletionBlock
{
    if (self.completionBlock) {
        self.completionBlock();
//        self.completionBlock = nil;
    }
}

#pragma mark - animation

- (void)animationWith:(NSTimeInterval)duration
{
    self.progress = 0;
    self.totalTime = duration;
    self.lastUpdate = [NSDate timeIntervalSinceReferenceDate];
    
    if (self.format == nil) {
        self.format = @"%d";
    }
    
    switch (self.method) {
        case WLableCountingMethodLinear:
            self.counter = [[WLabelCounterLiear alloc] init];
            break;
        case WLableCountingMethodEaseIn:
            self.counter = [[WLabelCounterEaseIn alloc] init];
            break;
        case WLableCountingMethodEaseOut:
            self.counter = [[WLabelCounterEaseOut alloc] init];
            break;
        case WLableCountingMethodEaseInOut:
            self.counter = [[WLabelCounterEaseInOut alloc] init];
            break;
    }
    
    CADisplayLink *timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateValue:)];
    timer.frameInterval = 2; // 帧率
    [timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:UITrackingRunLoopMode];
    self.timer = timer;
}

- (void)updateValue:(NSTimer *)timer
{
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    self.progress += now - self.lastUpdate;
    self.lastUpdate = now;
    
    if (self.progress >= self.totalTime) {
        [self.timer invalidate];
        self.timer = nil;
        self.progress = self.totalTime;
    }
    
    [self setTextValue:[self currentVale]];
    
    if (self.progress == self.totalTime) {
        [self runCompletionBlock];
    }
}
@end
