//
//  TableCellViewController.h
//  Contacts
//
//  Created by Callum Henshall on 26/01/15.
//  Copyright (c) 2015 Stupeflix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableCellViewController : UIViewController

@property (weak, nonatomic) NSLayoutConstraint *yPositionLayoutConstraint;
@property (weak, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIView *moveView;

@end
