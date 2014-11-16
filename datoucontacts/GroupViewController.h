//
//  GroupViewController.h
//  datoucontacts
//
//  Created by houwenjie on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupViewController : UITableViewController
{
    NSMutableArray *_groups;
    NSMutableDictionary *_persons;
    NSMutableDictionary *addpersons; //选择的联系人
    BOOL *flag;

}
@property (strong, nonatomic) NSMutableArray       *groups;
@property (strong, nonatomic) NSMutableDictionary  *persons;
@end
