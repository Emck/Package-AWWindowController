//
//  WebWindowController.m
//  AvawTools
//  Show Web page
//  Created by Emck on 5/13/22.
//

#import "WebWindowController.h"

@implementation WebWindowInfo

- (instancetype)initWithTitle:(NSString *)title Size:(NSSize)size Path:(NSString *)path UrlParameter:(nullable NSString *)urlParameter; {
    self = [super init];
    if (self) {
        self.isCenter = YES;
        self.Style    = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable;
        self.Title    = title;
        self.Size     = size;
        self.Path     = path;
        if (urlParameter) self.urlParameter = urlParameter;
        else self.urlParameter = @"";
    }
    return self;
}

- (void)addPageScript:(NSString *)script {
    if (_pageScripts == nil) _pageScripts = [[NSMutableArray alloc] init];
    [_pageScripts addObject:script];
}

- (void)addPageButton:(NSObject *)object forKey:(nonnull NSString *)Key {
    if (_pageButtons == nil) _pageButtons = [[NSMutableDictionary alloc] init];
    [_pageButtons setObject:object forKey:Key];
}

- (void)dealloc {
    if (_pageButtons) {
        [_pageButtons removeAllObjects];
        _pageButtons = nil;
    }
    if (_pageScripts) {
        [_pageScripts removeAllObjects];
        _pageScripts = nil;
    }
}

@end


@interface WebWindowController ()

@property( nullable,  assign ) id<WebWindowDelegate>  delegate;
@property( nonatomic, strong ) WebWindowInfo         *webInfo;
@property( nonatomic, strong ) WKWebView             *webView;
@property( nonatomic, strong ) AWPageControl          *pageControl;

@end

@implementation WebWindowController

- (instancetype)initWithWebInfo:(WebWindowInfo *)webInfo Delegate:(nullable id)delegate {
    self = [super initWithWindow:[[NSWindow alloc] initWithContentRect:NSMakeRect(0,0,webInfo.Size.width, webInfo.Size.height)
                            styleMask:webInfo.Style
                            backing:NSBackingStoreBuffered
                            defer:false]];
    self.delegate = delegate;
    self.webInfo = webInfo;
    [self initWebWindow];
    return self;
}

- (void)initWebWindow {
    self.window.delegate = self;
    self.window.title = self.webInfo.Title;           // 设置窗口Title
    self.webView = [[WKWebView alloc] initWithFrame:self.window.contentView.bounds];    // 初始化WKWebView
    [self.window.contentView addSubview:self.webView];      // 添加WKWebView到Window中
    
    // 转换成file路径,并拼上参数
    NSString* path  = [NSString stringWithFormat:@"file://%@?%@",[self generateHtmlPath:self.webInfo.Path], self.webInfo.urlParameter]; // Local System Path
    [self.webView loadFileURL:[NSURL URLWithString:path] allowingReadAccessToURL:[NSURL URLWithString:path]];   // load html file
}

- (void)showWindow:(id)sender {
    [super showWindow:sender];

    if (self.webInfo.isCenter == YES) [self.window center]; // move window to center
    if (!self.webInfo.pageScripts || self.webInfo.pageScripts.count <0) return;
    
    // need add AWPageControl
    @try {
        self.pageControl = [[AWPageControl alloc] initWithParentViewSize:self.window.contentView.frame.size Data:[self.webInfo.pageButtons objectForKey:@"Page"]];
        [self.pageControl customButton:AWPCButtonLeft   Button:[self.webInfo.pageButtons objectForKey:@"Left"]];
        [self.pageControl customButton:AWPCButtonRight  Button:[self.webInfo.pageButtons objectForKey:@"Right"]];
        [self.pageControl customButton:AWPCButtonEnding Button:[self.webInfo.pageButtons objectForKey:@"Ending"]];
        [self.pageControl setDelegate:self];                                // receive Event
        [self.pageControl setTotalPages:self.webInfo.pageScripts.count];    // total pages
        [self.window.contentView addSubview:self.pageControl];              // add view
    } @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
        self.pageControl = nil;
    }
}

- (void)dealloc {
    self.delegate = nil;
    self.webView = nil;
    self.webInfo = nil;
}


- (void)windowWillClose:(NSNotification *)notification {
    if (self.pageControl) {
        [self.pageControl removeFromSuperview];
        self.pageControl = nil;
    }
}

- (BOOL)windowShouldClose:(NSWindow *)sender {
    if (!self.delegate || ![self.delegate respondsToSelector: @selector(WebWindowShouldClose:)]) return YES;
    else return [self.delegate WebWindowShouldClose:self];          // Call delegate
}


#pragma mark - AWPageControl Delegate

// 即将进入这个页面时
- (void)pageControl:(AWPageControl *)pageControl didWillSelectPageAtIndex:(NSInteger)index {
    [self.webView evaluateJavaScript:self.webInfo.pageScripts[index] completionHandler:nil];
}

// 点击了结束按钮时
- (void)pageControl:(AWPageControl *)pageControl didClickEndingButton:(id)sender {
    if (!self.delegate || ![self.delegate respondsToSelector: @selector(WebWindowShouldClose:)]) [self close];
    else if ([self.delegate WebWindowShouldClose:self] == YES) [self close];        // Call delegate
}


#pragma mark - generateHtmlPath

// Generate Localhost Html Path
- (NSString *)generateHtmlPath:(NSString *)shortUrl {
    NSArray *array = [shortUrl componentsSeparatedByString:@"."];
    NSRange range = [array[0] rangeOfString:@"/" options:NSBackwardsSearch] ;
    return [[NSBundle mainBundle] pathForResource: [array[0] substringFromIndex:range.location + 1]
                                           ofType: array[1]
                                      inDirectory: [array[0] substringToIndex:range.location]];
}

@end
