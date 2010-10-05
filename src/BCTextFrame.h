#import <libxml/HTMLparser.h>

@interface BCTextFrame : NSObject {
	xmlNode *node;
}

- (id)initWithHTML:(NSString *)html;

@end
