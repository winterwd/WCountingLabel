//
//  ViewController.m
//  WCountingLabelExample
//
//  Created by winter on 2017/2/9.
//  Copyright © 2017年 JHJR. All rights reserved.
//

#import "ViewController.h"
#import "WCountingLabel.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet WCountingLabel *defaultLabel;
@property (weak, nonatomic) IBOutlet WCountingLabel *plainLabel;
@property (weak, nonatomic) IBOutlet WCountingLabel *attributedLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.defaultLabel.completionBlock = ^(){
        NSLog(@"default counting end...");
    };
    self.plainLabel.completionBlock = ^(){
        NSLog(@"plainLabel counting end...");
    };
    self.attributedLabel.completionBlock = ^(){
        NSLog(@"attributedLabel counting end...");
    };
    
    self.plainLabel.method = WLableCountingMethodEaseOut;
    self.attributedLabel.method = WLableCountingMethodEaseInOut;
    
    self.defaultLabel.format = @"￥%.2lf元";
    self.defaultLabel.numberStyle = kCFNumberFormatterDecimalStyle;
    
    self.plainLabel.formatBlock = ^(CGFloat value){
        NSString *string = [NSString stringWithFormat:@"￥%.2lf元",value];
        return string;
    };
    
    self.attributedLabel.attributedFormatBlock = ^(CGFloat value){
        NSString *string = [NSString stringWithFormat:@"￥%.2lf元",value];
        
        NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:string];
        [att addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:48] range:NSMakeRange(0, 1)];
        return att;
    };
}

- (IBAction)buttonAction:(UIButton *)sender
{
    if (sender.tag == 100) {
        [self.defaultLabel countFrom:0 to:19999.99];
    }
    else if (sender.tag == 101) {
        [self.plainLabel countFrom:0 to:19999.99];
    }
    else {
        [self.attributedLabel countFrom:0 to:19999.99];
    }
}


@end
