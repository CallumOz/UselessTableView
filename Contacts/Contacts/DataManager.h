//
//  DataManager.h
//  Contacts
//
//  Created by Callum Henshall on 26/01/15.
//  Copyright (c) 2015 Stupeflix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ContactManagedObject;

@interface DataManager : NSObject

+ (instancetype)sharedManager;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (NSArray *)loadContacts;

- (void)moveContact:(ContactManagedObject *)contact toPosition:(NSInteger)position;

- (void)setData:(NSArray *)contacts;

@end
