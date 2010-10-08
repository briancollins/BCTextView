#import "BCNode.h"

@interface BCTextNode : BCNode {
	NSString *text;
	UIFont *font;
	CGFloat width;
	CGFloat height;
}

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) UIFont *font;
@property (readonly) CGFloat width;
@property (readonly) CGFloat height;

- (id)initWithText:(NSString *)text font:(UIFont *)font width:(CGFloat)aWidth height:(CGFloat)aHeight link:(BOOL)isLink;
- (void)drawAtPoint:(CGPoint)point;

@end
