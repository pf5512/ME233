//
//  BACController.m
//  Laser Tag
//
//  Created by Rob Balian on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BACController.h"
#import "SoftModemTerminalAppDelegate.h"
#import "FSKSerialGenerator.h"
#include <ctype.h>

#define NO_DEVICE 1

#define SIGNAL_VERIFY_PING 'a'
#define SIGNAL_VERIFY_ACK 'b'

#define SIGNAL_ON_PING 'c'
#define SIGNAL_ON_ACK 'd'

#define SIGNAL_OFF_PING 'e'
#define SIGNAL_OFF_ACK 'f'


#define TEST_CHAR 'z'

@implementation BACController

BACController *instance;


+ (BACController *)getInstance {
    if (instance == nil) {
        instance = [[BACController alloc] init];
    }
    return instance;
}


-(id)init {
    if ((self = [super init])) {
        readings = [[NSMutableArray alloc] init];
        currentReading = [[[NSString alloc] init] retain];
        
        //testing
        //[self setState:SENSOR_STATE_WARMING];
        
    }
    return self;
}

-(int)currentState {
    return sensorState;
}

-(void)sendTestChar {
    NSLog(@"sending test char: %c", TEST_CHAR);
    [self sendCode:TEST_CHAR];
}

-(void)warmTimerTick:(id)sender {
    if (secondsTillWarm >= 1) {
        secondsTillWarm-= .5;
        [delegate warmupSecondsLeft:secondsTillWarm];
    } else {
        if (warmTimer) [warmTimer invalidate];
        warmTimer = nil;
        [self setState:SENSOR_STATE_READY];
    }
}

-(void)setState:(int)state {
    sensorState = state;
    [delegate sensorStateChanged:state];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stateChanged" object:self];
}

-(void)startWarmupTimer {
    secondsTillWarm = SENSOR_WARMUP_SECONDS;
    warmTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(warmTimerTick:) userInfo:nil repeats:YES];
}

-(void)verifySensor {
    NSLog(@"Verifying sensor");
#ifdef NO_DEVICE
    [self setState:SENSOR_STATE_WARMING];
    [self startWarmupTimer];    
#else
    [self sendCode:SIGNAL_VERIFY_PING];
    [self setState:SENSOR_STATE_VERIFYING];
#endif
}

-(void)sensorUnplugged {
    [self setState:SENSOR_STATE_DISCONNECTED];
    if (warmTimer != nil && [warmTimer isValid]) [warmTimer invalidate]; 
    NSLog(@"Sensor unplugged");
}

/*-(void)startWithDelegate:(id)del {
    //set delegate for callbacks
    delegate = del;
    //if (sensorState >= SENSOR_STATE_OFF) {
    //    [self sendCode:SIGNAL_SENSOR_POWER_ON];
        //need some error checking to make sure it pings back
        
        secondsTillWarm = SENSOR_WARMUP_SECONDS;
        warmTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(warmTimerTick:) userInfo:nil repeats:YES];
    //}
    
    //if () {
        //turn on sensor
        //wait for ready
        /* WAYS TO CHECK FOR READY
         
        //[delegate sensorStateChanged:SENSOR_STATE_WARMING
         Temp sensor (iphone interprets temps and alcohol readings)
         Start 15-30 second timer
         Wait until values stabilize (this one might work)
         
         */
    
    //} else (if sensor isn't plugged in) {
        
        //[delegate sensorStateChanged:SENSOR_STATE_DISCONNECTED
        
    //}
    
    /*[NSTimer scheduledTimerWithTimeInterval:2.0f
     target:self
     selector:@selector(sendA:)
     userInfo:nil
     repeats:YES];
     *//*
#ifdef NO_DEVICE
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(testReceiveChar:) userInfo:nil repeats:YES];
#endif
}*/

-(void)setDelegate:(id)del {
    delegate = del;
}

//Char TX
- (void) receivedChar:(char)input {
    if (sensorState == SENSOR_STATE_VERIFYING && input == SIGNAL_VERIFY_ACK) {
        [self setState:SENSOR_STATE_OFF];
        [self sendCode:SIGNAL_ON_PING];
        NSLog(@"Verified, turning on");
    } else if (sensorState == SENSOR_STATE_OFF && input == SIGNAL_ON_ACK) {
        [self setState:SENSOR_STATE_WARMING];
        //now we wait...
        //Timer starts here
        NSLog(@"Sensor on, warming up");
    } else if (sensorState == SENSOR_STATE_READING || sensorState == SENSOR_STATE_READY) {
        [self storeReading:input];
        NSLog(@"%d", (uint8_t)input);
    }
}

- (void) sendCode:(char)code {
	NSLog(@"Sending Char: %c", code);
    for (int i = 0; i < 1; i++) {
		[[SoftModemTerminalAppDelegate getInstance].generator writeByte:code];
	}
	for (int i = 0; i < 1; i++) {
		[[SoftModemTerminalAppDelegate getInstance].generator writeByte:0x04];
	}
}

-(NSString *)storeReading:(char)c {
    NSString *returnVal = @"";    
    [readings addObject:[NSNumber numberWithInt:(uint8_t)c]];
    [delegate bacChanged:[self getCurrentBAC]];
    return returnVal;
}

-(double)getCurrentBAC {
    int total = 0;
    int numReadings = 0;
    for (int i=[readings count]-10; i<[readings count]; i++) {
        if (i < 0) continue;
        int reading = [(NSNumber *)[readings objectAtIndex:i] intValue];
        total += reading;
        numReadings +=1;
    }
    double average = (double)total / numReadings;
    double bac = (average-125)*.0011;
    
        
    return bac > 0 ? bac : 0;
    //return .4*(((double)(rand()%10))/10.0);
}






//TEST CODE for no device
-(void)testReceiveChar:(id)sender {
        char c = rand() % 155 + 100;
        [self receivedChar:c];
}

@end
