
@implementation UIWindow (BigShot)

UIScrollView* getVerticalScrollView(UIView *aView);
UIWebView* getWebView(UIView *aView);

-(UIImage*)takeFullScreenShot{
    CGRect bounds = self.bounds;
    CGPoint previousContentOffset = CGPointZero;
    UIScrollView *scrollView = getVerticalScrollView(self);
    UIWebView *webView = getWebView(self);

    CGFloat calculatedHeight = 0;
    if (webView != nil) {
        CGFloat exceptWebViewHeight = bounds.size.height - webView.frame.size.height;
        CGFloat webViewContentHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.height"] floatValue];
        calculatedHeight = webViewContentHeight + exceptWebViewHeight;
        previousContentOffset = webView.scrollView.contentOffset;
    } else if (scrollView != nil) {
        CGFloat exceptScollViewHeight = bounds.size.height - scrollView.bounds.size.height;
        calculatedHeight = scrollView.contentSize.height + exceptScollViewHeight;
        previousContentOffset = scrollView.contentOffset;
    }

    if (calculatedHeight > 10000) {
        calculatedHeight = 10000;
    }

    if (calculatedHeight > self.bounds.size.height) {
        self.bounds = CGRectMake(0, 0, self.bounds.size.width, calculatedHeight);
    }

    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque,0.0);
    [[UIApplication sharedApplication].keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.bounds = bounds;
    scrollView.contentOffset = previousContentOffset;

    return image;
}

UIScrollView* getVerticalScrollView(UIView *aView) {

    if (isVerticalScrollingView(aView)) {
        return  (UIScrollView*)aView;
    }

    for (UIView *view in aView.subviews) {
        UIScrollView *scrollView =  getVerticalScrollView(view);
        if (isVerticalScrollingView(scrollView)) {
            return scrollView;
        }
    }

    return nil;
}

BOOL isVerticalScrollingView(UIView *view) {
    if (view != nil && [view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView*)view;
        if (scrollView.contentSize.height > scrollView.bounds.size.height) {
            return YES;
        }
    }
    return NO;
}

UIWebView* getWebView(UIView *aView) {

    if ([aView isKindOfClass:[UIWebView class]]) {
        return  (UIWebView*)aView;
    }

    for (UIView *view in aView.subviews) {
        UIWebView *webView = getWebView(view);
        if (webView !=nil) {
            return webView;
        }
    }

    return nil;
}

@end