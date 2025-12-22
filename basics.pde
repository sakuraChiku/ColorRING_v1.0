// basics.pde - 彻底重构版
Basics basics;

void setupBasics() {
  basics = new Basics();
}

class Basics {
  int[] hist = new int[256]; // 存储亮度直方图
  int maxHist = 0;

  Basics() {}

  // 1. 修复直方图：基于亮度(Luminance)计算
  void computeHistogram() {
    if (importer == null || importer.img == null) return;
    for (int i = 0; i < 256; i++) hist[i] = 0;
    maxHist = 0;

    PImage img = importer.img;
    img.loadPixels();
    for (int i = 0; i < img.pixels.length; i++) {
      int c = img.pixels[i];
      // 使用感知亮度公式: Y = 0.299R + 0.587G + 0.114B
      int bright = int(red(c)*0.299 + green(c)*0.587 + blue(c)*0.114);
      hist[bright]++;
      if (hist[bright] > maxHist) maxHist = hist[bright];
    }
  }

  // 2. 优化图片调节逻辑：修复自动裁切问题
  // 我们直接返回处理后的 PImage，不再在此处进行缩放，由 Importer 处理显示缩放
  PImage applyAdjustments(PImage src, float exposure, float contrast, float[] zoneAdjusts) {
    if (src == null) return null;
    PImage dest = src.copy();
    dest.loadPixels();
    
    float contrastFactor = (1.2 * (contrast + 100)) / 100.0; // 优化对比度公式
    
    for (int i = 0; i < dest.pixels.length; i++) {
      color c = dest.pixels[i];
      float r = red(c);
      float g = green(c);
      float b = blue(c);
      
      // A. 曝光 (Exposure) - 线性增益
      float expF = pow(2, exposure); 
      r *= expF; g *= expF; b *= expF;
      
      // B. 分区调节 (Zone Adjust) - 模拟 Lightroom 的阴影/高光调节
      float lum = (r + g + b) / 3.0;
      int zone = floor(constrain(lum / 42.6, 0, 5)); // 将 0-255 分为 6 个区
      float adj = zoneAdjusts[zone] * 2.0;
      r += adj; g += adj; b += adj;

      // C. 对比度 (Contrast) - 以 128 为中心缩放
      r = (r - 128) * contrastFactor + 128;
      g = (g - 128) * contrastFactor + 128;
      b = (b - 128) * contrastFactor + 128;

      dest.pixels[i] = color(constrain(r, 0, 255), constrain(g, 0, 255), constrain(b, 0, 255));
    }
    dest.updatePixels();
    return dest;
  }
  
  // 绘制直方图 UI
  void drawHistogram(float x, float y, float w, float h) {
    pushStyle();
    fill(50, 150);
    noStroke();
    rect(x, y, w, h);
    stroke(200, 200, 255);
    for (int i = 0; i < 256; i++) {
      float lineH = map(hist[i], 0, maxHist, 0, h);
      line(x + map(i, 0, 255, 0, w), y + h, x + map(i, 0, 255, 0, w), y + h - lineH);
    }
    popStyle();
  }
}