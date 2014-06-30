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

#import "ChatViewController.h"
#import "AppDelegate.h"

@interface ChatViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;

-(void)sendMyMessage;
-(void)didReceiveDataWithNotification:(NSNotification *)notification;

@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _appDelegate.chatViewController = self;

    
    _chatSource = [NSMutableArray array];
    _availAvatars = [NSMutableArray array];
    for (int i=1; i<=40; i++) {
        [_availAvatars addObject:[NSNumber numberWithInt:i]];
    }
    _avatarForUser = [[NSMutableDictionary alloc] init];
    _protestName.hidden = YES;
    _chatTable.hidden = YES;
    _protestName.textColor = [UIColor whiteColor];
    _protestName.font = [UIFont fontWithName:@"Gotham" size:18];
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_spinner setColor:[UIColor grayColor]];
    [_spinner setCenter:CGPointMake(160, 240)]; // I do this because I'm in landscape mode
    [self.view addSubview:_spinner]; // spinner is not visible until started
    [_spinner startAnimating];
    
    [self registerForKeyboardNotifications];
    
    [self addMessage:[[Message alloc] initWithMessage:@"heyooo sherriff!" uID:@"0" fromLeader:NO]];
    [self addMessage:[[Message alloc] initWithMessage:@"sherriff I am sorry but fuck your kind!" uID:@"1" fromLeader:NO]];
    [self addMessage:[[Message alloc] initWithMessage:@"It honestly doesn't matter because I don't care about you guys anyway. So get out." uID:@"0" fromLeader:NO]];
    [self addMessage:[[Message alloc] initWithMessage:@"get out!!!!" uID:@"1" fromLeader:NO]];
    [self addMessage:[[Message alloc] initWithMessage:@"I will not!!!" uID:@"0" fromLeader:NO]];
    [self addMessage:[[Message alloc] initWithMessage:@"Fine then get in at least." uID:@"1" fromLeader:NO]];
    [self addMessage:[[Message alloc] initWithMessage:@"I also won't do that!" uID:@"0" fromLeader:NO]];
    [self addMessage:[[Message alloc] initWithMessage:@"Then what will you do?!" uID:@"1" fromLeader:NO]];
    [self addMessage:[[Message alloc] initWithMessage:@"your mother ha" uID:@"0" fromLeader:NO]];
    [self addMessage:[[Message alloc] initWithMessage:@"the cops are coming!" uID:@"0" fromLeader:NO]];
    [self addMessage:[[Message alloc] initWithMessage:@"listen to me plz" uID:@"0" fromLeader:NO]];
    
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f,
                                                                     self.view.bounds.size.height - 40.0f,
                                                                     self.view.bounds.size.width,
                                                                     40.0f)];
    _toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_toolBar];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f,
                                                                           6.0f,
                                                                           _toolBar.bounds.size.width - 20.0f - 68.0f,
                                                                           30.0f)];
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    _textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_toolBar addSubview:_textField];
    
    _sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_sendButton setTitle:@"Send" forState:UIControlStateNormal];
    _sendButton.frame = CGRectMake(_toolBar.bounds.size.width - 68.0f,
                                  6.0f,
                                  58.0f,
                                  29.0f);
    [_sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_sendButton setEnabled:NO];
    [_sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:_sendButton];
    
    
    self.view.keyboardTriggerOffset = _toolBar.bounds.size.height;
    
    __weak ChatViewController *self_ = self; //to avoid retain cycle
    [self.view addKeyboardPanningWithFrameBasedActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        CGRect toolBarFrame = self_.toolBar.frame;
        toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
        self_.toolBar.frame = toolBarFrame;
    } constraintBasedActionHandler:nil];
    
    [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    NSIndexPath* ipath = [NSIndexPath indexPathForRow:[_chatTable numberOfRowsInSection:0]-1 inSection:0];
    [_chatTable scrollToRowAtIndexPath:ipath atScrollPosition: UITableViewScrollPositionTop animated:YES];
}

-(void)textFieldDidChange :(UITextField *)theTextField{
    if ([theTextField.text length] > 0) {
        [_sendButton setTitleColor:[UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [_sendButton setEnabled:YES];
    } else {
        [_sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_sendButton setEnabled:NO];
    }
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}


- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    NSDictionary *userInfo = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSTimeInterval animationDuration;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _chatTable.contentInset = contentInsets;
    _chatTable.scrollIndicatorInsets = contentInsets;
    NSIndexPath* ipath = [NSIndexPath indexPathForRow:[_chatTable numberOfRowsInSection:0]-1 inSection:0];
    [_chatTable scrollToRowAtIndexPath:ipath atScrollPosition: UITableViewScrollPositionTop animated:YES];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _chatTable.contentInset = contentInsets;
    _chatTable .scrollIndicatorInsets = contentInsets;
}


- (void)chatLoaded:(NSString*)protestName {
    _protestName.hidden = NO;
    _chatTable.hidden = NO;
    _protestName.text = protestName;
    [_spinner removeFromSuperview];
}

- (void)addMessage:(Message*)message {
    NSLog(@"recieved message! %@", message);
    if ([_avatarForUser objectForKey:message.uId] == nil) {
        uint32_t rnd = arc4random_uniform([_availAvatars count]);
        NSNumber *avatarNum = [_availAvatars objectAtIndex:rnd];
        [_availAvatars removeObject:avatarNum];
        [_avatarForUser setValue:avatarNum forKey:message.uId];
    }
    [_chatSource addObject:message];
    [_chatTable reloadData];
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

- (IBAction)exitButtonPressed:(id)sender {
    [_appDelegate.viewController reset];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)sendButtonPressed:(id)sender {
    NSLog(@"send button pressed");
    Message *myMessage = [[Message alloc] initWithMessage:_textField.text uID:_appDelegate.manager.userID fromLeader:NO];
    myMessage.timer = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                       target:self
                                                     selector:@selector(messageNotReturned)
                                                     userInfo:nil
                                                      repeats:NO];
    [_textField setText:@""];
    [_chatSource addObject:myMessage];
    [_chatTable reloadData];
    [_appDelegate.manager sendMessage:myMessage];
    [self.view endEditing:YES];
}

- (void)messageNotReturned {
    NSLog(@"Message not returned yet");
}


#pragma mark - Private method implementation


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_chatSource count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = [_chatSource[indexPath.row] message];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    textLabel.text = text;
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:@"Futura Std" size:12], NSFontAttributeName,
                                          nil];
    
    CGRect frame = [textLabel.text boundingRectWithSize:CGSizeMake(220, 2000.0)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:attributesDictionary
                                                context:nil];
    return frame.size.height + 30;
}

- (UITableViewCell*)othersChatBubble:(NSString*)text cell:(UITableViewCell*)cell avatarID:(int)id {
    UIImage *bubbleImage = [[UIImage imageNamed:@"white_text_bubble.png"]
                           resizableImageWithCapInsets:UIEdgeInsetsMake(20, 6, 6, 0)];
    cell.backgroundColor = [UIColor clearColor];
    UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:bubbleImage];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    textLabel.font = [UIFont fontWithName:@"Futura Std" size:12];
    textLabel.textColor = [UIColor colorWithRed:0.482 green:0.482 blue:0.482 alpha:1]; /*#7b7b7b*/
    textLabel.text = text;
    
    
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:@"Futura Std" size:12], NSFontAttributeName,
                                          nil];
    
    CGRect frame = [textLabel.text boundingRectWithSize:CGSizeMake(220, 2000.0)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:attributesDictionary
                                                context:nil];
    
    CGSize size = frame.size;
    
    textLabel.frame = CGRectMake(12, 8, size.width, size.height + 5);
    textLabel.numberOfLines = 0;
    [textLabel sizeToFit];
    bubbleImageView.frame = CGRectMake(55, 8, size.width + 20, size.height + 18); //set these variables as you want
    [bubbleImageView addSubview:textLabel];
    
    NSString *iconString = [NSString stringWithFormat:@"%@%i%@", @"icon", id, @".png"];
    NSLog(@"%@", iconString);
    
    UIImage *avatarImage = [UIImage imageNamed:iconString];
    UIImageView *avatarImageView = [[UIImageView alloc] initWithImage:avatarImage];
    avatarImageView.frame = CGRectMake(12, 8, avatarImage.size.width, avatarImage.size.height);
    textLabel.frame = CGRectMake(12, 4, size.width, size.height + 5);
    [cell.contentView addSubview:avatarImageView];
    [cell.contentView addSubview:bubbleImageView];
    
    return cell;
}

- (UITableViewCell*)selfChatBubble:(NSString*)text cell:(UITableViewCell*)cell {
    UIImage *bubbleImage = [[UIImage imageNamed:@"blue_text_bubble.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    cell.backgroundColor = [UIColor clearColor];
    UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:bubbleImage];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    textLabel.font = [UIFont fontWithName:@"Futura Std" size:12];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.text = text;
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:@"Futura Std" size:12], NSFontAttributeName,
                                          nil];

    CGRect frame = [textLabel.text boundingRectWithSize:CGSizeMake(220, 2000.0)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:attributesDictionary
                                                context:nil];
    
    CGSize size = frame.size;
    
    textLabel.numberOfLines = 0;
    [textLabel sizeToFit];
    bubbleImageView.frame = CGRectMake(308 - (size.width + 24), 8, size.width + 20, size.height + 18); //set these variables as you want
    [bubbleImageView addSubview:textLabel];
    textLabel.frame = CGRectMake(8, 4, size.width, size.height + 5);
    [cell.contentView addSubview:bubbleImageView];
    
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    
    Message *message = [_chatSource objectAtIndex:indexPath.row];
    
    [self othersChatBubble:message.message cell:cell avatarID:[[_avatarForUser objectForKey:message.uId] intValue]];

    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[_chatSource addObject:@"Hello! My name is Roger Sabonis and I work for the city. Please stop protesting. People might get mad..."];
    //[tableView reloadData];
}









@end
