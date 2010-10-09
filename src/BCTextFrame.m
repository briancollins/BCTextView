#import "BCTextFrame.h"
#import "BCTextLine.h"
#import "BCTextNode.h"
#import "BCImageNode.h"
#import "BCBlockBorder.h"

typedef enum {
	BCTextNodePlain = 0,
	BCTextNodeBold = 1,
	BCTextNodeItalic = 1 << 1,
	BCTextNodeLink = 1 << 2,
} BCTextNodeAttributes;

@interface BCTextFrame ()
- (UIFont *)fontWithAttributes:(BCTextNodeAttributes)attr;

@property (nonatomic, retain) NSMutableArray *lines;
@property (nonatomic, retain) BCTextLine *currentLine;
@end

@implementation BCTextFrame
@synthesize fontSize, height, width, lines, textColor, linkColor, delegate, indented, links;

- (id)init {
	if ((self = [super init])) {
		self.textColor = [UIColor blackColor];
		self.linkColor = [UIColor blueColor];
	}
	
	return self;
}

- (id)initWithHTML:(NSString *)html {
	if ((self = [self init])) {
		CFStringEncoding cfenc = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
		CFStringRef cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc);
		const char *enc = CFStringGetCStringPtr(cfencstr, 0);
		// let's set our xml doc to doc because we don't want to free node
		// (which we didn't alloc) but we want to free a doc we alloced
		doc = node = (xmlNode *)htmlReadDoc((xmlChar *)[html UTF8String],
									   "",
									   enc,
									   XML_PARSE_NOERROR | XML_PARSE_NOWARNING);
	}
	
	return self;
}

- (id)initWithXmlNode:(xmlNode *)aNode {
	if ((self = [self init])) {
		node = aNode;
	}
	
	return self;
}

- (void)touchBeganAtPoint:(CGPoint)point {
	for (NSValue *link in self.links) {
		NSArray *rects = [self.links objectForKey:link];
		for (NSValue *v in rects) {
			if (CGRectContainsPoint([v CGRectValue], point)) {
				touchingLink = link;
				[self.delegate link:link touchedInRects:rects];
				return;
			}
		}
	}
}

- (void)touchEndedAtPoint:(CGPoint)point {
	if (touchingLink) {
		NSArray *rects = [self.links objectForKey:touchingLink];
		for (NSValue *v in rects) {
			if (CGRectContainsPoint([v CGRectValue], point)) {
				[self.delegate link:touchingLink touchedUpInRects:rects];
				
				break;
			}
		}
	}
	touchingLink = nil;
}

- (void)touchCancelled {
	touchingLink = nil;
}

- (void)pushNewline:(BCTextLine *)line {
	line.indented = self.indented;
	if (self.currentLine.height == 0) {
		self.currentLine.height = self.fontSize;
	}
	self.currentLine = line;
}

- (void)pushNewline {
	[self pushNewline:[[[BCTextLine alloc] initWithWidth:self.width] autorelease]];
}

- (void)addLink:(NSValue *)link forRect:(CGRect)rect {
	NSMutableArray *a = [self.links objectForKey:link];
	if (!a) {
		a = [NSMutableArray array];
		[self.links setObject:a forKey:link];
	}
	
	[a addObject:[NSValue valueWithCGRect:rect]];
}

- (void)pushText:(NSString *)text withFont:(UIFont *)font link:(NSValue *)link {
	CGSize size = [text sizeWithFont:font];

	if (size.width > self.currentLine.widthRemaining) {
		NSRange spaceRange = [text rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		// a word that needs to wrap
		if (spaceRange.location == NSNotFound || spaceRange.location == text.length - 1) {
			[self pushNewline];
			if (size.width > self.currentLine.width) { // word is too long even for its own line
				CGFloat partWidth;
				NSString *textPart = nil;
				NSString *lastPart = nil;
				NSInteger length = 1;
				
				do {
					lastPart = textPart;
					textPart = [text substringToIndex:length++];
					partWidth = [textPart sizeWithFont:font].width;
				} while (partWidth < self.currentLine.width);
				
				[self pushText:lastPart withFont:font link:link];
				[self pushText:[text substringFromIndex:length - 2] withFont:font link:link];
			} else {
				[self pushText:text withFont:font link:link];
			}
		} else {
			[self pushText:[text substringWithRange:NSMakeRange(0, spaceRange.location + 1)] withFont:font
					  link:link];
			[self pushText:[text substringWithRange:NSMakeRange(spaceRange.location + 1, text.length - (spaceRange.location + 1))]
				  withFont:font
					  link:link];
		}
	} else {
		BCTextNode *n = [[[BCTextNode alloc] initWithText:text font:font width:size.width height:size.height link:link != nil] autorelease];
		
		if (link) {
			[self addLink:link forRect:CGRectMake((self.currentLine.width - self.currentLine.widthRemaining) - 4, 
												  self.currentLine.y - 4, 
												  n.width + 8, n.height + 8)];
		}
																				  
		[self.currentLine addNode:n height:size.height];
	}
}

- (void)pushImage:(NSString *)src linkTarget:(NSValue *)link {
	if ([(NSObject *)self.delegate respondsToSelector:@selector(imageForURL:)]) {
		UIImage *img = [self.delegate imageForURL:src];
		if (img.size.width > self.currentLine.widthRemaining) {
			[self pushNewline];
		}
		[self.currentLine addNode:[[[BCImageNode alloc] initWithImage:img link:link != nil] autorelease] height:img.size.height];
		whitespaceNeeded = YES;
	}
}


- (void)pushBlockBorder {
	[self pushNewline:[[[BCBlockBorder alloc] initWithWidth:self.width] autorelease]];
}


- (NSString *)stripWhitespace:(char *)str {
	char *stripped = malloc(strlen(str) + 1);
	int i = 0;
	for (*str; *str != '\0'; *str++) {
		if (*str == ' ' || *str == '\t' || *str == '\n' || *str == '\r') {
			if (whitespaceNeeded) {
				stripped[i++] = ' ';
				whitespaceNeeded = NO;
			}
		} else {
			whitespaceNeeded = YES;
			stripped[i++] = *str;
		}
	}
	stripped[i] = '\0';
	NSString *strippedString = [NSString stringWithUTF8String:stripped];
	free(stripped);
	return strippedString;
}


- (void)layoutNode:(xmlNode *)n attributes:(BCTextNodeAttributes)attr linkTarget:(NSValue *)link {
	if (!n) return;
	
	for (xmlNode *curNode = n; curNode; curNode = curNode->next) {
		if (curNode->type == XML_TEXT_NODE) {
			UIFont *textFont = [self fontWithAttributes:attr];
			
			NSString *text = [self stripWhitespace:(char *)curNode->content];
			
			[self pushText:text withFont:textFont link:link];
		} else {
			BCTextNodeAttributes childrenAttr = attr;
			
			if (curNode->name) {
				if (!strcmp((char *)curNode->name, "b")) {
					childrenAttr |= BCTextNodeBold;
				} else if (!strcmp((char *)curNode->name, "i")) {
					childrenAttr |= BCTextNodeItalic; 
				} else if (!strcmp((char *)curNode->name, "a")) {
					childrenAttr |= BCTextNodeLink;
					[self layoutNode:curNode->children attributes:childrenAttr linkTarget:[NSValue valueWithPointer:curNode]];
					continue;
				} else if (!strcmp((char *)curNode->name, "br")) {
					[self pushNewline];
					whitespaceNeeded = NO;
				} else if (!strcmp((char *)curNode->name, "h4")) {
					childrenAttr |= (BCTextNodeBold | BCTextNodeItalic);
					[self layoutNode:curNode->children attributes:childrenAttr linkTarget:link];
					[self pushNewline];
					whitespaceNeeded = NO;
					continue;
				} else if (!strcmp((char *)curNode->name, "div")) {
					char *class =(char *)xmlGetProp(curNode, (xmlChar *)"class");
					if (class) {
						if (!strcmp(class, "bbc-block")) {
							[self pushBlockBorder];
							self.indented = YES;
							[self pushNewline];
							[self layoutNode:curNode->children attributes:childrenAttr linkTarget:link];
							self.indented = NO;
							[self.lines removeLastObject];
							[self pushBlockBorder];
							[self pushNewline];
							whitespaceNeeded = NO;
							free(class);
							continue;
						} else {
							free(class);
						}
					} 
				} else if (!strcmp((char *)curNode->name, "img")) {
					char *url = (char *)xmlGetProp(curNode, (xmlChar *)"src");
					NSString *src = [NSString stringWithUTF8String:url];
					free(url);
					[self pushImage:src linkTarget:link];
				}
			}

			[self layoutNode:curNode->children attributes:childrenAttr linkTarget:link];
		}
	}
}

- (void)drawInRect:(CGRect)rect {
	for (BCTextLine *line in self.lines) {
		if (line.y > rect.size.height) {
			return;
		}
		
		[line drawAtPoint:CGPointMake(rect.origin.x, rect.origin.y + line.y) textColor:self.textColor linkColor:self.linkColor];
	}
}

- (BCTextLine *)currentLine {
	return [self.lines lastObject];
}

- (void)setCurrentLine:(BCTextLine *)aLine {
	aLine.y = self.currentLine.y + self.currentLine.height;
	[self.lines addObject:aLine];
}

- (void)setWidth:(CGFloat)aWidth {
	self.links = [NSMutableDictionary dictionary];
	width = aWidth;
	self.lines = [NSMutableArray array];
	self.currentLine = [[[BCTextLine alloc] initWithWidth:width] autorelease];
	[self layoutNode:node attributes:BCTextNodePlain linkTarget:nil];
	height = self.currentLine.y + self.currentLine.height;
}

- (void)dealloc {
	if (doc) 
		xmlFreeDoc((xmlDoc *)doc);
	
	node = NULL;
	self.links = nil;
	self.textColor = nil;
	self.linkColor = nil;
	self.lines = nil;
	self.currentLine = nil;
	[super dealloc];
}

- (CGFloat)fontSize {
	if (!fontSize) {
		fontSize = 12;
	}
	return fontSize;
}

- (UIFont *)regularFont {
	return [UIFont fontWithName:@"Helvetica" size:self.fontSize];
}

- (UIFont *)boldFont {
	return [UIFont fontWithName:@"Helvetica-Bold" size:self.fontSize];
}

- (UIFont *)italicFont {
	return [UIFont fontWithName:@"Helvetica-Oblique" size:self.fontSize];
}

- (UIFont *)boldItalicFont {
	return [UIFont fontWithName:@"Helvetica-BoldOblique" size:self.fontSize];
}

- (UIFont *)fontWithAttributes:(BCTextNodeAttributes)attr {
	if (attr & BCTextNodeItalic && attr & BCTextNodeBold) {
		return [self boldItalicFont];
	} else if (attr & BCTextNodeItalic) {
		return [self italicFont];
	} else if (attr & BCTextNodeBold) {
		return [self boldFont];
	} else {
		return [self regularFont];
	}
}

@end
