//
//  YXFColorTool.m
//  heibaipei
//
//  Created by yxf on 2018/3/12.
//  Copyright © 2018年 k_yan. All rights reserved.
//

#import "YXFColorTool.h"
#import "LinkedListStack.h"
#import "ColorConfig.h"

@interface YXFColorTool ()

@property (nonatomic,assign)CGFloat currentScale;
/** 上一次点击的点 */
@property(nonatomic,assign)CGPoint lastPoint;

@end

@implementation YXFColorTool

+(instancetype)shareInstance{
    static YXFColorTool *tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[YXFColorTool alloc] init];
    });
    return tool;
}

/**
 撤销操作
 */
- (UIImage *)revokeOption:(UIImage *)image {
    CGPoint lastPoint = [self.revokePoints.lastObject CGPointValue];
    return [self floodFillImage:image fromPoint:lastPoint withColor:[UIColor whiteColor]];
}

// 计算俩点之间的距离
-(double)distance:(CGPoint)p1 point:(CGPoint)p2{
    double distance=sqrt(pow(p1.x-p2.x,2)+pow(p1.y-p2.y,2));
    return distance;
}
- (UIImage *)floodFillImage:(UIImage *)image fromPoint:(CGPoint)startPoint withColor:(UIColor *)newColor{
    if (!image) {
        return nil;
    }
    CGPoint tapPoint = startPoint;
    // 颜色差异度
    int tolerance = 10;
    BOOL antiAlias = NO;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imageRef = [image CGImage];
    if (imageRef == NULL) {
        [self freeData:NULL content:NULL imageRef:NULL colorSpace:colorSpace];
        return nil;
    }
    NSUInteger width = CGImageGetWidth(image.CGImage);
    NSUInteger height = CGImageGetHeight(image.CGImage);
    // 装换坐标 实际坐标转换成像素坐标
    size_t www = startPoint.x * [ColorConfig shareInstance].scaleRate;
    size_t hhh = startPoint.y * [ColorConfig shareInstance].scaleRate;
    
    
    
    startPoint = CGPointMake(www, hhh);
    unsigned char* imageData = malloc(width * height * 4) ;
    memset(imageData, 0, width * height * 4);
    
    NSUInteger bytesPerPixel = CGImageGetBitsPerPixel(imageRef) / 8;
//    NSUInteger bytesPerRow = CGImageGetBytesPerRow(imageRef);
    NSUInteger bytesPerRow = width * bytesPerPixel;
    NSUInteger bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    if (kCGImageAlphaLast == (uint32_t)bitmapInfo || kCGImageAlphaFirst == (uint32_t)bitmapInfo) {
        bitmapInfo = (uint32_t)kCGImageAlphaPremultipliedLast;
    }
    //开启图片上下文
    CGContextRef context = CGBitmapContextCreate(imageData,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 bitmapInfo);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    // 获取点击 像素点的颜色
    unsigned int byteIndex = (bytesPerRow * roundf(startPoint.y)) + roundf(startPoint.x) * bytesPerPixel;
    unsigned int ocolor = getColorCode(byteIndex, imageData);
    if (ocolor == 50529279 || ocolor == 67372287) {//黑色333,444
        [self freeData:imageData content:context imageRef:NULL colorSpace:colorSpace];
        return nil;
    }
    
    // 判断 点击的是否是边框
    unsigned int blackcolor = getColorCodeFromUIColor([UIColor blackColor],bitmapInfo&kCGBitmapByteOrderMask);
    if (compareColor(blackcolor, ocolor, 0)) {
        [self freeData:imageData content:context imageRef:NULL colorSpace:colorSpace];
        return nil;
    }
    // 如果新的颜色和旧的颜色 相同直接返回
    if (compareColor(ocolor, getColorCodeFromUIColor(newColor,bitmapInfo&kCGBitmapByteOrderMask), 10)) {
        [self freeData:imageData content:context imageRef:NULL colorSpace:colorSpace];
        return nil;
    }
    // 新的颜色  把新的颜色转换成容易储存的形式
    int newRed=0, newGreen=0, newBlue=0, newAlpha=0;
    const CGFloat *components = CGColorGetComponents(newColor.CGColor);
    if(CGColorGetNumberOfComponents(newColor.CGColor) == 2){
        newRed   = newGreen = newBlue = components[0] * 255;
        newAlpha = components[1] * 255;
    }else if (CGColorGetNumberOfComponents(newColor.CGColor) == 4){
        if ((bitmapInfo&kCGBitmapByteOrderMask) == kCGBitmapByteOrder32Little){
            newRed   = components[2] * 255;
            newGreen = components[1] * 255;
            newBlue  = components[0] * 255;
            newAlpha = 255;
        }else{
            newRed   = components[0] * 255;
            newGreen = components[1] * 255;
            newBlue  = components[2] * 255;
            newAlpha = 255;
        }
    }
    
    unsigned int ncolor = (newRed << 24) | (newGreen << 16) | (newBlue << 8) | newAlpha;
    int muti = (int)height;
    int increase = (int)(muti * 0.9);
    LinkedListStack *points = [[LinkedListStack alloc] initWithCapacity:500 incrementSize:increase andMultiplier:muti];
    LinkedListStack *antiAliasingPoints = [[LinkedListStack alloc] initWithCapacity:500 incrementSize:increase andMultiplier:muti ];
    
    // roundf 四舍五入 取整数
    int x = roundf(startPoint.x);
    int y = roundf(startPoint.y);
    
    [points pushFrontX:x andY:y];
    
    
    unsigned int color;
    
    BOOL spanLeft,spanRight;
    
    while ([points popFront:&x andY:&y] != INVALID_NODE_CONTENT){
        byteIndex = (bytesPerRow * roundf(y)) + roundf(x) * bytesPerPixel;
        color = getColorCode(byteIndex, imageData);
        //获取点击 像素点的颜色
        while(y >= 0 && compareColor(ocolor, color, tolerance)){
            y--;
            if(y >= 0){
                byteIndex = (bytesPerRow * roundf(y)) + roundf(x) * bytesPerPixel;
                color = getColorCode(byteIndex, imageData);
            }
        }
        
        
        // 将顶部的种子点 放入栈中
        if(y >= 0 && !compareColor(ocolor, color, 0)){
            [antiAliasingPoints pushFrontX:x andY:y];
        }
        
        y++;
        
        spanLeft = spanRight = NO;
        
        byteIndex = (bytesPerRow * roundf(y)) + roundf(x) * bytesPerPixel;
        
        color = getColorCode(byteIndex, imageData);
        while (y < height && compareColor(ocolor, color, tolerance)){
            //改变旧的颜色
            imageData[byteIndex + 0] = newRed;
            imageData[byteIndex + 1] = newGreen;
            imageData[byteIndex + 2] = newBlue;
            imageData[byteIndex + 3] = newAlpha;
            if(x > 0){
                byteIndex = (bytesPerRow * roundf(y)) + roundf(x - 1) * bytesPerPixel;
                color = getColorCode(byteIndex, imageData);
                if(!spanLeft && x > 0 && compareColor(ocolor, color, tolerance)){
                    [points pushFrontX:(x - 1) andY:y];
                    spanLeft = YES;
                }else if(spanLeft && x > 0 && !compareColor(ocolor, color, tolerance)){
                    spanLeft = NO;
                }
                
                // we can't go left. Add the point on the antialiasing list
                if(!spanLeft && x > 0 && !compareColor(ocolor, color, tolerance) && !compareColor(ncolor, color, tolerance)){
                    [antiAliasingPoints pushFrontX:(x - 1) andY:y];
                }
            }
            if(x < width - 1){
                byteIndex = (bytesPerRow * roundf(y)) + roundf(x + 1) * bytesPerPixel;;
                color = getColorCode(byteIndex, imageData);
                if(!spanRight && compareColor(ocolor, color, tolerance)){
                    [points pushFrontX:(x + 1) andY:y];
                    
                    spanRight = YES;
                }else if(spanRight && !compareColor(ocolor, color, tolerance)){
                    spanRight = NO;
                }
                // we can't go right. Add the point on the antialiasing list
                if(!spanRight && !compareColor(ocolor, color, tolerance) && !compareColor(ncolor, color, tolerance)){
                    [antiAliasingPoints pushFrontX:(x + 1) andY:y];
                }
            }
            y++;
            
            if(y < height){
                byteIndex = (bytesPerRow * roundf(y)) + roundf(x) * bytesPerPixel;
                
                color = getColorCode(byteIndex, imageData);
            }
        }
        
        if (y<height){
            byteIndex = (bytesPerRow * roundf(y)) + roundf(x) * bytesPerPixel;
            color = getColorCode(byteIndex, imageData);
            
            if (!compareColor(ocolor, color, 0))
                [antiAliasingPoints pushFrontX:x andY:y];
        }
    }
    
    unsigned int antialiasColor = getColorCodeFromUIColor(newColor,bitmapInfo&kCGBitmapByteOrderMask );
    int red1   = ((0xff000000 & antialiasColor) >> 24);
    int green1 = ((0x00ff0000 & antialiasColor) >> 16);
    int blue1  = ((0x0000ff00 & antialiasColor) >> 8);
    int alpha1 =  (0x000000ff & antialiasColor);
    
    while ([antiAliasingPoints popFront:&x andY:&y] != INVALID_NODE_CONTENT)
    {
        byteIndex = (bytesPerRow * roundf(y)) + roundf(x) * bytesPerPixel;
        color = getColorCode(byteIndex, imageData);
        
        if (!compareColor(ncolor, color, 0))
        {
            int red2   = ((0xff000000 & color) >> 24);
            int green2 = ((0x00ff0000 & color) >> 16);
            int blue2 = ((0x0000ff00 & color) >> 8);
            int alpha2 =  (0x000000ff & color);
            
            if (antiAlias) {
                imageData[byteIndex + 0] = (red1 + red2) / 2;
                imageData[byteIndex + 1] = (green1 + green2) / 2;
                imageData[byteIndex + 2] = (blue1 + blue2) / 2;
                imageData[byteIndex + 3] = (alpha1 + alpha2) / 2;
            } else {
                imageData[byteIndex + 0] = red2;
                imageData[byteIndex + 1] = green2;
                imageData[byteIndex + 2] = blue2;
                imageData[byteIndex + 3] = alpha2;
            }
            
            
        }
        
        // left
        if (x>0)
        {
            byteIndex = (bytesPerRow * roundf(y)) + roundf(x - 1) * bytesPerPixel;
            color = getColorCode(byteIndex, imageData);
            
            if (!compareColor(ncolor, color, 0))
            {
                int red2   = ((0xff000000 & color) >> 24);
                int green2 = ((0x00ff0000 & color) >> 16);
                int blue2 = ((0x0000ff00 & color) >> 8);
                int alpha2 =  (0x000000ff & color);
                
                if (antiAlias) {
                    imageData[byteIndex + 0] = (red1 + red2) / 2;
                    imageData[byteIndex + 1] = (green1 + green2) / 2;
                    imageData[byteIndex + 2] = (blue1 + blue2) / 2;
                    imageData[byteIndex + 3] = (alpha1 + alpha2) / 2;
                } else {
                    imageData[byteIndex + 0] = red2;
                    imageData[byteIndex + 1] = green2;
                    imageData[byteIndex + 2] = blue2;
                    imageData[byteIndex + 3] = alpha2;
                }
            }
        }
        if (x<width)
        {
            byteIndex = (bytesPerRow * roundf(y)) + roundf(x + 1) * bytesPerPixel;
            color = getColorCode(byteIndex, imageData);
            
            if (!compareColor(ncolor, color, 0))
            {
                int red2   = ((0xff000000 & color) >> 24);
                int green2 = ((0x00ff0000 & color) >> 16);
                int blue2 = ((0x0000ff00 & color) >> 8);
                int alpha2 =  (0x000000ff & color);
                
                if (antiAlias) {
                    imageData[byteIndex + 0] = (red1 + red2) / 2;
                    imageData[byteIndex + 1] = (green1 + green2) / 2;
                    imageData[byteIndex + 2] = (blue1 + blue2) / 2;
                    imageData[byteIndex + 3] = (alpha1 + alpha2) / 2;
                } else {
                    imageData[byteIndex + 0] = red2;
                    imageData[byteIndex + 1] = green2;
                    imageData[byteIndex + 2] = blue2;
                    imageData[byteIndex + 3] = alpha2;
                }
                
            }
            
        }
        
        if (y>0)
        {
            byteIndex = (bytesPerRow * roundf(y - 1)) + roundf(x) * bytesPerPixel;
            color = getColorCode(byteIndex, imageData);
            
            if (!compareColor(ncolor, color, 0))
            {
                int red2   = ((0xff000000 & color) >> 24);
                int green2 = ((0x00ff0000 & color) >> 16);
                int blue2 = ((0x0000ff00 & color) >> 8);
                int alpha2 =  (0x000000ff & color);
                
                if (antiAlias) {
                    imageData[byteIndex + 0] = (red1 + red2) / 2;
                    imageData[byteIndex + 1] = (green1 + green2) / 2;
                    imageData[byteIndex + 2] = (blue1 + blue2) / 2;
                    imageData[byteIndex + 3] = (alpha1 + alpha2) / 2;
                } else {
                    imageData[byteIndex + 0] = red2;
                    imageData[byteIndex + 1] = green2;
                    imageData[byteIndex + 2] = blue2;
                    imageData[byteIndex + 3] = alpha2;
                }
                
            }
        }
        
        if (y<height)
        {
            byteIndex = (bytesPerRow * roundf(y + 1)) + roundf(x) * bytesPerPixel;
            if (byteIndex + 3 >= width * height * 4){
                break;
            }
            color = getColorCode(byteIndex, imageData);
            
            if (!compareColor(ncolor, color, 0))
            {
                int red2   = ((0xff000000 & color) >> 24);
                int green2 = ((0x00ff0000 & color) >> 16);
                int blue2 = ((0x0000ff00 & color) >> 8);
                int alpha2 =  (0x000000ff & color);
                
                
                
                if (antiAlias) {
                    imageData[byteIndex + 0] = (red1 + red2) / 2;
                    imageData[byteIndex + 1] = (green1 + green2) / 2;
                    imageData[byteIndex + 2] = (blue1 + blue2) / 2;
                    imageData[byteIndex + 3] = (alpha1 + alpha2) / 2;
                } else {
                    imageData[byteIndex + 0] = red2;
                    imageData[byteIndex + 1] = green2;
                    imageData[byteIndex + 2] = blue2;
                    imageData[byteIndex + 3] = alpha2;
                }
                
            }
            
        }
    }
    
    //Convert Flood filled image row data back to UIImage object.
    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    UIImage *resultImg = [UIImage imageWithCGImage:newCGImage scale:image.scale orientation:UIImageOrientationUp];
    [self revokePointsWith:tapPoint];
    [self freeData:imageData content:context imageRef:newCGImage colorSpace:colorSpace];
    return resultImg;
}


unsigned int getColorCode (unsigned int byteIndex, unsigned char *imageData)
{
    unsigned int red   = imageData[byteIndex];
    unsigned int green = imageData[byteIndex + 1];
    unsigned int blue  = imageData[byteIndex + 2];
    unsigned int alpha = imageData[byteIndex + 3];
    return (red << 24) | (green << 16) | (blue << 8) | alpha;
}
bool compareColor (unsigned int color1, unsigned int color2, int tolorance)
{
    if(color1 == color2){
        return true;
    }
    int red1   = ((0xff000000 & color1) >> 24);
    int green1 = ((0x00ff0000 & color1) >> 16);
    int blue1  = ((0x0000ff00 & color1) >> 8);
    int alpha1 =  (0x000000ff & color1);
    
    int red2   = ((0xff000000 & color2) >> 24);
    int green2 = ((0x00ff0000 & color2) >> 16);
    int blue2  = ((0x0000ff00 & color2) >> 8);
    int alpha2 =  (0x000000ff & color2);
    
    int diffRed   = abs(red2   - red1);
    int diffGreen = abs(green2 - green1);
    int diffBlue  = abs(blue2  - blue1);
    int diffAlpha = abs(alpha2 - alpha1);
    
    if( diffRed   > tolorance ||
       diffGreen > tolorance ||
       diffBlue  > tolorance ||
       diffAlpha > tolorance  )
    {
        return false;
    }
    
    return true;
}

unsigned int getColorCodeFromUIColor(UIColor *color, CGBitmapInfo orderMask)
{
    //Convert newColor to RGBA value so we can save it to image.
    int newRed, newGreen, newBlue, newAlpha;
    
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    if(CGColorGetNumberOfComponents(color.CGColor) == 2)
    {
        newRed   = newGreen = newBlue = components[0] * 255;
        newAlpha = components[1] * 255;
    }
    else if (CGColorGetNumberOfComponents(color.CGColor) == 4)
    {
        if (orderMask == kCGBitmapByteOrder32Little)
        {
            newRed   = components[2] * 255;
            newGreen = components[1] * 255;
            newBlue  = components[0] * 255;
            newAlpha = 255;
        }
        else
        {
            newRed   = components[0] * 255;
            newGreen = components[1] * 255;
            newBlue  = components[2] * 255;
            newAlpha = 255;
        }
    }
    else
    {
        newRed   = newGreen = newBlue = 0;
        newAlpha = 255;
    }
    
    unsigned int ncolor = (newRed << 24) | (newGreen << 16) | (newBlue << 8) | newAlpha;
    
    return ncolor;
}

-(void)freeData:(unsigned char *)imageData content:(CGContextRef)context imageRef:(CGImageRef)image colorSpace:(CGColorSpaceRef)color{
    NSLog(@"%s,%@,%@,%@",imageData,context,image,color);
    if (image != NULL) {
        CGImageRelease(image);
    }
    if (context != NULL) {
        CGContextRelease(context);
    }
    if (color != NULL) {
        CGColorSpaceRelease(color);
    }
    if (imageData != nil) {
        free(imageData);
    }
    
}

- (void)revokePointsWith:(CGPoint )point {
    self.lastPoint = point;
    BOOL isadd = YES;
    for (NSNumber *pointNum in self.revokePoints) {
        CGPoint savePoint = [pointNum CGPointValue];
        if ( savePoint.x == point.x && savePoint.y == point.y) {
            isadd = NO;
            [self.revokePoints removeObject:pointNum];
            break;
        }
    }
    if (isadd) {
        [self.revokePoints addObject:@(point)];
    }
    
    if (self.revokePoints.count == 0) {
        [_revokePoints addObject:@(point)];
    }
    
}
- (NSMutableArray *)revokePoints {
    if (!_revokePoints) {
        _revokePoints = [NSMutableArray array];
    }
    return _revokePoints;
}

@end
