// details.pde
class DetailsProcessor {
  
  // Added 'texture' (grain) parameter
  PImage applyDetails(PImage src, float sharpen, float blur, float clarity, float texture) {
    PImage out = src.copy();
    
    // 1. Blur
    if (blur > 0) {
      out.filter(BLUR, blur / 10.0);
    }
    
    // 2. Sharpen
    if (sharpen > 0) {
      float s = sharpen / 50.0;
      float[][] kernel = { { -s, -s, -s }, { -s, 1+8*s, -s }, { -s, -s, -s } };
      out = convolve(out, kernel);
    }
    
    // 3. Clarity (Local Contrast)
    if (abs(clarity) > 1) {
      PImage blurred = out.copy();
      blurred.filter(BLUR, 3);
      out.loadPixels();
      blurred.loadPixels();
      float factor = clarity / 100.0;
      for (int i=0; i<out.pixels.length; i++) {
        color c = out.pixels[i];
        color cb = blurred.pixels[i];
        float r = red(c) + (red(c) - red(cb)) * factor;
        float g = green(c) + (green(c) - green(cb)) * factor;
        float b = blue(c) + (blue(c) - blue(cb)) * factor;
        out.pixels[i] = color(constrain(r,0,255), constrain(g,0,255), constrain(b,0,255));
      }
      out.updatePixels();
    }
    
    // 4. Texture / Grain
    // Adds random noise to simulate texture
    if (texture > 0) {
      out.loadPixels();
      for (int i=0; i<out.pixels.length; i++) {
         float noiseVal = random(-texture, texture) * 0.5;
         color c = out.pixels[i];
         out.pixels[i] = color(constrain(red(c)+noiseVal,0,255), 
                               constrain(green(c)+noiseVal,0,255), 
                               constrain(blue(c)+noiseVal,0,255));
      }
      out.updatePixels();
    }
    
    return out;
  }

  PImage convolve(PImage img, float[][] kernel) {
    PImage res = createImage(img.width, img.height, RGB);
    img.loadPixels();
    // Optimization: Skip borders to avoid bounds checks inside loop
    for (int y = 1; y < img.height-1; y++) {
      for (int x = 1; x < img.width-1; x++) {
        float r = 0, g = 0, b = 0;
        // Unroll loop slightly for speed
        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            int idx = (y + ky) * img.width + (x + kx);
            color c = img.pixels[idx];
            float k = kernel[ky+1][kx+1];
            r += red(c) * k;
            g += green(c) * k;
            b += blue(c) * k;
          }
        }
        res.pixels[y * img.width + x] = color(constrain(r,0,255), constrain(g,0,255), constrain(b,0,255));
      }
    }
    res.updatePixels();
    return res;
  }
}