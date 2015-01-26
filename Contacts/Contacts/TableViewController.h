//
//  TableViewController.h
//  Contacts
//
//  Created by Callum Henshall on 26/01/15.
//  Copyright (c) 2015 Stupeflix. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TableViewController, TableCellViewController;

@protocol TableViewDataSource <NSObject>

//- (void)numberOfSectionsInTableVC:(TableViewController *)tableVC;

- (NSInteger)tableVC:(TableViewController *)tableVC numberOfRowsInSection:(NSInteger)section;

- (TableCellViewController *)tableVC:(TableViewController *)tableVC cellForIndexPath:(NSIndexPath *)indexPath;

- (void)tableVC:(TableViewController *)tableVC moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

@end

@protocol TableViewDelegate <NSObject>

- (NSInteger)tableVC:(TableViewController *)tableVC heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface TableViewController : UIViewController

@property (weak, nonatomic) id<TableViewDataSource> dataSource;
@property (weak, nonatomic) id<TableViewDelegate> delegate;

- (void)reloadData;

@end
