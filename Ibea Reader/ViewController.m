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

int oldminor;  // qui viene registrato l'ultimo valore del minor registrato
int lingua;    // qui viene registrata la lingua in uso
int maggiore;  // qui viene registrato il valore del major del beacon osservato
int minore;    // qui viene registrato il valore del minor del beacon osservato
NSString *ur = @"http://www.nearbee.it/beacons/jsandroid3.php?uuid=";


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) NSMutableArray *beacons;
@property (nonatomic, strong) NSArray *paintings;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) CBCentralManager* manager;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bt_it;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bt_in;


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // crea la toolbar
    //[self createToolbar];
    
    //setta la lingua iniziale come italiano
    //1 = italiano
    //2 = inglese
    //3 = francese
    lingua = 1;
    maggiore =0;
    minore = 1;
    
    _Vista.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _Vista.autoresizesSubviews = YES;
    _Vista.scalesPageToFit = YES;
    
    //initializzia l'indicatore di attesa per la webview
    
    UIActivityIndicatorView *actInd=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    actInd.color=[UIColor blackColor];
    [actInd setCenter:self.view.center];
    self.activityIndicator=actInd;
    [self.Vista addSubview:self.activityIndicator];
    //[self.Vista loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.youtube.com/watch?v=xUAD0gguFXc"]]];

    //controlla se c'e' connessione di rete
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    //se non c'e' connessione mostra il messaggio d'errore
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
    
    //inizializza il controllo beacon
    CBCentralManager *manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];

    //mostra la home page (locale) per la webview
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html"];
    [_Vista loadRequest:[NSURLRequest requestWithURL:url]];
    
}

// questo gestisce l'apparire e lo scomparire della wait whell sulla webview
#pragma mark - UIWebViewDelegate Protocol Methods
- (void)webViewDidStartLoad:(UIWebView *)Vista{
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)Vista{
    [self.activityIndicator stopAnimating];
}

//crea la toolbar
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

//le azioni legate alla toolbar
/*-(IBAction)italiano:(UIButton *)sender {
    [self.view makeToast:@"Italiano"
                duration:1.2
                position:@"center"
     ];
    lingua = 1;
    [self chiama];
}


-(IBAction)francese:(UIButton *)sender {
    [self.view makeToast:@"Francais"
                duration:1.2
                position:@"center"
     ];
    lingua = 2;
    [self chiama];
}

-(IBAction)inglese:(UIButton *)sender {
    [self.view makeToast:@"English"
                duration:1.2
                position:@"center"
     ];
    lingua = 3;
    [self chiama];
    }

 */

- (IBAction)Italiano:(id)item {
    [self.view makeToast:@"Impostato in Italiano"
                duration:1.2
                position:@"center"
     ];
    lingua = 1;
    
    [(UIBarButtonItem *)item setTitle:@"√Italiano"];
    _bt_in.title = @"Inglese";
    //[(UIBarButtonItem *)items obje  setTitle:@"√Italiano"];
    //UIBarButtonItem *in = [_toolbar.items objectAtIndex:2];
    //[in.setTitle: @"rr"];
    //self.in.setTitle = @"Inglese";
    
    [self chiama];

}


- (IBAction)Inglese:(id)item {
    [self.view makeToast:@"Set in English"
                duration:1.2
                position:@"center"
     ];
    lingua = 2;
    [(UIBarButtonItem *)item setTitle:@"√English"];
    _bt_it.title = @"Italiano";
    [self chiama];
}


- (void) chiama {
    NSString *l1 = [NSString stringWithFormat:@"%d",lingua];
    NSString *l2 = [NSString stringWithFormat:@"%d",maggiore];
    NSString *l3 = [NSString stringWithFormat:@"%d",minore];
    NSString *unione = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", ur,@"4506F9C7-00F9-C206-C12C-C2F9C702D3C3", @"&major=",l2,@"&minor=",l3,@"&lingua=",l1];
    NSLog([NSString stringWithFormat:@"%@", unione]);
    
    // e fa puntare la webview al server
    [self.Vista loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:unione]]];
    }

//gestione del manager del beacon
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
    oldminor = 0;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_locationManager stopRangingBeaconsInRegion:_beaconRegion];
}

//funzione principale per la gestione dei beacons
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if (beacons.count) {
        
        CLBeacon *closestBeacon;
        
        for (CLBeacon *beacon in beacons) {
            NSLog([NSString stringWithFormat:@"%@", beacon.major]);
            NSLog([NSString stringWithFormat:@"%@", beacon.minor]);
            NSLog([NSString stringWithFormat:@"%f", beacon.accuracy]);
            
            // qui decide quale e' il beacon piu' vicino
            if (beacon.accuracy > 0) {
                closestBeacon = beacon;
                break;
            }
        }
        
        
        if (closestBeacon.accuracy > 20)
            {
            // beacon lontano
                NSURL *url = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html"];
                [_Vista loadRequest:[NSURLRequest requestWithURL:url]];
            
            }
        else
            {
        
                // se e' stato visto un beacon con minor differente dal precedente avvia la richiesta verso il server
                if (oldminor != closestBeacon.minor.integerValue)
                    {
                        maggiore = closestBeacon.major.integerValue;
                        minore = closestBeacon.minor.integerValue;
                        NSString *ll = [NSString stringWithFormat:@"%d",lingua];
                        NSString *unione = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", ur,@"4506F9C7-00F9-C206-C12C-C2F9C702D3C3", @"&major=",closestBeacon.major,@"&minor=",closestBeacon.minor,@"&lingua=",ll];
            
                        NSLog([NSString stringWithFormat:@"%@", unione]);
                        // e fa puntare la webview al server
            
                        [_Vista loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:unione]]];
                        oldminor = closestBeacon.minor.integerValue;
                    }
            }
        
    }
    
}


@end
