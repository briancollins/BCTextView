@interface BCTextNode : NSObject {
	NSString *text;
	UIFont *font;
	CGFloat width;
	BOOL link;
}

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) UIFont *font;
@property (readonly) CGFloat width;
@property (nonatomic) BOOL link;

- (id)initWithText:(NSString *)text font:(UIFont *)font width:(CGFloat)aWidth link:(BOOL)isLink;
- (void)drawAtPoint:(CGPoint)point;

@end
