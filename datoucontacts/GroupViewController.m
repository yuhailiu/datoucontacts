//
//  GroupViewController.m
//  datoucontacts
//
//  Created by houwenjie on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GroupViewController.h"
#import <AddressBook/AddressBook.h>
@interface GroupViewController ()

@end

@implementation GroupViewController
@synthesize groups=_groups,persons=_persons;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)loadData
{
    ABAddressBookRef myAddressBook = ABAddressBookCreate();
    CFArrayRef allSources = ABAddressBookCopyArrayOfAllSources(myAddressBook);
	
	for (CFIndex i = 0; i < CFArrayGetCount(allSources); i++)
    {
		ABRecordRef aSource = CFArrayGetValueAtIndex(allSources,i);
		
		// Fetch all groups included in the current source
		CFArrayRef result = ABAddressBookCopyArrayOfAllGroupsInSource (myAddressBook, aSource);
		// The app displays a source if and only if it contains groups
		if (CFArrayGetCount(result) > 0)
		{
            
			NSMutableArray *groups = [[NSMutableArray alloc] initWithArray:(NSArray *)result];
            NSMutableDictionary *allrecords=[[NSMutableDictionary alloc] init];
            for (int j=0; j<[groups count];j++) {
                ABRecordRef group=[groups objectAtIndex:j];
                CFStringRef name = ABRecordCopyCompositeName(group);
                
                CFArrayRef persons=ABGroupCopyArrayOfAllMembers(group);
                NSMutableArray *members = [[NSMutableArray alloc] init];
                if (persons!=nil) {
                    for (int k=0;k<CFArrayGetCount(persons);k++) {
                        ABRecordRef record=CFArrayGetValueAtIndex(persons,k);
                        ABRecordID  personID=ABRecordGetRecordID(record);
                        CFStringRef personname = ABRecordCopyCompositeName(record);
                        [members addObject:(NSString *)personname];
                        NSLog(@"%@-%d",personname,personID);
                    }
                    [allrecords setObject:members forKey:(NSString *)name];
                    NSLog(@"%@",name);
                    [members release];
                }
                
            }
            self.groups=[NSMutableArray arrayWithArray:[allrecords allKeys]];
            self.persons=allrecords;
            // [allrecords release];
			//[groups release];
		}
		
		CFRelease(result);
    }
	
	CFRelease(allSources);
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadData];
	// Do any additional setup after loading the view, typically from a nib.
    self.title=@"群组";
    addpersons=[[NSMutableDictionary alloc] init];
    flag = (BOOL*)malloc(sizeof(BOOL*));
	memset(flag, NO, sizeof(flag)*[self.groups count]);
    UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showSelects)] autorelease];
    self.navigationItem.rightBarButtonItem = addButton;
}
-(void)showSelects
{
    NSLog(@"%@",addpersons);
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.rightBarButtonItem = nil;
    [self setEditing:YES animated:YES];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.groups count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberOfRowsInSection:section];
    //    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSMutableArray *members = [self.persons objectForKey:[self.groups objectAtIndex:indexPath.section]];
    cell.textLabel.text=[members objectAtIndex:indexPath.row];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 40;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	return 40;
	
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.tag = section;
    //	NSDictionary *source = [self.dic objectForKey:[NSString stringWithFormat:@"%i",section+1]];
    //	NSArray *array = [source objectForKey:@"titles"];
	[button setBackgroundImage:[UIImage imageNamed:@"bgd1.png"] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(headerClicked:) forControlEvents:UIControlEventTouchUpInside];
	UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
	
	if(flag[section])
		image.image = [UIImage imageNamed:@"normal.png"];
	else 
		image.image = [UIImage imageNamed:@"pressed.png"];
	[UIView beginAnimations:@"animatecomeout" context:NULL];
	[UIView setAnimationDuration:.25f];
	if(!flag[section])
		image.transform=CGAffineTransformMakeRotation(-1.58);
	else
		image.transform=CGAffineTransformMakeRotation(1.58);
	[UIView commitAnimations];
	[button addSubview:image];
	[image release];
	
	CGFloat size = 16;
	CGFloat width = 100;	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, width+200, 30)];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
	label.font = [UIFont boldSystemFontOfSize:size];
	label.text = [NSString stringWithFormat:@"%@",[self.groups objectAtIndex:section]];
	[button addSubview:label];
	[label release];
	//[array release];
    //[source release];
	return button;
	
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *members = [self.persons objectForKey:[self.groups objectAtIndex:indexPath.section]];
    [addpersons setObject:indexPath forKey:[members objectAtIndex:indexPath.row]];
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *members = [self.persons objectForKey:[self.groups objectAtIndex:indexPath.section]];
    [addpersons removeObjectForKey:[members objectAtIndex:indexPath.row]]; 
}
////////////////////////////////////

-(void)headerClicked:(id)sender
{
	int sectionIndex = ((UIButton*)sender).tag;
	flag[sectionIndex] = !flag[sectionIndex];
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
	
}


- (int)numberOfRowsInSection:(NSInteger)section
{
	
	if (flag[section]) {
        NSArray *array = [self.persons objectForKey:[self.groups objectAtIndex:section]];
        return [array count];
        
    }
	else {
		return 0;
	}
}


@end
