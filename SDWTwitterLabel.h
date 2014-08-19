//
//  SDWTwitterLabel.h
//  TextkitExperiments
//
//  Created by alex on 8/16/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//

#import "TwitterText.h"
#import "TwitterTextEntity.h"

typedef enum {
	SDWTwitterEntityTypeURL = TwitterTextEntityURL,
	SDWTwitterEntityTypeScreenName = TwitterTextEntityScreenName,
	SDWTwitterEntityTypeHashtag = TwitterTextEntityHashtag,
	SDWTwitterEntityTypeListName = TwitterTextEntityListName,
	SDWTwitterEntityTypeSymbol = TwitterTextEntitySymbol,
	SDWTwitterEntityTypePlain
} SDWTwitterEntityType;


#import <UIKit/UIKit.h>

@interface SDWTwitterLabel : UILabel

@property (nonatomic, copy) void (^detectionBlock)(SDWTwitterEntityType entityType, NSString *string);

- (void)showWithText:(NSString *)text attributes:(NSDictionary *)textAttributes;

@end
