//
//  Theme.m
//  iDrank
//
//  Created by Rob Balian on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Theme.h"
#import "BACController.h"

@implementation Theme

-(id)initWithTheme:(int)theme {
    if (self = [super init]) {
        themeNum = theme;
        textDict = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BACStrings" ofType:@"plist"]];
        NSLog(@"Dict: %@", textDict);
    }
    return self;
    //UIImageView *
}

-(UIView *)getView:(id)sender {
    NSString *nibName;
    switch (themeNum) {
        case THEME_STANDARD:
            nibName = @"StandardThemeView";
            break;
        case THEME_COLLEGE:
            nibName = @"CollegeThemeView";
            break;
        default:
            nibName = @"StandardThemeView";
            break;
    }
    NSArray *nibObjs;
    nibObjs = [[NSBundle mainBundle] loadNibNamed:nibName owner:sender options:nil];
    return [nibObjs objectAtIndex:0];
}

-(NSString *)getBodyLabel {
    double bac = [[BACController sharedInstance] getCurrentBAC];
    NSString *returnStr;
    for (NSDictionary *bacDict in [textDict objectAtIndex:themeNum]) {
        NSLog(@"BAC_Tier: %f", [((NSString *)[bacDict objectForKey:@"BAC_Tier"]) doubleValue]);
        if (bac >= [((NSString *)[bacDict objectForKey:@"BAC_Tier"]) doubleValue]) {
            int rand = arc4random() % [[bacDict objectForKey:@"texts"] count];
            returnStr = (NSString *)[[bacDict objectForKey:@"texts"] objectAtIndex:rand];
        }
    }

    
    
    
    return returnStr;    
}

-(int)getThemeNum {
    return themeNum;
}

-(void)setTheme:(int)newTheme {
    themeNum = newTheme;
}

@end
