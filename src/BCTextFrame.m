#import "BCTextFrame.h"

@interface BCTextFrame ()

- (void)parseNode:(xmlNode *)n;

@end

@implementation BCTextFrame

- (id)initWithHTML:(NSString *)html {
	if ((self = [super init])) {
		CFStringEncoding cfenc = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
		CFStringRef cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc);
		const char *enc = CFStringGetCStringPtr(cfencstr, 0);
		node = (xmlNode *)htmlReadDoc((xmlChar *)[html UTF8String],
									   "",
									   enc,
									   XML_PARSE_NOERROR | XML_PARSE_NOWARNING);
		[self parseNode:node];
	}
	
	return self;
}

- (void)parseNode:(xmlNode *)n {
	if (!n) return;

	for (xmlNode *curNode = n; curNode; curNode = curNode->next) {

		printf("node type: Element, name: %s\n", curNode->name);
		[self parseNode:curNode->children];
	}
}


- (void)dealloc {
	if (node) 
		xmlFreeDoc((xmlDoc *)node);
	
	node = NULL;
	[super dealloc];
}

@end
