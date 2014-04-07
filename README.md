DDCoachMarks
============

Quick and easy coach marks to use in any iOS app.

![](https://raw.githubusercontent.com/ddoria921/DDCoachMarks/master/Preview%20Images/preview1.png?token=3970871__eyJzY29wZSI6IlJhd0Jsb2I6ZGRvcmlhOTIxL0REQ29hY2hNYXJrcy9tYXN0ZXIvUHJldmlldyBJbWFnZXMvcHJldmlldzEucG5nIiwiZXhwaXJlcyI6MTM5NzMzMjE1NX0%3D--c7460ce128607c4887106c88f0572d75d593dae1)

![](https://raw.githubusercontent.com/ddoria921/DDCoachMarks/master/Preview%20Images/preview2.png?token=3970871__eyJzY29wZSI6IlJhd0Jsb2I6ZGRvcmlhOTIxL0REQ29hY2hNYXJrcy9tYXN0ZXIvUHJldmlldyBJbWFnZXMvcHJldmlldzIucG5nIiwiZXhwaXJlcyI6MTM5NzMzMjE3OH0%3D--436361979e62e3639c427b94c7d6804eab77d38b)

![](https://raw.githubusercontent.com/ddoria921/DDCoachMarks/master/Preview%20Images/preview3.png?token=3970871__eyJzY29wZSI6IlJhd0Jsb2I6ZGRvcmlhOTIxL0REQ29hY2hNYXJrcy9tYXN0ZXIvUHJldmlldyBJbWFnZXMvcHJldmlldzMucG5nIiwiZXhwaXJlcyI6MTM5NzMzMjE5NH0%3D--49ede964615a2980e484ad0ad53a295d5725c72a)


## Requirements
DDCoachMarks works on any iOS version and is built with ARC. It depends on the following Apple frameworks:

* Foundation.framework
* UIKit.framework
* QuartzCore.framework

## Adding DDCoachMarks to your project

1. Copy the source files in the Coach Marks folder into your project. 
2. Include the coach marks wherever you need it by using `#import "DDCoachMarksView.h"`

## Example
Create a new DDCoachMarksView instance and pass in an array of coach mark definitions

```objective-c
- (void)viewDidAppear:(BOOL)animated 
{
	[super viewDidLoad];

	// ...

	// Setup coach marks
	NSArray *coachMarks = @[
                            @{
                                @"rect": [NSValue valueWithCGRect:CGRectMake(6, 24, 40, 40)],
                                @"caption": @"Synchronize your mail",
                                @"shape": @"circle"
                                },
                            @{
                                @"rect": [NSValue valueWithCGRect:CGRectMake(275, 24, 40, 40)],
                                @"caption": @"Create a new message",
                                @"shape": @"circle",
                                },
                            @{
                                @"rect": [NSValue valueWithCGRect:CGRectMake(0, 125, 320, 60)],
                                @"caption": @"Swipe for more options",
                                @"shape": @"square",
                                @"swipe": @"YES"
                                },
                            ];

	DDCoachMarksView *coachMarksView = [[DDCoachMarksView alloc] initWithFrame:self.view.bounds coachMarks:coachMarks];
	[self.view addSubview:coachMarksView];
	[coachMarksView start];
}
```

If you want to add the coach marks to a view controller that is part of a navigation controller, you need to add it to the navigation controller's view like this...
```objective-c
DDCoachMarksView *coachMarksView = [[DDCoachMarksView alloc] initWithFrame:self.navigationController.view.bounds coachMarks:coachMarks];
[self.navigationController.view addSubview:coachMarksView];
[coachMarksView start];
```

You also might need to change the coordinates of the CGRect values you passed into the coach marks array using the method shown below.
```objective-c
// translate values to navigation controller
CGRect navFrame = [self.view convertRect:button.frame toView:navController.view];
```

You can configure any coach mark properties before calling the `start` method. For example:
```objective-c
coachMarksView.animationDuration = 0.5f;
coachMarksView.maskColor = [UIColor blueColor];
coachMarksView.useBubbles = NO;
[coachMarksView start];
```

## Configuration
When creating your array of dictionary definitions for each coach mark only the `@"rect"` value is required. 
Other optional values are:
* `@"caption"` 
Text that goes in the bubbles
* `@"shape"`
 Can be set to circle or square. If nothing is defined, the default is a rounded rect.
* `@"POI"`
 Stands for 'point of interest'. You can define a whole region using the `@"rect"` value, but defining a different CGRect value here makes the bubble caption position itself under the POI rect.
* `@"swipe"`
 Use "YES" here if you want to show a row swipe gesture on a table view cell. Disabled by default.

## DDCoachMarksViewDelegate

If you'd like to take a certain action when a specific coach mark comes into view, your view controller can implement the DDCoachMarksViewDelegate.

### 1. Conform your view controller to the DDCoachMarksViewDelegate protocol:

`@interface MainViewController : UIViewController <DDCoachMarksViewDelegate>`

### 2. Assign the delegate to your coach marks view instance:

`coachMarksView.delegate = self;`

### 3. Implement the delegate protocol methods:

*Note: All of the methods are optional. Implement only those that are needed.*

- `- (void)coachMarksView:(DDCoachMarksView*)coachMarksView willNavigateToIndex:(NSUInteger)index`
- `- (void)coachMarksView:(DDCoachMarksView*)coachMarksView didNavigateToIndex:(NSUInteger)index`
- `- (void)coachMarksViewWillCleanup:(DDCoachMarksView*)coachMarksView`
- `- (void)coachMarksViewDidCleanup:(DDCoachMarksView*)coachMarksView`

## Acknowledgements
Used and modified code from the following sources. 

https://github.com/workshirt/WSCoachMarksView/

https://github.com/Cclleemm/ProductTour
