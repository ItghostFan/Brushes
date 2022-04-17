//
//  WDActionSheet.m
//  Brushes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2012-2013 Steve Sprang
//

#import "WDActionSheet.h"

#import "WDAppDelegate.h"

@interface WDTagProvider : NSObject
@property (nonatomic, assign) int tag;
+ (WDTagProvider *) tagProviderWithNumber:(NSNumber *)number;
@end

@implementation WDTagProvider
@synthesize tag;

+ (WDTagProvider *) tagProviderWithNumber:(NSNumber *)number
{
    WDTagProvider *tagProvider = [[WDTagProvider alloc] init];
    tagProvider.tag = number.intValue;
    return tagProvider;
}

@end

@implementation WDActionSheet

@synthesize sheet;
@synthesize actions;
@synthesize delegate;
@synthesize tags;

+ (WDActionSheet *) sheet
{
    WDActionSheet *sheet = [[WDActionSheet alloc] init];
    return sheet;
}

- (id) init
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
//    sheet = [[UIActionSheet alloc] init];
//    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    actions = [[NSMutableArray alloc] init];
    tags = [[NSMutableArray alloc] init];
    
    self.sheet = [UIAlertController alertControllerWithTitle:nil
                                                    message:nil
                                             preferredStyle:UIAlertControllerStyleActionSheet];
    [((WDAppDelegate *)UIApplication.sharedApplication.delegate).navigationController.topViewController presentViewController:self.sheet animated:YES completion:^{
    }];
    
    return self;
}

// TODO: 增加这个。
//    [delegate actionSheetDismissed:self];

- (void) addButtonWithTitle:(NSString *)title action:(void (^)(id))action
{
    [self addButtonWithTitle:title action:action tag:0];
}

- (void) addButtonWithTitle:(NSString *)title action:(void (^)(id))action tag:(int)tag
{
    NSInteger index = self.actions.count;
    [self.sheet addAction:[UIAlertAction actionWithTitle:title
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * _Nonnull action) {
        void (^block)(id) = self.actions[index];
        block([WDTagProvider tagProviderWithNumber:(self.tags)[index]]);
    }]];
    [self.actions addObject:[action copy]];
    [self.tags addObject:@(tag)];
}

- (void) addCancelButton
{
    [self.sheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                   style:UIAlertActionStyleCancel
                                                 handler:^(UIAlertAction * _Nonnull action) {
    }]];;
}

@end
