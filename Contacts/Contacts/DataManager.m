//
//  DataManager.m
//  Contacts
//
//  Created by Callum Henshall on 26/01/15.
//  Copyright (c) 2015 Stupeflix. All rights reserved.
//

#import "DataManager.h"

#import "ContactManagedObject.h"

@interface DataManager ()

@property (strong, nonatomic) NSArray *contacts;

@end

@implementation DataManager

+ (instancetype)sharedManager
{
    static DataManager *manager;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
    {
        manager = [[self alloc] init];
    });
    
    return manager;
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.stupeflix.Contacts" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Contacts" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Contacts.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSArray *)loadContacts
{
    if (self.contacts)
    {
        return self.contacts;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
    
    NSError *error = nil;
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (results.count > 0)
    {
        self.contacts = [self sortContacts:results];
    }
    return self.contacts;
}

- (void)moveContact:(ContactManagedObject *)contact toPosition:(NSInteger)position
{
    if (contact.position.integerValue != position && position < self.contacts.count)
    {
        for (ContactManagedObject *contactManagedObject in self.contacts)
        {
            if (contact.position.integerValue > position)
            {
                if (contactManagedObject.position.integerValue >= position
                    && contactManagedObject.position.integerValue < contact.position.integerValue)
                {
                    contactManagedObject.position = @(contactManagedObject.position.integerValue + 1);
                }
            }
            else if (contact.position.integerValue < position)
            {
                if (contactManagedObject.position.integerValue <= position
                    && contactManagedObject.position.integerValue > contact.position.integerValue)
                {
                    contactManagedObject.position = @(contactManagedObject.position.integerValue - 1);
                }
            }
        }
        contact.position = @(position);
        
        self.contacts = [self sortContacts:self.contacts];
    }
}

- (NSArray *)sortContacts:(NSArray *)contacts
{
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:contacts];
    
    [mutableArray sortUsingComparator:^NSComparisonResult(ContactManagedObject *obj1, ContactManagedObject *obj2)
     {
         return obj1.position.integerValue - obj2.position.integerValue;
     }];
    
    return [[NSArray alloc] initWithArray:mutableArray];
}

- (void)setData:(NSArray *)contacts
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Contact"
                                                  inManagedObjectContext:self.managedObjectContext];
    
    for (NSInteger i = 0; i < contacts.count; ++i)
    {
        NSDictionary *dict = contacts[i];
        
        ContactManagedObject *contact = [[ContactManagedObject alloc] initWithEntity:entityDesc
                                                      insertIntoManagedObjectContext:self.managedObjectContext];
        
        contact.email = dict[@"email"];
        contact.name = dict[@"name"];
        contact.job = dict[@"job"];
        contact.position = @(i);
    }
    
    [self saveContext];
}

@end
