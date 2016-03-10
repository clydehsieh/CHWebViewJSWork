//
//  ViewController.m
//  CHWebViewJSWork
//
//  Created by Chin-Hui Hsieh  on 3/8/16.
//  Copyright © 2016 Chin-Hui Hsieh. All rights reserved.
//
#define TAG_yearTF  101
#define TAG_monthTF 102
#define TAG_dayTF   103

#import <MapKit/MapKit.h>
#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *iosBackgroundView;
@property (weak, nonatomic) IBOutlet UITextField *yearTextField;
@property (weak, nonatomic) IBOutlet UITextField *monthTextField;
@property (weak, nonatomic) IBOutlet UITextField *dayTextField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (nonatomic) MKMapView *mapView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _yearTextField.tag  = TAG_yearTF ;
    _monthTextField.tag = TAG_monthTF;
    _dayTextField.tag   = TAG_dayTF  ;
    
    //load index
    NSString *path = [[NSBundle mainBundle]pathForResource:@"index" ofType:@"html" inDirectory:@"wwwRoot"];
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
    [_webView loadRequest:request];
    _webView.layer.borderWidth = 2.0f;
    _webView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _webView.delegate = self;
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - webview delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSURL *url = [request URL];
    NSString *urlStr = url.absoluteString;
    
    return [self processURL:urlStr];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    NSString *currentURL = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    NSLog(@"currentURL:%@",currentURL);
    NSLog(@"title:%@",title);
    
//    [_webView stringByEvaluatingJavaScriptFromString:@"alert('You')"];
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error{
    
}


#pragma mark - 
- (BOOL) processURL:(NSString *) url
{
    NSString *urlStr = [NSString stringWithString:url];
    
    NSString *protocolPrefix = @"js2ios://";
    if ([[urlStr lowercaseString] hasPrefix:protocolPrefix])
    {
//                NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
//                urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:set];
        
                //js2ios://%7B%22funcName%22:%22updateText%22,%22arg%22:%221949t1%081%E5%22%7D
        
                urlStr = [urlStr substringFromIndex:protocolPrefix.length];
        
                urlStr = [urlStr stringByRemovingPercentEncoding];///!!!:轉中文會有問題
        
                NSError *jsonError;
        
                NSDictionary *callInfo = [NSJSONSerialization
                                          JSONObjectWithData:[urlStr dataUsingEncoding:NSUTF8StringEncoding]
                                          options:kNilOptions
                                          error:&jsonError];
        
                if (jsonError != nil)
                {
                    //call error callback function here
                    NSLog(@"Error parsing JSON for the url %@",url);
                    return NO;
                }
        
        
                NSString *functionName = [callInfo objectForKey:@"funcName"];
                NSString *newString = [callInfo objectForKey:@"arg"];
                if (functionName == nil)
                {
                    NSLog(@"Missing function name");
                    return NO;
                }else if ([functionName isEqualToString:@"updateLabel"]){
                    [self updateDateLable:newString];
                }else if ([functionName isEqualToString:@"updateText"]){
                    [self updateDateTextField:newString];
                }else if ([functionName isEqualToString:@"showMap"]){
                    [self showMap];
                }else if ([functionName isEqualToString:@"removeMap"]){
                    [self removeMap];
                }
        
        
        
        return NO;
        
    }
    
    return YES;
}


-(void)changeJSSelectDateType:(NSString *)dateType dateValue:(NSString *)dateValue{
    
    NSString *jsFuncionName = @"selectDidChangeByIOS";
    NSString *arg1 = dateType;
    NSString *arg2 = dateValue;
    NSString *total = [NSString stringWithFormat:@"%@('%@','%@')",jsFuncionName,arg1,arg2];
    
    [_webView stringByEvaluatingJavaScriptFromString:total];
    
}

#pragma mark - respone to js request
-(void)updateDateLable:(NSString *)newString{
    _dateLabel.text = [NSString stringWithFormat:@"Updated Date:%@",newString];
}

-(void)updateDateTextField:(NSString *)newString{
    
    NSArray *array=[newString componentsSeparatedByString:@"."];
    _yearTextField.text  = array[0];
    _monthTextField.text = array[1];
    _dayTextField.text   = array[2];
}

-(void)showMap{
    
    NSArray *subViews = [_iosBackgroundView subviews];
    
    if (![subViews containsObject:_mapView]) {
        _mapView = [[MKMapView alloc]initWithFrame:_iosBackgroundView.bounds];
        _mapView.layer.borderWidth = 2.0f;
        _mapView.layer.borderColor = [UIColor lightGrayColor].CGColor;

        [_iosBackgroundView addSubview:_mapView];
    }
    
}

-(void)removeMap{
    
    [_mapView removeFromSuperview];
    
}

#pragma mark - UITextField
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    
    UITextField *textField = (UITextField *)[touch view];
    
    //touch other view
    if (![textField isExclusiveTouch]) {
        [textField resignFirstResponder];
    }
    
    
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    NSString *dateType;
    
    switch (textField.tag) {
        case TAG_yearTF:
            dateType = @"year";
            break;
        case TAG_monthTF:
            dateType = @"month";
            break;
        case TAG_dayTF:
            dateType = @"day";
            break;
        default:
            break;
    }
    
    if (![textField.text isEqualToString:@""]) {
        [self changeJSSelectDateType:dateType dateValue:textField.text];
    }
    
}

@end











