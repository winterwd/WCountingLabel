//
//  WCountingLable.h
//  WCountingLable
//
//  Created by winter on 2017/2/9.
//  Copyright © 2017年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WLableCountingMethod) {
    WLableCountingMethodLinear = 0, // 线性
    WLableCountingMethodEaseIn,
    WLableCountingMethodEaseOut,
    WLableCountingMethodEaseInOut // 慢进慢出
};

/**
 返回NSString类型字符串

 @param value 需要显示的数字
 @return NSString类型字符串
 */
typedef NSString *(^WCountingLableStringFormatBlock)(CGFloat value);

/**
 返回NSAttributedString类型字符串

 @param value 需要显示的数字
 @return NSAttributedString类型
 */
typedef NSAttributedString *(^WCountingLableAttributedFormatBlock)(CGFloat value);

@interface WCountingLable : UILabel

/**
 显示方式 default linear
 */
@property (nonatomic, assign) WLableCountingMethod method;

/**
 动画时长 default 2
 */
@property (nonatomic, assign) NSTimeInterval animationDuration;

/**
 数字显示格式 和 numberStyle 一起使用
 */
@property (nonatomic, copy) NSString *format;
// 默认 NSNumberFormatterNoStyle
@property (nonatomic, assign) NSNumberFormatterStyle numberStyle;

@property (nonatomic, copy) WCountingLableStringFormatBlock formatBlock;
@property (nonatomic, copy) WCountingLableAttributedFormatBlock attributedFormatBlock;
// 动画结束
@property (nonatomic, copy) void(^completionBlock)();

- (void)countFrom:(CGFloat)startValue to:(CGFloat)endValue;
- (void)countFrom:(CGFloat)startValue to:(CGFloat)endValue duration:(NSTimeInterval)duration;

- (void)countFromCurrentValueTo:(CGFloat)endValue;
- (void)countFromCurrentValueTo:(CGFloat)endValue duration:(NSTimeInterval)duration;

- (void)countFromZeroTo:(CGFloat)endValue;
- (void)countFromZeroTo:(CGFloat)endValue duration:(NSTimeInterval)duration;
@end
