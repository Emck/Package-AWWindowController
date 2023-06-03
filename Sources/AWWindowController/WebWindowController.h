//
//  WebWindowController.h
//  AvawTools
//  Show Web page
//  Created by Emck on 5/13/22.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <AWPageControl.h>

NS_ASSUME_NONNULL_BEGIN

// 保存Web Window信息
@interface WebWindowInfo : NSObject
@property ( nonatomic, assign           ) NSSize               Size;        // 窗口大小
@property ( nonatomic, assign           ) BOOL                 isCenter;    // 是否居中显示
@property ( nonatomic, assign           ) NSWindowStyleMask    Style;       // 窗口风格
@property ( nonatomic, strong           ) NSString            *Title;       // 窗口标题
@property ( nonatomic, strong           ) NSString            *Path;        // 保存Html文件本地全路径
@property ( nonatomic, strong           ) NSString            *urlParameter;   //
@property ( nonatomic, strong, readonly ) NSMutableArray      *pageScripts; // 页面总数对应的javascript
@property ( nonatomic, strong, readonly ) NSMutableDictionary *pageButtons; //

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTitle:(NSString *)title Size:(NSSize)size Path:(NSString *)path UrlParameter:(nullable NSString *)urlParameter;
- (void)addPageScript:(NSString *)script;
- (void)addPageButton:(NSObject *)object forKey:(nonnull NSString *)Key;

@end


@class WebWindowController;
@protocol WebWindowDelegate <NSObject>

- (BOOL)WebWindowShouldClose:(WebWindowController *)sender;

@end

@interface WebWindowController : NSWindowController <NSWindowDelegate, AWPageControlDelegate>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithWebInfo:(WebWindowInfo *)webInfo Delegate:(nullable id)delegate;

@end

NS_ASSUME_NONNULL_END
