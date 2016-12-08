//
//  ViewController.m
//  VXJSContext
//
//  Created by voidxin on 16/12/8.
//  Copyright © 2016年 voidxin. All rights reserved.
//

#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
@interface ViewController ()<UIWebViewDelegate>
@property(nonatomic,strong)UIWebView *webView;
@property(nonatomic,strong)UIButton *button;
@property(nonatomic,strong)JSContext *context;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBaseViews];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self webViewLoadData];
}

- (void)addBaseViews{
    [self.view addSubview:self.webView];
    [self.view addSubview:self.button];
    self.button.frame = CGRectMake(100, CGRectGetMaxY(self.webView.frame), 200, 44);
    
}

- (void)webViewLoadData{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"html"];
    NSString *htmlCont = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:htmlCont baseURL:baseURL];

}

- (void)btnAction{
    //调用html中的js
    [self.context[@"nativeCall"] callWithArguments:@[@"我是voidxin，我来自native"]];
}

- (void)jsCallNative{
    //相当于重写了html文件中的changetext方法，原来的代码不再执行
    self.context[@"changetext"] = ^(){
        NSLog(@"js调用native代码");
    };
}

#pragma mark - webView delegate 
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    self.context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
   
    [self jsCallNative];
    
}



#pragma mark - getter
- (UIWebView *)webView{
    if (!_webView) {
        _webView = [[UIWebView alloc]init];
        _webView.delegate = self;
        _webView.frame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height - 50);
    }
    return _webView;
}

- (JSContext *)context{
    if (!_context) {
        _context = [[JSContext alloc]init];
    }
    return _context;
}

- (UIButton *)button{
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeSystem];
        [_button setTitle:@"调用js" forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
        _button.backgroundColor = [UIColor orangeColor];
    }
    return _button;
}


#pragma mark 相互调用的方法
- (void)testContext{
    //oc调用js
    JSContext *cons = [[JSContext alloc]init];
    NSString *js = @"function test(a,b) { return a-b}";
    [cons evaluateScript:js];
    JSValue *value = [cons[@"test"] callWithArguments:@[@5,@1]];
    NSLog(@"-----------%@-----",value);
   
}

- (void)testContext2{
    //js调用oc(block方式)
    JSContext *cont2 = [[JSContext alloc]init];
    cont2[@"test"] = ^() {
        NSLog(@"i am void xin from js");
    };
    
    [cont2 evaluateScript:@"test()"];
    
    //JSExport protocol方式
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
