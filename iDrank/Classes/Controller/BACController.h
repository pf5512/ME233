//
//  BACController.h
//  Laser Tag
//
//  Created by Rob Balian on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CharReceiver.h"
#import "BACEvent.h"
//#import "iDrankAppDelegate.h"

#define SENSOR_WARMUP_SECONDS 3
#define SENSOR_READ_SECONDS 1
#define SENSOR_CALCULATE_SECONDS 1

#define NO_IDRANK 1
#define USING_SIM 1

typedef enum {
    UNKNOWN = -1,
    DISCONNECTED = 0,
    OFF,
    ON_WARMING,
    ON_READY,
    ON_BLOWING_INTO
} SensorState;

@interface BACController : NSObject <CharReceiver>{
    NSMutableArray *readings;
    NSString *currentReading;
    int sensorState;
    id delegate;
    double secondsTillWarm;
    double currentBAC;
    NSTimer *warmTimer;
    NSTimer *readTimer;
    NSTimer *calculateTimer;
    NSTimer *verifyRetryTimer;
    NSTimer *noBlowTimer;

    
    
    NSManagedObjectContext *managedObjectContext;
    NSFetchedResultsController *fetchedResultsController;
    NSMutableArray *eventArray;
    

}

+(BACController *)sharedInstance;

//CoreData Methods
-(void)fetchRecords;
-(void)addBAC:(id)sender;

-(void)setDelegate:(id)del;
-(void)storeReading:(char)c;
-(double)getCurrentBAC;
-(void)receivedChar:(char)input;
-(void)sendCode:(char)code;
-(void)setState:(int)state;
-(void)startWarmupTimer;
-(void)sendTestChar;
-(void)verifySensor;
-(void)sensorUnplugged;
-(BOOL)detectSensorBlow;
-(void)measureAgain;
-(void)doneReading:(id)sender;
-(void)doneCalculating:(id)sender;
-(void)calculateBAC;

-(int)currentState;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;  
@property (nonatomic, retain) NSMutableArray *eventArray;

@end


@protocol BACControllerDelegate


-(void)warmupSecondsLeft:(double)seconds;
-(void)sensorStateChanged:(int)state;
-(void)bacChanged:(double)bac;
-(void)startWithDelegate:(id)del;
@end