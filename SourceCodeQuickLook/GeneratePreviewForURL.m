#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include <Cocoa/Cocoa.h>
#include <WebKit/WebKit.h>

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
 Generate a preview for file
 This function's job is to create preview for designated file
 ----------------------------------------------------------------------------- */
CFStringRef getSourceCodeType(CFStringRef extention){
    NSString *string = (__bridge NSString*)extention;
    if ([string isEqualToString:@"m"]) {
        return kUTTypeObjectiveCSource;
    }
    if ([string isEqualToString:@"h"]) {
        return kUTTypeCHeader;
    }
    if ([string isEqualToString:@"rb"]) {
        return kUTTypeRubyScript;
    }
    if ([string isEqualToString:@"c"]) {
        return kUTTypeCSource;
    }
    if ([string isEqualToString:@"cpp"]) {
        return kUTTypeCPlusPlusSource;
    }
    if ([string isEqualToString:@"swift"]) {
        return kUTTypeSwiftSource;
    }
    if ([string isEqualToString:@"s"]) {
        return kUTTypeAssemblyLanguageSource;
    }
    if ([string isEqualToString:@"java"]) {
        return kUTTypeJavaSource;
    }
    
    return kUTTypeSourceCode;
}

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:[(__bridge NSString*)CFURLCopyPath(url) stringByRemovingPercentEncoding]];
    NSData *data = [handle readDataOfLength:200*1024]; // 200k 最大
    NSString *string = [NSString stringWithUTF8String:data.bytes];
    int code = 1;
    while (!string && code < 16) {
        string = [[NSString alloc] initWithData:data encoding:code];
        if (string) {
            break;
        }
        code ++;
    }
    string = string ?: @"error:  获取内容失败";
    CFStringRef extention = (__bridge CFStringRef)([(__bridge NSURL*)url pathExtension] ?: @"unknown");
    QLPreviewRequestSetDataRepresentation(preview,
                                          (__bridge CFDataRef)[string dataUsingEncoding:NSUTF8StringEncoding],
                                          getSourceCodeType(extention),
                                          NULL);
    return noErr;
}


void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview){}
