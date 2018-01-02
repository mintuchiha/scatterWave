//
//  scatterWave.m
//  scatterWave
//
//  Created by Prakrit Shrestha on 3/6/13.
//  Copyright (c) 2013 Prakrit Shrestha. All rights reserved.
//

#import "scatterWave.h"

@implementation scatterWave

- (id)initWithFrame:(NSRect)frame
{
    
    dt_dx = 0.1;
    dx = 0.001;
    dt = dt_dx * SQR(dx);
    
    potentialScale = 0.0015;
    psi2Scale = 150;
    
    nSystem = 800;
    nStart = round(double(N_UNIVERSE - nSystem)/2.0);
    nStop  = round(double(N_UNIVERSE + nSystem)/2.0);
    xLeft = 0.47 * nSystem;
    xRight = 0.53 * nSystem;
    
    
    vLeft = 0.0;
    vCenter = 25000.0;
    vRight = 0.0;
    
    sigma_0 = 0.05;
    energy_0 = 25000.0;
    
    nowMinus = 0;
    now = 1;
    nowPlus = 2;
    
    lineWidth = 1.0;
    speed = 15000.0;
    
    
    return [super initWithFrame:frame];
}

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowResized:) name:NSWindowDidResizeNotification object:nil];
    [self windowResized:nil];
    
    [sigma0Text setDoubleValue:sigma_0];
    [x0Text setDoubleValue:x_0];
    [energy0Text setDoubleValue:energy_0];
    [lineWidthSlider setDoubleValue:lineWidth];
    [xLeftText setDoubleValue:xLeft];
    [xRightText setDoubleValue:xRight];
    [psiScaleSlider setDoubleValue:psi2Scale];
    [speedSlider setDoubleValue:speed];
    [self reset:self];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect scatterRect = [self bounds];
    [self setBoundsOrigin:NSMakePoint(0, -0.3 * scatterRect.size.height)];
    
    [[NSColor whiteColor]set];
    NSRectFill(dirtyRect);
    
    [[NSColor redColor]set];
    NSBezierPath *energyLine = [NSBezierPath bezierPath];
    {
        [energyLine setLineWidth:[lineWidthSlider doubleValue]];   //line width
        [energyLine moveToPoint:NSMakePoint(0, energy_0 * potentialScale)];
        [energyLine lineToPoint:NSMakePoint(nSystem, energy_0 * potentialScale)];
    }
    [energyLine stroke];
    
    [[NSColor blueColor]set];
    NSBezierPath *potentialLine = [NSBezierPath bezierPath];
    {
        [potentialLine moveToPoint:NSMakePoint(0, vLeft * potentialScale)];
        [potentialLine lineToPoint:NSMakePoint(xLeft , vLeft * potentialScale)];
        [potentialLine lineToPoint:NSMakePoint(xLeft, vCenter* potentialScale)];
        [potentialLine lineToPoint:NSMakePoint(xRight, vCenter* potentialScale)];
        [potentialLine lineToPoint:NSMakePoint(xRight, vRight* potentialScale)];
        [potentialLine lineToPoint:NSMakePoint(nSystem, vRight* potentialScale)];
        [potentialLine lineToPoint:NSMakePoint(nSystem, - dirtyRect.size.height)];
        [potentialLine lineToPoint:NSMakePoint(0, - dirtyRect.size.height)];
    }
    [potentialLine fill];
    
    
    [[NSColor colorWithCalibratedRed:0 green:1 blue:1 alpha:0.5]set];
    NSBezierPath *psiLine = [NSBezierPath bezierPath];
    {
        double psiMag2 = SQR(psi[nStart][now].re) + SQR(psi[nStart][now].im);
        [psiLine moveToPoint:NSMakePoint(0, psiMag2 * psi2Scale)];
        
        for (int n = 1; n < nSystem; n++)
        {
            double psiMag3 = SQR(psi[n + nStart][now].re) + SQR(psi[n + nStart][now].im);
            [psiLine lineToPoint:NSMakePoint(n, psiMag3 * psi2Scale)];
        }
        [psiLine lineToPoint:NSMakePoint(nSystem, -0.5 * dirtyRect.size.height)];
        [psiLine lineToPoint:NSMakePoint(0, -0.5 *  dirtyRect.size.height)];
        [psiLine lineToPoint:NSMakePoint(0, psi2Scale * psiMag2)];
        
    }
    [psiLine fill];
}

- (void)reset:(id)sender
{
    x_0 = [x0Text doubleValue];
    sigma_0 = [sigma0Text doubleValue];
    energy_0 = [energy0Text doubleValue];
    lineWidth = [lineWidthSlider doubleValue];
    xLeft = [xLeftText doubleValue];
    xRight = [xRightText doubleValue];
    psi2Scale = [psiScaleSlider doubleValue];
    speed = [speedSlider doubleValue];
    
    for (int n = 1; n < N_UNIVERSE - 2; n++)
    {
        
        double x = n * dx;
        
        complex psiNowMinus = [self initialWavePacketAtTime: -dt andSpace: x];
        complex  psiNow = [self initialWavePacketAtTime: 0 andSpace: x];
        complex psiNowPlus = [self initialWavePacketAtTime: dt andSpace: x];
        
        psi[n][nowMinus] = psiNowMinus;
        psi[n][now] = psiNow;
        psi[n][nowPlus] = psiNowPlus;
    }
    
    [self display];
}

-(complex)initialWavePacketAtTime:(double)t
                         andSpace:(double)x
{
    double p_0 = sqrt(energy_0);
    double phi = p_0 * x - energy_0 * t;
    double psiMag = exp(- SQR((x - x_0)) / (2.0 * SQR(sigma_0)));
    
    complex psi_ = {psiMag * cos(phi) , psiMag * sin(phi)};
    return psi_;
    
}

-(void)evolve:(NSTimer *)timer
{
    
    
    for (int n = 0; n <= N_UNIVERSE - 2; n++)
    {
        if (n < xLeft + nStart)
            potential[n] = vLeft;
        else
        {
            if (n < xRight + nStart)
                potential[n] = vCenter;
            else
                potential[n] = vRight;
        }
        
        complex lap =
        {
            2 * dt_dx * (psi[n-1][now].re - 2 * psi[n][now].re + psi[n+1][now].re),
            2 * dt_dx * (psi[n-1][now].im - 2 * psi[n][now].im + psi[n+1][now].im)
        };
        
        psi[n][nowPlus].re = psi[n][nowMinus].re - lap.im + 2 * dt * potential[n] * psi[n][now].im;
        
        psi[n][nowPlus].im = psi[n][nowMinus].im + lap.re - 2 * dt * potential[n] * psi[n][now].re;
    }
    
    int nowMinus_ = nowMinus;
    nowMinus = now;
    now = nowPlus;
    nowPlus = nowMinus_;
    
    if (SQR(psi[N_UNIVERSE-500][now].re) + SQR(psi[N_UNIVERSE-500][now].im)> .01 or SQR(psi[500][now].re) + SQR(psi[500][now].im)> .01)
        [self reset:self];
    else
        [self setNeedsDisplay:YES];
    
}

- (void)toggleEvolve:(id)sender
{
    speed = [speedSlider doubleValue];
    
    if  (not evolving)
    {
        evolving = YES;
        evolveTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 / (speed)
                                                       target: self
                                                     selector: @selector
                       (evolve:)
                                                     userInfo: nil
                                                      repeats: YES];
    }
    else // animating
    {
        evolving = NO;
        [evolveTimer invalidate];
    }
    [self display];
}

- (void)reDraw: (id)sender
{
    psi2Scale = [psiScaleSlider doubleValue];
    speed = [speedSlider doubleValue];
    
    [self display];
}
-(void)windowResized:(NSNotification *)notification
{
    NSRect scatterRect = [self bounds];
    [self setBoundsOrigin:NSMakePoint(0, - 0.3 * scatterRect.size.height)];
    
    nSystem = scatterRect.size.width;
    x_0 = 0.2 * nSystem * dx + nStart * dx;
    
}

@end
