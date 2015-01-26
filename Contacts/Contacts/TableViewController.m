//
//  TableViewController.m
//  Contacts
//
//  Created by Callum Henshall on 26/01/15.
//  Copyright (c) 2015 Stupeflix. All rights reserved.
//

#import "TableViewController.h"

#import "TableCellViewController.h"

@interface TableViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) UIView *containerView;

@property (strong, nonatomic) NSMutableArray *cells;

@property (weak, nonatomic) NSLayoutConstraint *heightLayoutConstraint;

@property (weak, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (weak, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

@property (weak, nonatomic) TableCellViewController *editingCell;

@end

@implementation TableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
}

- (void)reloadData
{
    [self.containerView removeFromSuperview];
    self.containerView = nil;
    self.cells = nil;
    
    [self loadData];
}

- (void)loadData
{
    if (self.dataSource && self.delegate)
    {
        NSInteger section = 0;
        NSInteger rows = [self.dataSource tableVC:self numberOfRowsInSection:section];
        
        NSInteger cellHeight = [self.delegate tableVC:self heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        
        UIView *containerView = [[UIView alloc] init];
        
        self.containerView = containerView;
        
        containerView.translatesAutoresizingMaskIntoConstraints = NO;
        
        
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        
        [self.containerView addGestureRecognizer:longPressGestureRecognizer];
        self.longPressGestureRecognizer = longPressGestureRecognizer;
        
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        
        [self.containerView addGestureRecognizer:panGestureRecognizer];
        self.panGestureRecognizer = panGestureRecognizer;
        panGestureRecognizer.enabled = NO;
        
        
        NSDictionary *views = NSDictionaryOfVariableBindings(containerView);
        
        [self.scrollView addSubview:containerView];
        [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[containerView]|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:views]];
        [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[containerView]|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:views]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:containerView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.f
                                                               constant:0.f]];
        
        NSLayoutConstraint *heightLayoutConstraint = [NSLayoutConstraint constraintWithItem:containerView
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:nil
                                                                                  attribute:0
                                                                                 multiplier:1.f
                                                                                   constant:rows * cellHeight];
        self.heightLayoutConstraint = heightLayoutConstraint;
        [self.scrollView addConstraint:heightLayoutConstraint];
        
        self.cells = [[NSMutableArray alloc] init];
        
        for (NSInteger i = 0; i < rows; ++i)
        {
            TableCellViewController *cell = [self.dataSource tableVC:self cellForIndexPath:[NSIndexPath indexPathForRow:i inSection:section]];
            
            if (cell)
            {
                self.cells[i] = cell;
                
                cell.view.translatesAutoresizingMaskIntoConstraints = NO;
                
                UIView *cellView = cell.view;
                
                NSDictionary *views = NSDictionaryOfVariableBindings(cellView);
                
                [self.containerView addSubview:cell.view];
                [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[cellView]|"
                                                                                        options:0
                                                                                        metrics:nil
                                                                                          views:views]];
                [cell.view addConstraint:[NSLayoutConstraint constraintWithItem:cell.view
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:0
                                                                     multiplier:1.f
                                                                       constant:cellHeight]];
                
                NSLayoutConstraint *yPositionLayoutConstraint = [NSLayoutConstraint constraintWithItem:cell.view
                                                                                             attribute:NSLayoutAttributeTop
                                                                                             relatedBy:NSLayoutRelationEqual
                                                                                                toItem:self.containerView
                                                                                             attribute:NSLayoutAttributeTop
                                                                                            multiplier:1.f
                                                                                              constant:i * cellHeight];
                [self.containerView addConstraint:yPositionLayoutConstraint];

                cell.yPositionLayoutConstraint = yPositionLayoutConstraint;
                
                cell.moveView.hidden = YES;
            }
            else
            {
                // Abort
            }
        }
    }
}

- (void)move:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        TableCellViewController *cell = [self cellForPanGestureRecognizer:panGestureRecognizer];
        
        if (cell)
        {
            self.editingCell = cell;
            
            cell.view.backgroundColor = [UIColor lightGrayColor];
            
            [self.containerView bringSubviewToFront:cell.view];
            
            CGPoint point = [panGestureRecognizer locationInView:self.containerView];
            
            NSLog(@"Pan ; y : %lf", point.y);
        }
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint point = [panGestureRecognizer locationInView:self.containerView];
        
        self.editingCell.yPositionLayoutConstraint.constant = point.y;
        
        NSLog(@"Pan ; y : %lf", point.y);
        
        CGFloat cellHeight = [(TableCellViewController *)self.cells[0] view].frame.size.height;

        NSInteger i = [self.cells indexOfObject:self.editingCell];
        CGFloat normalCenterY = i * cellHeight + cellHeight / 2;
        CGFloat currentCenterY = self.editingCell.view.center.y;
        
        if (currentCenterY < normalCenterY
            && i - 1 >= 0) // moving up
        {
            TableCellViewController *cell = self.cells[i - 1];
            
            if (ABS(currentCenterY - normalCenterY) >= cellHeight / 2)
            {
                [self.dataSource tableVC:self
                      moveRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]
                             toIndexPath:[NSIndexPath indexPathForRow:i - 1 inSection:0]];

                [self.cells exchangeObjectAtIndex:i withObjectAtIndex:i - 1];
                
                [self updateCells];
            }
        }
        else if (currentCenterY > normalCenterY
                 && i + 1 < self.cells.count) // moving down
        {
            TableCellViewController *cell = self.cells[i + 1];

            if (ABS(currentCenterY - normalCenterY) >= cellHeight / 2)
            {
                [self.dataSource tableVC:self
                      moveRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]
                             toIndexPath:[NSIndexPath indexPathForRow:i + 1 inSection:0]];
                
                [self.cells exchangeObjectAtIndex:i withObjectAtIndex:i + 1];
                
                [self updateCells];
            }
        }
        
        
        [self updateCells];
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        self.editingCell.view.backgroundColor = [UIColor whiteColor];
        self.editingCell = nil;
        
        [self updateCells];
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        self.editing = !self.editing;
    }
}

- (TableCellViewController *)cellForPanGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
{
    CGPoint point = [panGestureRecognizer locationInView:self.containerView];

    NSInteger i = point.y / [(TableCellViewController *)self.cells[0] view].frame.size.height;
    
    if (i >= 0 && i < self.cells.count)
    {
        return self.cells[i];
    }
    return nil;
}

- (void)setEditing:(BOOL)editing
{
    [super setEditing:editing];
    
    self.scrollView.panGestureRecognizer.enabled = !editing;
    
    self.panGestureRecognizer.enabled = editing;
    
    for (TableCellViewController *cell in self.cells)
    {
        cell.moveView.hidden = !editing;
    }
}

- (void)updateCells
{
    CGFloat cellHeight = [(TableCellViewController *)self.cells[0] view].frame.size.height;
    
    for (NSInteger i = 0; i < self.cells.count; ++i)
    {
        TableCellViewController *cell = self.cells[i];
        
        if (cell != self.editingCell)
        {
            cell.yPositionLayoutConstraint.constant = cellHeight * i;
        }
    }
}

@end
