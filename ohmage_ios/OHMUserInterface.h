//
//  OHMUserInterface.h
//  ohmage_ios
//
//  Created by Charles Forkish on 4/24/14.
//  Copyright (c) 2014 VPD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIColor+Ohmage.h"

@interface OHMUserInterface : NSObject

+ (CGSize)sizeForText:(NSString *)text withWidth:(CGFloat)width font:(UIFont *)font;
+ (CGFloat)heightForText:(NSString *)text withWidth:(CGFloat)width font:(UIFont *)font;
+ (CGFloat)heightForSubtitleCellWithTitle:(NSString *)title
                                 subtitle:(NSString *)subtitle
                            accessoryType:(UITableViewCellAccessoryType)accessoryType
                            fromTableView:(UITableView *)tableView;
+ (UITableViewCell *)cellWithDefaultStyleFromTableView:(UITableView *)tableView;
+ (UITableViewCell *)cellWithDetailStyleFromTableView:(UITableView *)tableView;
+ (UITableViewCell *)cellWithSwitchFromTableView:(UITableView *)tableView setupBlock:(void (^)(UISwitch *sw))swBlock;
+ (UITableViewCell *)cellWithTimePickerFromTableView:(UITableView *)tableView setupBlock:(void (^)(UIDatePicker *dp))dpBlock;

+ (UILabel *)headerTitleLabelWithText:(NSString *)text width:(CGFloat)width;
+ (UILabel *)headerDescriptionLabelWithText:(NSString *)text width:(CGFloat)width;
+ (UILabel *)headerDetailLabelWithText:(NSString *)text width:(CGFloat)width;
+ (UILabel *)variableHeightLabelWithText:(NSString *)text width:(CGFloat)width font:(UIFont *)font;
+ (UILabel *)fixedSizeLabelWithText:(NSString *)text size:(CGSize)size font:(UIFont *)font;
+ (UIView *)fixedSizeFramedLabelWithText:(NSString *)text
                                    size:(CGSize)size
                                    font:(UIFont *)font
                               alignment:(NSTextAlignment)textAlignment;
+ (UIView *)textFieldWithLabelText:(NSString *)text setupBlock:(void (^)(UITextField *tf))tfBlock;

+ (UIButton *)buttonWithTitle:(NSString *)title target:(id)target action:(SEL)selector maxWidth:(CGFloat)maxWidth;
+ (UIButton *)buttonWithTitle:(NSString *)title target:(id)target action:(SEL)selector size:(CGSize)size;

+ (void)applyRoundedBorderToView:(UIView *)view radius:(CGFloat)borderRadius;

+ (NSString *)formattedDate:(NSDate *)date;

@end