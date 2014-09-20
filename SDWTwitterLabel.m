//
//  SDWTwitterLabel.m
//  TextkitExperiments
//
//  Created by alex on 8/16/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//

#import "SDWTwitterLabel.h"
#import "TwitterText.h"
#import "TwitterTextEntity.h"

@import CoreText;

@interface SDWTwitterTextStorage : NSTextStorage

- (instancetype)initWithAttributesForEntityTypes:(NSDictionary *)types;

@property (strong) NSArray *entitiesInText;

@end

@implementation SDWTwitterTextStorage {

	NSMutableAttributedString *_imp;
	NSDictionary *_attributes;
}

- (instancetype)initWithAttributesForEntityTypes:(NSDictionary *)attr {

	self = [super init];

	if (self) {
		_imp = [[NSMutableAttributedString alloc] init];
		_attributes = attr;
	}

	return self;
}

- (NSString *)string {
	return [_imp string];
}

- (NSAttributedString *)attributedString {
	return _imp;
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range {
	return [_imp attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str {
    [self beginEditing];
	[_imp replaceCharactersInRange:range withString:str];
	[self edited:NSTextStorageEditedCharacters range:range changeInLength:(NSInteger)str.length - (NSInteger)range.length];
    [self endEditing];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range {
    [self beginEditing];
	[_imp setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];
}

- (void)processEditing {

    NSDictionary *attributesForPlainText = (NSDictionary *)_attributes[[NSNumber numberWithInt:SDWTwitterEntityTypePlain]];
    [self addAttributes:attributesForPlainText range:NSMakeRange(0, self.string.length)];

    self.entitiesInText =  [TwitterText entitiesInText:self.string];

    for (TwitterTextEntity *entity in self.entitiesInText) {

        NSDictionary *attributesForType = (NSDictionary *)_attributes[[NSNumber numberWithInt:entity.type]];

        if (attributesForType) {
            [self addAttributes:attributesForType range:entity.range];
        }
    }

	[super processEditing];
}

@end


@interface SDWTwitterLabel () {

	NSString *_cleantext;
    UITextView *_textView;
    SDWTwitterTextStorage *_textStorage;
    NSLayoutManager *_layoutManager;
    NSTextContainer *_textContainer;
    NSDictionary *_textAttributes;
}

@end

@implementation SDWTwitterLabel

- (void)showWithText:(NSString *)text attributes:(NSDictionary *)textAttributes {

    _textAttributes = textAttributes ? : [self defaultTextAttributes];

    [self setup];
    self.text = text;
}

- (NSDictionary *)defaultTextAttributes {

	NSNumber *mentionType = [NSNumber numberWithInt:SDWTwitterEntityTypeScreenName];
	NSDictionary *mentionAttributes = @{ NSForegroundColorAttributeName:[UIColor darkGrayColor], NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:24] };
	
	NSNumber *urlType = [NSNumber numberWithInt:SDWTwitterEntityTypeURL];
	NSDictionary *urlAttributes = @{ NSForegroundColorAttributeName:[UIColor darkGrayColor], NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:24] };

	NSNumber *hashtagType = [NSNumber numberWithInt:SDWTwitterEntityTypeHashtag];
	NSDictionary *hashtagAttributes = @{ NSForegroundColorAttributeName:[UIColor darkGrayColor], NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:24] };

	NSNumber *plainType = [NSNumber numberWithInt:SDWTwitterEntityTypePlain];
	NSDictionary *plainAttributes = @{ NSForegroundColorAttributeName:[UIColor grayColor], NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:24] };


	return @{
		hashtagType:hashtagAttributes,
		plainType:plainAttributes,
		mentionType:mentionAttributes,
		urlType:urlAttributes
            };
}

- (void)setup {

	[self setBackgroundColor:[UIColor clearColor]];
	[self setClipsToBounds:NO];
	[self setUserInteractionEnabled:YES];
	[self setNumberOfLines:0];

    if (!_textView) {

        _textStorage = [[SDWTwitterTextStorage alloc]initWithAttributesForEntityTypes:_textAttributes];
        _layoutManager = [NSLayoutManager new];

        _textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)];
        [_layoutManager addTextContainer:_textContainer];
        [_textStorage addLayoutManager:_layoutManager];

        _textView = [[UITextView alloc] initWithFrame:self.bounds textContainer:_textContainer];
        _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _textView.backgroundColor = [UIColor clearColor];
        _textView.textContainer.lineFragmentPadding = 0;
        _textView.textContainerInset = UIEdgeInsetsZero;
        _textView.userInteractionEnabled = NO;
        _textView.clipsToBounds = NO;
        [self addSubview:_textView];
    }

}

- (void)setText:(NSString *)text {
	[super setText:@""];
	_cleantext = text;

    [_textStorage replaceCharactersInRange:NSMakeRange(0, _textStorage.string.length)
                                      withString:_cleantext];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
	self.text = attributedText.string;
}

- (CGSize)sizeThatFits:(CGSize)size {

    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_textView.attributedText);
    CFRange fitRange;
    CGSize frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, size, &fitRange);

    CFRelease(framesetter);

    return frameSize;
}

#pragma mark - UIResponder

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];

	CGPoint touchLocation = [[touches anyObject] locationInView:self];

	if (!CGRectContainsPoint(_textView.frame, touchLocation))
		return;

    CGPoint locationInTextView = [[touches anyObject] locationInView:_textView];
    NSUInteger charaterIndex = [_layoutManager characterIndexForPoint:locationInTextView
                                                      inTextContainer:_textView.textContainer
                             fractionOfDistanceBetweenInsertionPoints:NULL];

	[_textStorage.entitiesInText enumerateObjectsUsingBlock:^(TwitterTextEntity *obj, NSUInteger idx, BOOL *stop) {
	    NSRange range = obj.range;

	    if (charaterIndex >= range.location && charaterIndex < range.location + range.length) {
	        if (self.detectionBlock) self.detectionBlock((SDWTwitterEntityType)obj.type, [_cleantext substringWithRange:range]);
	        *stop = YES;
		}
	}];
}


@end
