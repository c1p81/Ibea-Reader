//
//  ViewController.h
//  Ibea Reader
//
//  Created by Luca Innocenti on 07/07/14.
//  Copyright (c) 2014 lucainnoc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"



@interface ViewController : UIViewController
{
        Reachability *internetReachableFoo;
    }

@property (weak, nonatomic) IBOutlet UIWebView *Vista;


@end
