//
//  PrincipalViewController.m
//  GestosImagePicker
//
//  Created by Rafael Brigagão Paulino on 18/09/12.
//  Copyright (c) 2012 rafapaulino.com. All rights reserved.
//

#import "PrincipalViewController.h"

@interface PrincipalViewController ()
{
    CGPoint pontoDoToque;
}

@end

@implementation PrincipalViewController

//eotodo acionado por um gesto tap dedois toques com um dedo
//a instancia do gesto e passada via parametro - sender
-(IBAction)abreAlbum:(id)sender
{
   //vamos pecisar captar o gesto efetuado para saber em qual ponto ele ocorreu
    UITapGestureRecognizer *gestoTap = sender;
    
    //guardamos o local onde o ponto ocorreu
    pontoDoToque = [gestoTap locationInView:self.view];
    
    //view controlller especifico para acessar a biblioteca de fotos salvas  no iphone e acessar a camera
    UIImagePickerController *imagePicker = [[UIImagePickerController  alloc] init];
    
    //devemos falar qual vai ser a fonte das fotos
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    //falando para o imagepicker que somos o delegate dele para que ele nos envie os eventos que ocorrem dentro dele
    imagePicker.delegate = self;
    
    //apresentar o viewcontroleer na tela
    [self presentModalViewController:imagePicker animated:YES];
}

//metodo acionado quando o usuario termina de selecionar ou captar a foto
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //a foto ORIGINAL selecionada vem pelo parametro info na chave do dicionario UIImagePickerCONtrollerOriginalImage
    //a foto EDITADA selecionada vem pelo parametro info na chave do dicionario UIImagePickerCONtrollerEditImage
    ImagemGiraEstica *imgView = [[ImagemGiraEstica alloc] init];
    imgView.frame = CGRectMake(pontoDoToque.x - 60, pontoDoToque.y - 60, 120, 120);
    
    [imgView setContentMode:UIViewContentModeScaleAspectFit];
    
    //verificar se a foto em questao deve ser pega na chave original ou editada
    if (picker.allowsEditing)
    {
        //setando no imageView a foto selecionada no imagePicker
        imgView.image = [info objectForKey:UIImagePickerControllerEditedImage];
    }
    else
    {
        //setando no imageView a foto selecionada no imagePicker
        imgView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    //adicionando gestos no imageview
    //para cada imageView adicionado na tela iremos add os gestos rotacao, pinça, toque longo e pan
    
    //para que o mageView consiga identificar os gestos, precisamos seta:
    imgView.userInteractionEnabled = YES;
    imgView.angulo = 0;
    imgView.escala = 1;
    
    //======================================== ROTACAO
    UIRotationGestureRecognizer *rotacao = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotacionaImagem:)];

    //quando ocorrer dois gestos ao mesmo tempo ele vai acionar o delegate para pergurtar o que ele deve fazer
    rotacao.delegate = self;
    
    //adicionar esse gesto na view
    [imgView addGestureRecognizer:rotacao];
    
    //======================================== ZOOM
    UIPinchGestureRecognizer *zoom = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(esticaImagem:)];
    
    //quando ocorrer dois gestos ao mesmo tempo ele vai acionar o delegate para pergurtar o que ele deve fazer
    zoom.delegate = self;
    
    //adicionar esse gesto na view
    [imgView addGestureRecognizer:zoom];
    
    
    //======================================== ARRASTAR
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(arrastaImagem:)];
    
    //quando ocorrer dois gestos ao mesmo tempo ele vai acionar o delegate para pergurtar o que ele deve fazer
    pan.delegate = self;
    
    //adicionar esse gesto na view
    [imgView addGestureRecognizer:pan];
    
    
    //adicionado a imagem na tela
    [self.view addSubview:imgView];
    
    //fazer o imagePicker sumir
    [self dismissModalViewControllerAnimated:YES];
    
    
    //======================================== TOQUE LONGO
    UILongPressGestureRecognizer *toqueLongo = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(removeImagem:)];
    
    toqueLongo.minimumPressDuration = 2; //distancia do toque
    toqueLongo.allowableMovement = 20; //duracao do toque
    
    //quando ocorrer dois gestos ao mesmo tempo ele vai acionar o delegate para pergurtar o que ele deve fazer
    toqueLongo.delegate = self;

    
    //adicionar esse gesto na view
    [imgView addGestureRecognizer:toqueLongo];
    
    
    //adicionado a imagem na tela
    [self.view addSubview:imgView];
    
    //fazer o imagePicker sumir
    [self dismissModalViewControllerAnimated:YES];
}


-(IBAction)abreCamera:(id)sender
{
    //vamos pecisar captar o gesto efetuado para saber em qual ponto ele ocorreu
    UITapGestureRecognizer *gestoTap = sender;
    
    //guardamos o local onde o ponto ocorreu
    pontoDoToque = [gestoTap locationInView:self.view];
    
    //verificar se o aparelho tem camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        imagePicker.delegate = self;
        
        //vamos permitir que o usuario edite a imagem antes de utilizar no app
        imagePicker.allowsEditing = YES;
        
        [self presentModalViewController:imagePicker animated:YES];
    }
    else
    {
        NSLog(@"Voce nao tem camera");
    }
}


-(void)rotacionaImagem:(UIRotationGestureRecognizer*)gestoRotacao
{
    NSLog(@"Ocorreu rotacao - %f",gestoRotacao.rotation);
    //captar o image view que foi acionado
    ImagemGiraEstica *vitima = (ImagemGiraEstica*)gestoRotacao.view;
    
    //verificar se e a primeira vez que o metodo e chamad
    if (gestoRotacao.state == UIGestureRecognizerStateBegan)
    {
        gestoRotacao.rotation = vitima.angulo;
    }
    
    //criar uma estrutura do tipo transform para inidicar a escala atual no exato momento antes de rotacionar
    CGAffineTransform transformEscala = CGAffineTransformMakeScale(vitima.escala, vitima.escala);
    
    //vitima.transform = CGAffineTransformMakeRotation(gestoRotacao.rotation);
    vitima.transform = CGAffineTransformRotate(transformEscala,gestoRotacao.rotation);
    
    //no fim do metodo guardamos o valor da ultima rotacao
    vitima.angulo = gestoRotacao.rotation;
}

-(void)esticaImagem:(UIPinchGestureRecognizer*)gestoZoom
{
    NSLog(@"Ocorreu zoom.");
    
    ImagemGiraEstica *vitima = (ImagemGiraEstica*)gestoZoom.view;
    
    if (gestoZoom.state == UIGestureRecognizerStateBegan) {
        gestoZoom.scale = vitima.escala;
    }
    
    //criar
    CGAffineTransform transformRotacao = CGAffineTransformMakeRotation(vitima.angulo);
    
    vitima.transform = CGAffineTransformScale(transformRotacao, gestoZoom.scale, gestoZoom.scale);
    
    //vitima.transform = CGAffineTransformMakeScale(gestoZoom.scale,gestoZoom.scale);
    
    vitima.escala = gestoZoom.scale;
}

-(void)arrastaImagem:(UIPanGestureRecognizer*)gestoPan
{
    NSLog(@"arrastou img.");
    ImagemGiraEstica *vitima = (ImagemGiraEstica*)gestoPan.view;

    CGPoint localDoPonto = [gestoPan translationInView:self.view]; //delta
    
    NSLog(@"X: %f - Y: %f",localDoPonto.x,localDoPonto.y);
    
    vitima.center = CGPointMake(vitima.center.x + localDoPonto.x,vitima.center.y + localDoPonto.y);
    
    [gestoPan setTranslation:CGPointMake(0, 0) inView:self.view];
}

-(void)removeImagem:(UILongPressGestureRecognizer*)gestoToqueLongo
{
   NSLog(@"remove img.");
    //este metodo sewra chamado constantemente enquanto o toque longo estiver acontecendo
    //portanto devemos permitir que ele execute a remocao da imagem apenas na primeira chamada do metodo
    if (gestoToqueLongo.state == UIGestureRecognizerStateBegan)
    {
        //remove a img
        [gestoToqueLongo.view removeFromSuperview];
    }
}


//delegate que cuida quando dois gestos ocorrem ao mesmo tempo
//estamos recebendo pelo parametro estes dois gestos (gestureRecognizer e otherGestureRecognizer) onde iremos verificar se amos os gestos podem ocorrem ao mesmo tempo retornar yes ou no
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

//captura a view
-(UIImage*)capturarTela:(UIView*)view
{
    //capturar toda area da view que recebemos como parametro
    UIGraphicsBeginImageContext(view.frame.size);
    //criando uma referencia ao contexto da captura que inicamos na linha anterior
    CGContextRef contexto = UIGraphicsGetCurrentContext();
    
    //renderizando a imagem (elaborando uma imagem) a partir da captura do contexto
    [view.layer renderInContext:contexto];
    
    //criamos umauiimage a partir da renderizacao efetuada
    UIImage *imagem = UIGraphicsGetImageFromCurrentImageContext();
    
    //finalizamos o processo
    UIGraphicsEndImageContext();
    
    //retornamos a imagem criada
    return imagem;
}

//tira um print da tela e salva a imagem
-(void)tirarPrintTela:(UISwipeGestureRecognizer*)gesto
{
    //criar uma imagem nova com a captura
    UIImage *imagemCapturada = [self capturarTela:self.view];
    
    //salvar essa imagem no álbum de  fotos do aparelho
    UIImageWriteToSavedPhotosAlbum(imagemCapturada, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

//salva a imagem
-(void)image:(UIImage*)image didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo
{
    if (error == nil)
    {
        [[[UIAlertView alloc] initWithTitle:@"Sucesso" message:@"Imagem salva com sucesso" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Ops!" message:@"A imagem nao foi salva" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];  
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //adicionar um recon hecdor de gestos para capturar o swipe e tirar um print da tela
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tirarPrintTela:)];
    swipe.numberOfTouchesRequired = 1;
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:swipe];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
