//
//  ContactManagedObject.h
//  Contacts
//
//  Created by Callum Henshall on 26/01/15.
//  Copyright (c) 2015 Stupeflix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ContactManagedObject : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * job;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * position;

@end
