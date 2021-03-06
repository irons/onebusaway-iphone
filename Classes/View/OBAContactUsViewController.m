/**
 * Copyright (C) 2009 bdferris <bdferris@onebusaway.org>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "OBAContactUsViewController.h"
//#import "ISFeedback.h"


@implementation OBAContactUsViewController

@synthesize appContext = _appContext;

- (id) initWithApplicationContext:(OBAApplicationContext*)appContext {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		_appContext = [appContext retain];
	}
    return self;
}

- (void) dealloc {
	[_appContext release];
	[super dealloc];
}

#pragma mark UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
		
	//if ([ISFeedback sharedInstance] == nil)
	//	[ISFeedback initSharedInstance:@"b1b94280-e1bf-4d7c-a657-72aa1d25e49e"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch(section) {
		case 0:
			return NSLocalizedString(@"Twitter - Latest News",@"titleForHeaderInSection case 0");
		case 1:
			return NSLocalizedString(@"Email",@"titleForHeaderInSection case 1");
/*            
		case 2:
			return @"Idescale Feedback";
 */
		case 2:
			return NSLocalizedString(@"Report bugs",@"titleForHeaderInSection case 2");
		default:
			return nil;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell * cell = [UITableViewCell getOrCreateCellForTableView:tableView];
	cell.imageView.image = nil;
	
	switch( indexPath.section ) {
		case 0:
			cell.textLabel.text = NSLocalizedString(@"http://twitter.com/onebusaway",@"case 0");
			break;
		case 1:
			cell.textLabel.text = NSLocalizedString(@"contact@onebusaway.org",@"cell.textLabel.text case 1");
			break;
/*
		case 2:
			cell.textLabel.text = @"Submit an Idea";
			cell.imageView.image = [UIImage imageNamed:@"Lightbulb.png"];
			break;
 */
		case 2:
			cell.textLabel.text = NSLocalizedString(@"OneBusAway Issue Tracker",@"cell.textLabel.text case 2");
			break;
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch(indexPath.section) {
		case 0: {
			NSString *url = [NSString stringWithString: NSLocalizedString(@"http://twitter.com/onebusaway",@"case 0")];
			[[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
			break;
			
		}
		case 1: {
			NSString *url = [NSString stringWithString: NSLocalizedString(@"mailto:contact@onebusaway.org",@"didSelectRowAtIndexPath case 1")];
			[[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
			break;		
		}
/*            
		case 2: {
			[[ISFeedback sharedInstance] pushOntoViewController:self];
			break;
		}
*/ 
		case 2: {
			NSString *url = [NSString stringWithString: NSLocalizedString(@"http://code.google.com/p/onebusaway-iphone/issues/list",@"didSelectRowAtIndexPath case 2")];
			[[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
			break;
		}
			
	}
}

#pragma mark OBANavigationTargetAware

- (OBANavigationTarget*) navigationTarget {
	return [OBANavigationTarget target:OBANavigationTargetTypeContactUs];
}

@end

