//
//  HomeVC.m
//  MyMSQRD
//
//  Created by Tops on 11/24/16.
//
//

#import "HomeVC.h"
#include "ofApp.h"
@interface HomeVC ()

@end

@implementation HomeVC
{
    ofApp * mainApp;
}
- (instancetype)init
{
    self = [super init];
    if ( self ) {
        
        //self.title = kTHFacePickerViewControllerTitle;
    }
    return self;
}
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self ) {
        ofiOSWindowSettings settings;
        settings.enableRetina = false; // enables retina resolution if the device supports it.
        settings.enableDepth = false; // enables depth buffer for 3d drawing.
        settings.enableAntiAliasing = false; // enables anti-aliasing which smooths out graphics on the screen.
        settings.numOfAntiAliasingSamples = 0; // number of samples used for anti-aliasing.
        settings.enableHardwareOrientation = false; // enables native view orientation.
        settings.enableHardwareOrientationAnimation = false; // enables native orientation changes to be animated.
        settings.glesVersion = OFXIOS_RENDERER_ES1; // type of renderer to use, ES1, ES2, ES3
        settings.windowMode = OF_FULLSCREEN;
        ofCreateWindow(settings);
        mainApp = (new ofApp);
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    mainApp->setupCam(50,50);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
  
}
@end
