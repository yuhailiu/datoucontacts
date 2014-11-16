//
//  MasterViewController.h
//  datoucontacts
//
//  Created by houwenjie on 12-7-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
@class DetailViewController;

@interface MasterViewController : UITableViewController<UISearchDisplayDelegate,ABNewPersonViewControllerDelegate,ABPersonViewControllerDelegate>
{
    NSMutableDictionary *sectionDic;
    NSMutableDictionary *phoneDic;
    NSMutableDictionary *contactDic;
    NSMutableArray *filteredArray;
    //NSMutableArray *contactNames;
}
@property (strong, nonatomic) DetailViewController *detailViewController;
-(void)loadContacts;
@end
