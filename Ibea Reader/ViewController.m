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
int lingua;

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
    [self createToolbar];
    lingua = 1;
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


- (void)createToolbar {
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                  target:nil action:nil];
    UIBarButtonItem *italiano = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Italiano" style:UIBarButtonItemStyleBordered
                                    target:self action:@selector(italiano:)];
    UIBarButtonItem *inglese = [[UIBarButtonItem alloc]
                                    initWithTitle:@"English" style:UIBarButtonItemStyleDone
                                target:self action:@selector(inglese:)];
    
    UIBarButtonItem *francese= [[UIBarButtonItem alloc]
                                initWithTitle:@"Francais" style:UIBarButtonItemStyleDone
                                target:self action:@selector(francese:)];
    
    NSArray *toolbarItems = [NSArray arrayWithObjects:
                             italiano,spaceItem, inglese,spaceItem, francese, nil];
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:
                          CGRectMake(0, 366+54, 320, 50)];
    [toolbar setBarStyle:UIBarStyleBlackOpaque];
    [self.view addSubview:toolbar];
    [toolbar setItems:toolbarItems];}

-(IBAction)italiano:(UIButton *)sender {
    [self.view makeToast:@"Italiano"
                duration:1.2
                position:@"center"
     ];
    lingua = 1;
    
}


-(IBAction)francese:(UIButton *)sender {
    [self.view makeToast:@"Francais"
                duration:1.2
                position:@"center"
     ];
    lingua = 2;
    
}
-(IBAction)inglese:(UIButton *)sender {
    [self.view makeToast:@"English"
                duration:1.2
                position:@"center"
     ];
    lingua = 3;
    
}



- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (central.state != CBCentralManagerStateUnsupported)
    {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No BLE"
                                                            message:@"This device does not support Bluetooth Low Energy"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        }
    if (central.state != CBCentralManagerStateUnauthorized)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No BLE"
                                                        message:@"This app is not authorized to use Bluetooth Low Energy"
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
        
     
        
        NSString *ll = [NSString stringWithFormat:@"%d",lingua];
        
        if (oldminor != closestBeacon.minor.integerValue)
        {
            NSString *ur = @"http://150.217.73.79/luca/jsandroid3.php?uuid=";
            NSString *unione = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", ur,@"4506F9C7-00F9-C206-C12C-C2F9C702D3C3", @"&major=",closestBeacon.major,@"&minor=",closestBeacon.minor,@"&lingua=",ll];
            NSLog([NSString stringWithFormat:@"%@", unione]);

            [_Vista loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:unione]]];
            oldminor = closestBeacon.minor.integerValue;
        }
        
    }
    
}


@end
