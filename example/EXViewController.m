#import "EXViewController.h"
#import "BCTextView.h"

@implementation EXViewController

- (void)viewDidLoad {
	BCTextView *textView = [[[BCTextView alloc] initWithHTML:
							 [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"] 
													   encoding:NSUTF8StringEncoding 
														  error:NULL]]
							  
							autorelease];
	textView.fontSize = 14;
	textView.frame = self.view.bounds;
	textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	textView.backgroundColor = [UIColor whiteColor];

	self.view.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:textView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

@end
