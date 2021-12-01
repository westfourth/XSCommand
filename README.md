# XSCommand

以命令模式设计的中介者，用于模块间解藕，也可用作控制器解藕。

![架构设计](XSCommand.png)


## 举例

-  **AViewController**

``` objc
@interface AViewController : UIViewController
@end
```

-  **BViewController**

``` objc
@interface BViewController : UIViewController
@property (nonatomic) UIColor *bgColor;
@end
```


## 基本使用

使用时，属性名相同即可，例如`BViewController.bgColor` <--> `BCommand.bgColor`。


### 1.  使用Storyboard方式

实现`XSCommandStoryboard`协议，并提供storyboardName

-  **BCommand**

``` objc
@interface BCommand : XSCommand <XSCommandStoryboard>
@property (nonatomic) UIColor *bgColor;
@end
```

``` objc
@implementation BCommand
@synthesize storyboardName;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.storyboardName = @"Main";
        self.className = @"BViewController";
    }
    return self;
}

@end
```

### 2.  使用Nib方式

实现`XSCommandNib`协议

-  **BCommand**

``` objc
@interface BCommand : XSCommand <XSCommandNib>
@property (nonatomic) UIColor *bgColor;
@end
```

``` objc
@implementation BCommand

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.className = @"BViewController";
    }
    return self;
}

@end
```

### 3.  使用Code方式

-  **BCommand**

``` objc
@interface BCommand : XSCommand
@property (nonatomic) UIColor *bgColor;
@end
```

``` objc
@implementation BCommand

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.className = @"BViewController";
    }
    return self;
}

@end
```

### 调用

``` objc
BCommand *c = [BCommand new];
c.bgColor = [UIColor redColor];
[self presentViewController:[c command] animated:YES completion:nil];
```


## 进阶使用 1：有不同的属性名

-  **BViewController**

``` objc
@interface BViewController : UIViewController

@property (nonatomic) UIColor *bgColor;

@end
```

-  **BCommand**

``` objc
@interface BCommand : XSCommand

@property (nonatomic) UIColor *bg_color;

@end
```


这时候`BViewController.bgColor`与`BCommand.bg_color`名称不一致。

### 处理方法：

在`BViewController`模块中写个`BCommand `分类，重写`-command`方法

-  **BViewController**

``` objc
#import "BCommand.h"

//  可以不写 @interface BCommand(XXX)
@implementation BCommand (XXX)

- (__kindof UIViewController *)command {
    BViewController *vc = [BViewController new];
    vc.bgColor = self.bg_color;
    return vc;
}

@end

@implementation BViewController

@end
```


## 进阶使用 2：有自定义的初始化方法

-  **BViewController**

``` objc
@interface BViewController : UIViewController

- (instancetype)initWithArray:(NSArray *)array;

@end
```

### 处理方法：

在`BViewController`模块中写个`BCommand `分类，重写`-command`方法；

并在`BCommand `中新增属性，持有需要传递的参数。

-  **BViewController**

``` objc
#import "BCommand.h"

//  可以不写 @interface BCommand(XXX)
@implementation BCommand (XXX)

- (__kindof UIViewController *)command {
    BViewController *vc = [[BViewController alloc] initWithArray:self.array];
    return vc;
}

@end

@implementation BViewController

- (instancetype)initWithArray:(NSArray *)array {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        NSLog(@">>> %@", array);
    }
    return self;
}

@end
```

-  **BCommand**

``` objc
@interface BCommand : XSCommand

@property (nonatomic) NSArray *array;

@end
```

### 调用：

``` objc
    BCommand *c = [BCommand new];
    c.array = @[@"ABC", @"123"];
    [self presentViewController:[c command] animated:YES completion:nil];
```


## 进阶使用 3：有多个自定义的初始化方法

-  **BViewController**

``` objc
@interface BViewController : UIViewController

- (instancetype)initWithArray:(NSArray *)array;

- (instancetype)initWithText:(NSString *)text count:(NSInteger)count;

@end
```

### 处理方法：

在`BViewController`模块中写个`BCommand `分类，重写`-command`方法；

在`BCommand `中新增的每个属性，对应需要传递的参数；**并额外新增一个枚举**。

-  **BViewController**

``` objc
#import "BCommand.h"

//  可以不写 @interface BCommand(XXX)
@implementation BCommand (XXX)

- (__kindof UIViewController *)command {
    BViewController *vc;
    if (self.initType == BCommandInitTypeWithArray) {
        vc = [[BViewController alloc] initWithArray:self.array];
    } else {
        vc = [[BViewController alloc] initWithText:self.text count:self.count];
    }
    return vc;
}

@end

@implementation BViewController

- (instancetype)initWithArray:(NSArray *)array {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        NSLog(@">>> %@", array);
    }
    return self;
}

- (instancetype)initWithText:(NSString *)text count:(NSInteger)count {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        NSLog(@">>> %@, %ld", text, count);
    }
    return self;
}

@end
```

-  **BCommand**

``` objc
typedef NS_ENUM(NSUInteger, BCommandInitType) {
    BCommandInitTypeWithArray = 0,      //  默认
    BCommandInitTypeWithTextAndCount,
};

@interface BCommand : XSCommand

@property (nonatomic) BCommandInitType initType;

@property (nonatomic) NSArray *array;

@property (nonatomic) NSString *text;

@property (nonatomic) NSInteger count;

@end
```

### 调用：

``` objc
    BCommand *c = [BCommand new];
    c.text = @"一二三";
    c.count = 3;
    c.initType = BCommandInitTypeWithTextAndCount;
    [self presentViewController:[c command] animated:YES completion:nil];
```


## 进阶使用 4：block回调

把该block当作普通的属性即可。

-  **BViewController**

``` objc
@interface BViewController : UIViewController

@property (nonatomic) void (^callback)(void);

@end
```

-  **BCommand**

``` objc
@interface BCommand : XSCommand

@property (nonatomic) void (^callback)(void);

@end
```

### 调用：

``` objc
    BCommand *c = [BCommand new];
    c.callback = ^{
        puts(__func__);
    };
    [self presentViewController:[c command] animated:YES completion:nil];
```


## 进阶使用 5：delegate回调

在`BCommand`中复制`BViewController`中的`delegate`、`@protocol`，如果不该引用某个类，则把相应参数类型该为`id`。

-  **BViewController**

``` objc
@interface BViewController : UIViewController
@property (nonatomic) id<BViewControllerDelegate> delegate;
@end

@protocol BViewControllerDelegate <NSObject>
- (void)didDismiss:(BViewController *)vc;
@end
```

-  **BCommand**

``` objc
@interface BCommand : XSCommand

//  改变协议类型
@property (nonatomic) id<BCommandDelegate> delegate;

@end

//  复制 @protocol BViewControllerDelegate，将其改名
@protocol BCommandDelegate <NSObject>

//  防止引入BViewController，将参数类型改为UIViewController
- (void)didDismiss:(UIViewController *)vc;

@end
```

### 调用：


``` objc

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    BCommand *c = [BCommand new];
    c.delegate = self;
    [self presentViewController:[c command] animated:YES completion:nil];
}

- (void)didDismiss:(UIViewController *)vc {

}

```


## 进阶使用 6：关于业务模型的引用

如果ACommand、BCommand层没有引用业务模型，那么在ACommand、BCommand层中需要将具体业务模型类型改为`id`类型。

``` objc
@interface TestCommand : XSCommand <XSCommandStoryboard>
@property (nonatomic) UIColor *bgColor;
@property (nonatomic) id person;
@end
```

