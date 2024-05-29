#import "UITextField+Extensions.h"
#import <objc/runtime.h>

static const char *lengthLimitKey = "lengthLimitKey";
static const char *changeBlock = "changeBlock";

@implementation UITextField (Extensions)

- (NSRange)selectedRange {
    
    UITextPosition* beginning = self.beginningOfDocument;
    
    UITextRange* selectedRange = self.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    
    const NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}

- (void)setSelectedRange:(NSRange)range {
    UITextPosition* beginning = self.beginningOfDocument;
    
    UITextPosition* startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition* endPosition = [self positionFromPosition:beginning offset:range.location + range.length];
    UITextRange* selectionRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
    
    [self setSelectedTextRange:selectionRange];
}

- (void (^)(NSInteger))didChangeBlock{
    return objc_getAssociatedObject(self, changeBlock);
}

- (void)setDidChangeBlock:(void (^)(NSInteger))didChangeBlock{
    
    objc_setAssociatedObject(self, changeBlock, didChangeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSInteger)fLengthLimit {
    return [objc_getAssociatedObject(self, lengthLimitKey) integerValue];
}

- (void)setFLengthLimit:(NSInteger)fLengthLimit {
    objc_setAssociatedObject(self, lengthLimitKey, @(fLengthLimit), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldDidChange:(UITextField *)textField
{
    NSString *toBeString = textField.text;
    
    if (toBeString.length<self.fLengthLimit || self.fLengthLimit <0) {
        if (self.didChangeBlock) {
            self.didChangeBlock(textField.text.length);
        }
        return;
    }
    
    NSString *lang = [[UIApplication sharedApplication]textInputMode].primaryLanguage ;
    
    if ([lang hasPrefix:@"zh-Hans"]) {
        
        UITextRange *selectedRange = [textField markedTextRange];
        
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        
        if (!position) {
            textField.text = [self textFieldLimitWithString:toBeString];
        }
        else{
            
        }
    }else{
        textField.text = [self textFieldLimitWithString:toBeString];
    }
    if (self.didChangeBlock) {
        self.didChangeBlock(textField.text.length);
    }
}

- (NSString *)textFieldLimitWithString:(NSString *)string{
    NSRange range;
    NSMutableArray *tempMarr = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < string.length ; i += range.length ){
        range = [string rangeOfComposedCharacterSequenceAtIndex:i];
        NSString *subStr = [string substringWithRange:range];
        [tempMarr addObject:subStr];
    
    }
    
    NSString *old = @"";
    NSString *new = @"";
    
    for (NSString *subStr in tempMarr) {
        new = [new stringByAppendingString:subStr];
        if (new.length>self.fLengthLimit) {
            break;
        }else{
            old = new;
        }
    }
    return old;
}

@end
