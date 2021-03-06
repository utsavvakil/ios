//
//  UIColor+Ohmage.m
//  ohmage_ios
//
//  Created by Charles Forkish on 4/24/14.
//  Copyright (c) 2014 VPD. All rights reserved.
//

#import "UIColor+Ohmage.h"

@implementation UIColor (Ohmage)

- (UIColor *)lightColor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s * 0.5
                          brightness:MIN(b * 1.2, 1.0)
                               alpha:a];
    return nil;
}

- (UIColor *)buttonPressedColor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:MIN(s * 1.1, 1.0)
                          brightness:b * 0.9
                               alpha:a];
    return nil;
}

@end
