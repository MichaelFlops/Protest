//
//  FirstViewController.m
//  MCTest
//
//  Created by John Rogers on 4/5/14.
//  Copyright (c) 2014 John Rogers. All rights reserved.
//
//
//  FirstViewController.m
//  MCDemo
//

#import "FirstViewController.h"
#import "AppDelegate.h"

@interface FirstViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;

-(void)sendMyMessage;
-(void)didReceiveDataWithNotification:(NSNotification *)notification;

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    _txtMessage.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITextField Delegate method implementation

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self sendMyMessage];
    return YES;
}


#pragma mark - IBAction method implementation

- (IBAction)sendMessage:(id)sender {
    [self sendMyMessage];
}

- (IBAction)cancelMessage:(id)sender {
    [_txtMessage resignFirstResponder];
}


#pragma mark - Private method implementation

-(void)sendMyMessage{
    NSData *dataToSend = [_txtMessage.text dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *allPeers = _appDelegate.manager.session.connectedPeers;
    NSError *error;
    if (_appDelegate.manager.leader == YES) {
        NSData *signedMessage = [_appDelegate.key sign:dataToSend];
        NSArray *array = [[NSArray alloc] initWithObjects:_appDelegate.manager.publicKey, dataToSend, signedMessage, nil];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
        [_appDelegate.manager.session sendData:data
                                       toPeers:allPeers
                                      withMode:MCSessionSendDataReliable
                                         error:&error];
    } else {
        NSArray *array = [[NSArray alloc] initWithObjects:_appDelegate.manager.publicKey, dataToSend, nil];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
        [_appDelegate.manager.session sendData:data
                                       toPeers:allPeers
                                      withMode:MCSessionSendDataReliable
                                         error:&error];
    }
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    [_tvChat setText:[_tvChat.text stringByAppendingString:[NSString stringWithFormat:@"I wrote:\n%@\n\n", _txtMessage.text]]];
    [_txtMessage setText:@""];
    [_txtMessage resignFirstResponder];
}

- (void)appendMessage:(NSArray*)sender {
    NSLog(@"appending message");
    MCPeerID *peerID = [sender objectAtIndex:1];
    NSString *peerDisplayName = peerID.displayName;
    NSData *receivedText = [sender objectAtIndex:0];
    
    [_tvChat performSelectorOnMainThread:@selector(setText:) withObject:[_tvChat.text stringByAppendingString:[NSString stringWithFormat:@"%@ wrote:\n%@\n\n", peerDisplayName, receivedText]] waitUntilDone:NO];
    
}

@end
