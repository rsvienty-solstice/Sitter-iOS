//
//  ViewController.m
//  SmartOfficeBeaconReceiver
//
//  Created by Chelsea Chanay on 11/21/13.
//  Copyright (c) 2013 Chelsea Chanay. All rights reserved.
//

#import "ViewController.h"

static NSString *BEACON_UUID = @"DA0925D8-6581-4B8E-997A-01FA0536EE62";
static NSString *BEACON_REGION_ID = @"com.solstice-mobile.smart-office";

static NSString *SERVICE_UUID = @"3B1CEB1B-59E8-4E1B-837E-D47CEDE4B230";

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    // [self initRegion];
    [self startAdvertising];
}

- (void)initRegion
{
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:BEACON_UUID];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:BEACON_REGION_ID];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    self.beaconFoundLabel.text = @"No";
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    CLBeacon *beacon = [[CLBeacon alloc] init];
    beacon = [beacons lastObject];
    
    self.beaconFoundLabel.text = @"Yes";
    self.proximityUUIDLabel.text = beacon.proximityUUID.UUIDString;
    self.majorLabel.text = [NSString stringWithFormat:@"%@", beacon.major];
    self.minorLabel.text = [NSString stringWithFormat:@"%@", beacon.minor];
    self.accuracyLabel.text = [NSString stringWithFormat:@"%f", beacon.accuracy];
    if (beacon.proximity == CLProximityUnknown) {
        self.distanceLabel.text = @"Unknown Proximity";
    } else if (beacon.proximity == CLProximityImmediate)
    {
        self.distanceLabel.text = @"Immediate";
        
        // Switch to a CB peripheral - start advertising to central manager
        self.peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
        [self startAdvertising];
    }
    else if (beacon.proximity == CLProximityNear) {
        self.distanceLabel.text = @"Near";
    } else if (beacon.proximity == CLProximityFar) {
        self.distanceLabel.text = @"Far";
    }
    self.rssiLabel.text = [NSString stringWithFormat:@"%li", (long)beacon.rssi];
}

-(void)startAdvertising
{
    self.peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
    
    // CBMutableService *service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:@"538B505F-1642-4550-BE01-CDAA75E897A9"] primary:YES];
    
    CBMutableService *service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:SERVICE_UUID] primary:YES];

    /*  Characteristic for service
    NSString *stringValue = self.textView.text;
    CBMutableCharacteristic *emailCharacteristic = [[CBMutableCharacteristic alloc]
                                                    initWithType:[CBUUID UUIDWithString:@"DFE26734-D2D2-463C-97A9-581176021F24"]
                                                    properties:CBCharacteristicPropertyRead
                                                    value:[stringValue dataUsingEncoding:NSUTF8StringEncoding]
                                                    permissions:CBAttributePermissionsReadable];
    [service setCharacteristics:@[emailCharacteristic]];
     */
    
    [self.peripheralManager addService:service];
    
    [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey :@[service.UUID] }];
}


-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch (peripheral.state)
    {
        case CBCentralManagerStatePoweredOff:
            NSLog(@"CoreBluetooth BLE hardware is powered off");
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
            // [self startAdvertising];
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"CoreBluetooth BLE hardware is resetting");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"CoreBluetooth BLE state is unauthorized");
            break;
        case CBCentralManagerStateUnknown:
            NSLog(@"CoreBluetooth BLE state is unknown");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
            break;
        default:
            break;
    }
}


@end
