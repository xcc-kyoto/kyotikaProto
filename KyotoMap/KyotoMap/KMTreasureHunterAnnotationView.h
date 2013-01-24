//
//  KMTreasureHunterAnnotationView.h
//  KyotoMap
//
//  Created by kunii on 2013/01/20.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface KMTreasureHunterAnnotation : MKPointAnnotation
@end

@interface KMTreasureHunterAnnotationView : MKAnnotationView
- (void)startAnimation;
- (void)stopAnimation;
- (void)direction:(CGPoint)vector;
@property (assign) KMTreasureHunterAnnotation* hunterAnnotation;
@end

