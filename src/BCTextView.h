@class BCTextFrame;

@interface BCTextView : UIView {
	BCTextFrame *textFrame;
}

- (id)initWithHTML:(NSString *)html;

@property (nonatomic) CGFloat fontSize;

@end
