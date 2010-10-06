#import <libxml/HTMLparser.h>

@interface BCTextFrame : NSObject {
	xmlNode *node;
	CGFloat fontSize;
}

- (id)initWithHTML:(NSString *)html;
- (void)drawInContext:(CGContextRef)context;

@property (nonatomic) CGFloat fontSize;

@end
