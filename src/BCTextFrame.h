#import <libxml/HTMLparser.h>

@class BCTextLine;

@interface BCTextFrame : NSObject {
	xmlNode *node;
	CGFloat fontSize;
	BCTextLine *currentLine;
	CGFloat height;
}

- (id)initWithHTML:(NSString *)html;
- (void)drawInRect:(CGRect)rect;

@property (nonatomic) CGFloat fontSize;
@property (nonatomic) CGFloat height;

@end
