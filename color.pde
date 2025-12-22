//this is the funciton for color
// color.pde - color processing functions
class ColorProcessor {
  
  PImage process(PImage src, float temp, float tint, float vibrance, float sat, color shadowT, color midT, color highT) {
    PImage dest = src.copy();
    dest.loadPixels();
    
    for (int i = 0; i < dest.pixels.length; i++) {
      color c = dest.pixels[i];
      float r = red(c);
      float g = green(c);
      float b = blue(c);
      
      // 1. Temperature & Tint
      r += temp; 
      b -= temp;
      g += tint;
      
      // 2. Vibrance & Saturation
      // Vibrance mainly affects unsaturated pixels
      float maxVal = max(r, max(g, b));
      float minVal = min(r, min(g, b));
      float l = (maxVal + minVal) / 2.0;
      float s = (maxVal - minVal) / (255 - abs(2*l - 255) + 0.01);
      
      float vibAmount = (1.0 - s) * (vibrance / 100.0);
      float totalSat = 1.0 + (sat / 100.0) + vibAmount;
      
      // 简化的 HSL 饱和度调整
      r = l + (r - l) * totalSat;
      g = l + (g - l) * totalSat;
      b = l + (b - l) * totalSat;
      
      // 3. Split Toning
      float lum = (r * 0.299 + g * 0.587 + b * 0.114) / 255.0;
      if (lum < 0.33) { // Shadows
        float w = map(lum, 0, 0.33, 1, 0);
        r += (red(shadowT)-128) * w * 0.5;
        g += (green(shadowT)-128) * w * 0.5;
        b += (blue(shadowT)-128) * w * 0.5;
      } else if (lum < 0.66) { // Midtones
        float w = 1.0 - abs(lum - 0.5) * 6.0;
        r += (red(midT)-128) * max(0, w) * 0.5;
        g += (green(midT)-128) * max(0, w) * 0.5;
        b += (blue(midT)-128) * max(0, w) * 0.5;
      } else { // Highlights
        float w = map(lum, 0.66, 1.0, 0, 1);
        r += (red(highT)-128) * w * 0.5;
        g += (green(highT)-128) * w * 0.5;
        b += (blue(highT)-128) * w * 0.5;
      }
      
      dest.pixels[i] = color(constrain(r,0,255), constrain(g,0,255), constrain(b,0,255));
    }
    dest.updatePixels();
    return dest;
  }
}