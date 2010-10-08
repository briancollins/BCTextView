#import <libxml/HTMLparser.h>

@class BCTextLine;
@protocol BCTextFrameDelegate;


@interface BCTextFrame : NSObject {
	xmlNode *node;
	xmlNode *doc;
	CGFloat fontSize;
	NSMutableArray *lines;
	CGFloat height;
	CGFloat width;
	UIColor *textColor;
	UIColor *linkColor;
	BOOL whitespaceNeeded;
	BOOL indented;
	id <BCTextFrameDelegate> delegate;
	NSMutableDictionary *links;
	NSValue *touchingLink;
}

- (id)initWithHTML:(NSString *)html;
- (id)initWithXmlNode:(xmlNode *)aNode;
- (void)drawInRect:(CGRect)rect;
- (void)touchBeganAtPoint:(CGPoint)point;
- (void)touchEndedAtPoint:(CGPoint)point;
- (void)touchCancelled;

@property (nonatomic) CGFloat fontSize;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat width;
@property (nonatomic) BOOL indented;

@property (nonatomic, retain) NSMutableDictionary *links;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIColor *linkColor;
@property (nonatomic, assign) id <BCTextFrameDelegate> delegate;

@end

@protocol BCTextFrameDelegate
- (void)link:(NSValue *)link touchedInRects:(NSArray *)rects;
- (void)link:(NSValue *)link touchedUpInRects:(NSArray *)rects;
- (UIImage *)imageForURL:(NSString *)url;

@end

