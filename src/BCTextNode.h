#import "BCNode.h"

@interface BCTextNode : BCNode {
	NSString *text;
	UIFont *font;
	CGFloat width;
	CGFloat height;
	BOOL link;
}

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) UIFont *font;
@property (readonly) CGFloat width;
@property (readonly) CGFloat height;
@property (nonatomic) BOOL link;

- (id)initWithText:(NSString *)text font:(UIFont *)font width:(CGFloat)aWidth height:(CGFloat)aHeight link:(BOOL)isLink;
- (void)drawAtPoint:(CGPoint)point;

@end
