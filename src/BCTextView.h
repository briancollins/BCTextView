@class BCTextFrame;

@interface BCTextView : UIView {
	BCTextFrame *textFrame;
}

- (id)initWithHTML:(NSString *)html;

@end
