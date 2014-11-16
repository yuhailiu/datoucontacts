//
//  MasterViewController.m
//  datoucontacts
//
//  Created by houwenjie on 12-7-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//sectionDic

#import "MasterViewController.h"
#import "GroupViewController.h"
#import "DetailViewController.h"
#import "pinyin.h"
#import "POAPinyin.h"
#import "PersonalDetailTableViewController.h"
@implementation MasterViewController

@synthesize detailViewController = _detailViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title =@"通讯录";
        filteredArray=[[NSMutableArray alloc] init];
        sectionDic= [[NSMutableDictionary alloc] init];
        phoneDic=[[NSMutableDictionary alloc] init];
        contactDic=[[NSMutableDictionary alloc] init];
        
    }
    return self;
}
							
- (void)dealloc
{
    [super dealloc];
    [_detailViewController release];
    [filteredArray         release];
    [sectionDic            release];
    [phoneDic              release];
    [contactDic            release];

    
}
// 导入通讯录
-(void)loadContacts
{
    [sectionDic removeAllObjects];
    [phoneDic   removeAllObjects];
    [contactDic removeAllObjects];
    for (int i = 0; i < 26; i++) [sectionDic setObject:[NSMutableArray array] forKey:[NSString stringWithFormat:@"%c",'A'+i]];
    [sectionDic setObject:[NSMutableArray array] forKey:[NSString stringWithFormat:@"%c",'#']];
    
    ABAddressBookRef myAddressBook =ABAddressBookCreate();
    
    CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(myAddressBook);
    CFMutableArrayRef mresults=CFArrayCreateMutableCopy(kCFAllocatorDefault,
                                                        CFArrayGetCount(results),
                                                        results);
    //将结果按照拼音排序，将结果放入mresults数组中
    CFArraySortValues(mresults,
                      CFRangeMake(0, CFArrayGetCount(results)),
                      (CFComparatorFunction) ABPersonComparePeopleByName,
                      (void*) ABPersonGetSortOrdering());
    //遍历所有联系人
    for (int k=0;k<CFArrayGetCount(mresults);k++) {
        ABRecordRef record=CFArrayGetValueAtIndex(mresults,k);
        NSString *personname = (NSString *)ABRecordCopyCompositeName(record);
        ABMultiValueRef phone = ABRecordCopyValue(record, kABPersonPhoneProperty);
        ABRecordID recordID=ABRecordGetRecordID(record);
        for (int k = 0; k<ABMultiValueGetCount(phone); k++)
        {
            NSString * personPhone = (NSString*)ABMultiValueCopyValueAtIndex(phone, k);
            NSRange range=NSMakeRange(0,3);
            NSString *str=[personPhone substringWithRange:range];
            if ([str isEqualToString:@"+86"]) {
                personPhone=[personPhone substringFromIndex:3];
            }
            
            [phoneDic setObject:record forKey:[NSString stringWithFormat:@"%@%d",personPhone,recordID]];
            
            
        }
        char first=pinyinFirstLetter([personname characterAtIndex:0]);
        NSString *sectionName;
        if ((first>='a'&&first<='z')||(first>='A'&&first<='Z')) {
            if([self searchResult:personname searchText:@"曾"])
                sectionName = @"Z";
            else if([self searchResult:personname searchText:@"解"])
                sectionName = @"X";
            else if([self searchResult:personname searchText:@"仇"])
                sectionName = @"Q";
            else if([self searchResult:personname searchText:@"朴"])
                sectionName = @"P";
            else if([self searchResult:personname searchText:@"查"])
                sectionName = @"Z";
            else if([self searchResult:personname searchText:@"能"])
                sectionName = @"N";
            else if([self searchResult:personname searchText:@"乐"])
                sectionName = @"Y";
            else if([self searchResult:personname searchText:@"单"])
                sectionName = @"S";
            else
            sectionName = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([personname characterAtIndex:0])] uppercaseString];
        }
        else {
            sectionName=[[NSString stringWithFormat:@"%c",'#'] uppercaseString];
        }
        
        [[sectionDic objectForKey:sectionName] addObject:record];
        [contactDic setObject:record forKey:[NSNumber numberWithInt:recordID]];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self loadContacts];
    
    UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)] autorelease];
    UIBarButtonItem *groupButton =[[[UIBarButtonItem alloc] initWithTitle:@"群组" style:UIBarButtonItemStyleBordered target:self action:@selector(showGroupView)] autorelease];
    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.leftBarButtonItem=groupButton;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![self.searchDisplayController isActive]) {
        [self loadContacts];
        [self.tableView reloadData];
    }
    [self.searchDisplayController.searchResultsTableView reloadData];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
//显示群组
-(void)showGroupView
{
    GroupViewController *groupView=[[GroupViewController alloc] initWithNibName:@"GroupViewController" bundle:nil];
    [self.navigationController pushViewController:groupView animated:YES];
    [groupView release];
}
//新建联系人
- (void)insertNewObject:(id)sender
{
    ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
	picker.newPersonViewDelegate = self;
	
	UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:picker];
	[self presentModalViewController:navigation animated:YES];
	[picker release];
	[navigation release];
}
#pragma mark ABNewPersonViewControllerDelegate methods
// Dismisses the new-person view controller. 
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark ABPersonViewControllerDelegate methods
// Does not allow users to perform default actions such as dialing a phone number, when they select a contact property.
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person 
					property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
	return NO;
}


#pragma mark - Table View
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if ([tableView isEqual:self.tableView]) {
    NSMutableArray *indices = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
    for (int i = 0; i < 27; i++) 
            [indices addObject:[[ALPHA substringFromIndex:i] substringToIndex:1]];
    //[indices addObject:@"\ue057"]; // <-- using emoji
    return indices;
    }
    return nil;
}
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (title == UITableViewIndexSearch) 
	{
		[self.tableView scrollRectToVisible:self.searchDisplayController.searchBar.frame animated:NO];
		return -1;
	}

   return  [ALPHA rangeOfString:title].location;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tableView isEqual:self.tableView]) {
        return 27;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableView]) {
    NSString *key=[NSString stringWithFormat:@"%c",[ALPHA characterAtIndex:section]];
   return  [[sectionDic objectForKey:key] count];
    }
   return [filteredArray count];
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        return nil;
    }
    NSString *key=[NSString stringWithFormat:@"%c",[ALPHA characterAtIndex:section]];
    if ([[sectionDic objectForKey:key] count]!=0) {
        return key;
    }
    return nil;
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (![tableView isEqual:self.tableView]) {
        //搜索结果
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
        NSDictionary *person=[filteredArray objectAtIndex:indexPath.row];
        cell.textLabel.text=[person objectForKey:@"name"];
        cell.detailTextLabel.text=[person objectForKey:@"phone"];
    }
    else {

        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        NSString *key=[NSString stringWithFormat:@"%c",[ALPHA characterAtIndex:indexPath.section]];
        NSMutableArray *persons=[sectionDic objectForKey:key];
        ABRecordRef record=[persons objectAtIndex:indexPath.row];
        cell.textLabel.text=(NSString *)ABRecordCopyCompositeName(record);
//        NSData *imageData=(NSData*)ABPersonCopyImageData(record);
//       
//        [cell.imageView setImage:[UIImage imageWithData:imageData]];
//         cell.imageView.contentMode=UIViewContentModeScaleToFill;
    }
    
    return cell;

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    ABRecordRef person;
    if (![tableView isEqual:self.tableView]) {
        NSMutableDictionary *record=[filteredArray objectAtIndex:indexPath.row];
        NSString *recordID=[record objectForKey:@"ID"];
        person=[contactDic objectForKey:recordID];
    }
    else {
        NSString *key=[NSString stringWithFormat:@"%c",[ALPHA characterAtIndex:indexPath.section]];
        NSMutableArray *persons=[sectionDic objectForKey:key];
        person=[persons objectAtIndex:indexPath.row];
    }
    
    //added by yuhai
    
    PersonalDetailTableViewController * controller = [[[PersonalDetailTableViewController alloc]init] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
    
//    ABPersonViewController *picker = [[[ABPersonViewController alloc] init] autorelease];
//    
//    picker.personViewDelegate = self;
//    picker.displayedPerson = person;
//    picker.allowsActions=YES;
//    // Allow users to edit the person’s information
//    picker.allowsEditing = YES;
//    [self.navigationController pushViewController:picker animated:YES];
    
}
#pragma UISearchDisplayDelegate
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self performSelectorOnMainThread:@selector(searchWithString:) withObject:searchString waitUntilDone:YES];

    return YES;
}
-(void)searchWithString:(NSString *)searchString
{
    [filteredArray removeAllObjects];
    NSString * regex        = @"(^[0-9]+$)";
    NSPredicate * pred      = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([searchString length]!=0) {
        if ([pred evaluateWithObject:searchString]) { //判断是否是数字
            NSArray *phones=[phoneDic allKeys];
            for (NSString *phone in phones) {
                if ([self searchResult:phone searchText:searchString]) {
                    ABRecordRef person=[phoneDic objectForKey:phone];
                    ABRecordID recordID=ABRecordGetRecordID(person);
                    NSString *ff=[NSString stringWithFormat:@"%d",recordID];
                    
                    NSString *name=(NSString *)ABRecordCopyCompositeName(person);
                    NSMutableDictionary *record=[[NSMutableDictionary alloc] init];
                    [record setObject:name forKey:@"name"];
                    [record setObject:[phone substringToIndex:(phone.length-ff.length)] forKey:@"phone"];
                    [record setObject:[NSNumber numberWithInt:recordID] forKey:@"ID"];
                    [filteredArray addObject:record];
                    [record release];
                    NSLog(@"%@",filteredArray);
                }
            }
        }
        else {
            //搜索对应分类下的数组
            NSString *sectionName = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([searchString characterAtIndex:0])] uppercaseString];
            NSArray *array=[sectionDic objectForKey:sectionName];
            for (int j=0;j<[array count];j++) {
                ABRecordRef person=[array objectAtIndex:j];
                NSString *name=(NSString *)ABRecordCopyCompositeName(person);
                if ([self searchResult:name searchText:searchString]) { //先按输入的内容搜索
                    ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);   
                    NSString * personPhone = (NSString*)ABMultiValueCopyValueAtIndex(phone, 0);
                    ABRecordID recordID=ABRecordGetRecordID(person);
                    NSMutableDictionary *record=[[NSMutableDictionary alloc] init];
                    [record setObject:name forKey:@"name"];
                    [record setObject:personPhone forKey:@"phone"];
                    [record setObject:[NSNumber numberWithInt:recordID] forKey:@"ID"];
                    [filteredArray addObject:record];
                    [record release];
                }
                else { //按拼音搜索
                    NSString *string = @"";
                    NSString *firststring=@"";
                    for (int i = 0; i < [name length]; i++)
                    {
                        if([string length] < 1)
                            string = [NSString stringWithFormat:@"%@",
                                      [POAPinyin quickConvert:[name substringWithRange:NSMakeRange(i,1)]]];
                        else
                            string = [NSString stringWithFormat:@"%@%@",string,
                                      [POAPinyin quickConvert:[name substringWithRange:NSMakeRange(i,1)]]];
                        if([firststring length] < 1)
                            firststring = [NSString stringWithFormat:@"%c",
                                           pinyinFirstLetter([name characterAtIndex:i])];
                        else
                        {
                            if ([name characterAtIndex:i]!=' ') {
                                firststring = [NSString stringWithFormat:@"%@%c",firststring,
                                               pinyinFirstLetter([name characterAtIndex:i])];
                            }
                            
                        }
                    }
                    if ([self searchResult:string searchText:searchString]
                        ||[self searchResult:firststring searchText:searchString])
                    {
                        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);   
                        NSString * personPhone = (NSString*)ABMultiValueCopyValueAtIndex(phone, 0);
                        ABRecordID recordID=ABRecordGetRecordID(person);
                        NSMutableDictionary *record=[[NSMutableDictionary alloc] init];
                        [record setObject:name forKey:@"name"];
                        [record setObject:personPhone forKey:@"phone"];
                        [record setObject:[NSNumber numberWithInt:recordID] forKey:@"ID"];
                        [filteredArray addObject:record];
                        [record release];
                        
                    }
                    
                    
                }
            }
        } 
    }   
}
-(void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    
}
-(BOOL)searchResult:(NSString *)contactName searchText:(NSString *)searchT{
	NSComparisonResult result = [contactName compare:searchT options:NSCaseInsensitiveSearch
											   range:NSMakeRange(0, searchT.length)];
	if (result == NSOrderedSame)
		return YES;
	else
		return NO;
}

@end
