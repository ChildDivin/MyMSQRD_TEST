//
//  AppDelegate.h
//  test
//
//  Created by Tops on 11/24/16.
//  Copyright © 2016 Self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeVC.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) HomeVC *home;
@property (strong, nonatomic) UINavigationController *nav;

@end

