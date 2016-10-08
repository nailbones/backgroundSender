#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];

    sendButton.frame = CGRectMake(0, 80, CGRectGetWidth(self.view.bounds), 60);
    sendButton.backgroundColor = [UIColor colorWithRed:0 green:0.5 blue:0.5 alpha:1];
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendButton];

    UIButton *scheduleButton = [UIButton buttonWithType:UIButtonTypeCustom];

    scheduleButton.frame = CGRectMake(0, CGRectGetMaxY(sendButton.frame) + 40, CGRectGetWidth(self.view.bounds), 60);
    [scheduleButton setTitle:@"Schedule" forState:UIControlStateNormal];
    scheduleButton.backgroundColor = [UIColor colorWithRed:0.5 green:0 blue:0.5 alpha:1];
    [scheduleButton addTarget:self action:@selector(schedule) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scheduleButton];


}

- (void)send
{
    AppDelegate *delegate = [self appdelegate];
    [delegate sendThing];
}

- (void)schedule
{
    AppDelegate *delegate = [self appdelegate];
    [delegate scheduleThing];
}

- (AppDelegate *)appdelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
