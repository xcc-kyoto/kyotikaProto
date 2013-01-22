//
//  KMTreasureHunterAnnotationView.h
//  KyotoMap
//
//  Created by kunii on 2013/01/20.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface KMTreasureHunterAnnotationView : MKAnnotationView
- (void)startAnimation;
- (void)stopAnimation;
- (void)direction:(CGPoint)vector;
@end

@interface KMTreasureHunterAnnotation : MKPointAnnotation

@end
