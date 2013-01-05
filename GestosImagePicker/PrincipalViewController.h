//
//  PrincipalViewController.h
//  GestosImagePicker
//
//  Created by Rafael Brigagão Paulino on 18/09/12.
//  Copyright (c) 2012 rafapaulino.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImagemGiraEstica.h"
#import <QuartzCore/QuartzCore.h>

@interface PrincipalViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIGestureRecognizerDelegate>


-(IBAction)abreAlbum:(id)sender;
-(IBAction)abreCamera:(id)sender;

-(void)rotacionaImagem:(UIRotationGestureRecognizer*)gestoRotacao;
-(void)esticaImagem:(UIPinchGestureRecognizer*)gestoZoom;
-(void)arrastaImagem:(UIPanGestureRecognizer*)gestoPan;
-(void)removeImagem:(UILongPressGestureRecognizer*)gestoToqueLongo;

@end
