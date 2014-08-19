fast-twitter-label
==================

Fast UILabel subclass that parses # hashtags, @ mentions and links using TwitterText lib

#Usage

1. Create instance in code or from Xib
2. Setup text and attributes
```
NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
[paragrahStyle setLineSpacing:0];
[paragrahStyle setLineHeightMultiple:0.9];

NSNumber *hashtagType = [NSNumber numberWithInt:SDWTwitterEntityTypeHashtag];
NSDictionary *hashtagAttributes = @{
                                    NSForegroundColorAttributeName:UIColorFromRGB(0x17a6d0),
                                    NSFontAttributeName: DinProRegular(18),
                                    NSParagraphStyleAttributeName: paragrahStyle
                                    };

NSNumber *plainType = [NSNumber numberWithInt:SDWTwitterEntityTypePlain];
NSDictionary *plainAttributes = @{NSForegroundColorAttributeName: UIColorFromRGB(0x555555),
                                  NSFontAttributeName: DinProRegular(18),
                                  NSParagraphStyleAttributeName: paragrahStyle
                                  };
[self.label showWithText:trimmedWhitespaceString attributes:@
{
  hashtagType:hashtagAttributes,
  plainType:plainAttributes
}];
                                                                                
```

Add detection block if needed
```
    [self.label setDetectionBlock:^(SDWTwitterEntityType type, NSString *string) {
    // do your thing
    }];
```
