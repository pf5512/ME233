//
//  ProfileSelectionViewController.h
//  iDrank
//
//  Created by Rob Balian on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileSelectionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITextField *textBox;
    IBOutlet UIButton *enterButton;
    IBOutlet UITableView *namestv;
    
    IBOutlet UITableView *placestv;
    NSArray *places;
}

-(IBAction)done:(id)sender;
@end
