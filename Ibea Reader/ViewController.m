//
//  ViewController.m
//  Ibea Reader
//
//  Created by Luca Innocenti on 07/07/14.
//  Copyright (c) 2014 lucainnoc. All rights reserved.
//

#import "ViewController.h"
#import "Reachability.h"
#import "UIView+Toast.h"
#import <CoreBluetooth/CoreBluetooth.h>





#define ESTIMOTE_PROXIMITY_UUID [[NSUUID alloc] initWithUUIDString:@"4506F9C7-00F9-C206-C12C-C2F9C702D3C3"]

int oldminor;

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *beacons;
@property (nonatomic, strong) NSArray *paintings;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) CBCentralManager* manager;



@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"There IS NO internet connection");
        /*[self.view makeToast:@"No internet connection. Please Enable Connection and restart the app"
                    duration:3.0
                    position:@"center"
                    ];*/
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                        message:@"Please Enable Connection and restart the app."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        
    } else {
        NSLog(@"There IS internet connection");
        _beacons = [[NSMutableArray alloc] init];
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                           identifier:@"lucainnoc.Ibeareader"];

    }
    
    CBCentralManager *manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];

    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html"];
    [_Vista loadRequest:[NSURLRequest requestWithURL:url]];
    
 
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (central.state != CBCentralManagerStatePoweredOn)
    {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Bluetooth"
                                                            message:@"Please Enable Connection and restart the app."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        }
    }

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error : %@",error);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [_locationManager startRangingBeaconsInRegion:_beaconRegion];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_locationManager stopRangingBeaconsInRegion:_beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if (beacons.count) {
        
        CLBeacon *closestBeacon;
        
        for (CLBeacon *beacon in beacons) {
            //NSLog([NSString stringWithFormat:@"%@", beacon.major]);
            //NSLog([NSString stringWithFormat:@"%@", beacon.minor]);
            NSLog([NSString stringWithFormat:@"%f", beacon.accuracy]);
            
            if (beacon.accuracy > 0) {
                closestBeacon = beacon;
                
                break;
            }
        }
        
     
        
        
        
        if (oldminor != closestBeacon.minor.integerValue)
        {
            NSString *ur = @"http://150.217.73.79/luca/jsandroid3.php?uuid=";
            NSString *unione = [NSString stringWithFormat:@"%@%@%@%@%@%@", ur,@"4506F9C7-00F9-C206-C12C-C2F9C702D3C3", @"&major=",closestBeacon.major,@"&minor=",closestBeacon.minor];
            NSLog([NSString stringWithFormat:@"%@", unione]);

            [_Vista loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:unione]]];
            oldminor = closestBeacon.minor.integerValue;
        }
        
    }
    
}


@end
