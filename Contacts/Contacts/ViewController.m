//
//  ViewController.m
//  Contacts
//
//  Created by Callum Henshall on 26/01/15.
//  Copyright (c) 2015 Stupeflix. All rights reserved.
//

#import "ViewController.h"

#import "DataManager.h"
#import "ContactManagedObject.h"

#import "TableViewController.h"
#import "TableCellViewController.h"

@interface ViewController () <NSURLConnectionDataDelegate, TableViewDataSource, TableViewDelegate>

@property (strong, nonatomic) NSArray *contacts;

@property (weak, nonatomic) TableViewController *tableVC;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[TableViewController class]])
    {
        TableViewController *tableVC = segue.destinationViewController;
        
        tableVC.dataSource = self;
        tableVC.delegate = self;
        
        self.tableVC = tableVC;
    }
}

- (void)loadData
{
    self.contacts = [[DataManager sharedManager] loadContacts];
    
    if (self.contacts == nil)
    {
#error Change this url
        NSURL *url = [NSURL URLWithString:@"http://uri.to.json.com"];
        
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        [connection start];
    }
    else
    {
        NSLog(@"Contacts : %@", self.contacts);

        [self.tableVC reloadData];
    }
}

/*----------------------------------------------------------------------------*/
#pragma mark - NSURLConnectionDelegate
/*----------------------------------------------------------------------------*/

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
    
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (data)
    {
        NSError *error = nil;
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        if (dict && [dict isKindOfClass:[NSDictionary class]])
        {
            NSArray *array = dict[@"data"];
            
            if ([array isKindOfClass:[NSArray class]] && array.count > 0)
            {
                [[DataManager sharedManager] setData:array];
                
                self.contacts = [[DataManager sharedManager] loadContacts];
                
                NSLog(@"Contacts : %@", self.contacts);
                
                [self.tableVC reloadData];
            }
        }
    }
}

/*----------------------------------------------------------------------------*/
#pragma mark - TableViewDataSource
/*----------------------------------------------------------------------------*/

- (NSInteger)tableVC:(TableViewController *)tableVC numberOfRowsInSection:(NSInteger)section
{
    return self.contacts.count;
}

- (TableCellViewController *)tableVC:(TableViewController *)tableVC cellForIndexPath:(NSIndexPath *)indexPath
{
    TableCellViewController *cell = [self.storyboard instantiateViewControllerWithIdentifier:@"TableCellVC"];
        
    UIView *view = cell.view;
    
    ContactManagedObject *contact = self.contacts[indexPath.row];
    
    cell.titleLabel.text = contact.name;
    
    
    return cell;
}

- (void)tableVC:(TableViewController *)tableVC moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    ContactManagedObject *contact = self.contacts[fromIndexPath.row];
    
    [[DataManager sharedManager] moveContact:contact toPosition:toIndexPath.row];
    
    self.contacts = [[DataManager sharedManager] loadContacts];
    
    [[DataManager sharedManager] saveContext];
}

/*----------------------------------------------------------------------------*/
#pragma mark - TableViewDelegate
/*----------------------------------------------------------------------------*/

- (NSInteger)tableVC:(TableViewController *)tableVC heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

@end
