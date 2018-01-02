//
//  scatterWave.h
//  scatterWave
//
//  Created by Prakrit Shrestha on 3/6/13.
//  Copyright (c) 2013 Prakrit Shrestha. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#define SQR(a) ((a) * (a))

const int N_UNIVERSE = 2000;

struct complex
{
    double re;
    double im;
};

@interface scatterWave : NSView
{
    NSTimer *evolveTimer;
    
    bool evolving;
    
    double potential[N_UNIVERSE];
    
    complex psi[N_UNIVERSE][3];
    
    IBOutlet id x0Text, sigma0Text, energy0Text;
    double x_0, sigma_0, energy_0;

    IBOutlet id speedSlider, lineWidthSlider, psiScaleSlider;
    int speed;
    double lineWidth, psiScale;
    
    int nowMinus, now, nowPlus;
    
    int nStart, nStop, nSystem;
    
    double dt_dx, dx, dt, psi2Scale, potentialScale;
    
    double vLeft, vCenter, vRight;
    
    IBOutlet id xLeftText, xRightText;
    double xLeft, xRight;
}

-(IBAction)reset:(id)sender;
-(void)awakeFromNib;
-(complex)initialWavePacketAtTime:(double)t
                         andSpace:(double)x;

-(void)evolve: (NSTimer *)timer;
-(IBAction)toggleEvolve: (id)sender;
-(IBAction)reDraw:(id)sender;
-(void)windowResized: (NSNotification*) notification;

@end