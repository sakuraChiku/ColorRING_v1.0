// basics.pde
// Image analysis & adjustment utilities used by the Basics sidebar

Basics basics;

void setupBasics() {
  basics = new Basics();
}

class Basics {
  int countR, countG, countB;
  int imgW, imgH;

  Basics() {
    countR = countG = countB = 0;
  }

  // compute 3-color histogram (red/green/blue groups) and store counts
  void computeHistogram() {
    countR = countG = countB = 0;
    if (importer == null || importer.img == null) return;
    PImage img = importer.img;
    img.loadPixels();
    imgW = img.width; imgH = img.height;
    
    colorMode(HSB, 360, 100, 100);
    for (int i = 0; i < img.pixels.length; i++) {
      color c = img.pixels[i];
      float h = hue(c);
      // classify to nearest of red(0), green(120), blue(240)
      float dR = min(abs(h - 0), abs(h - 360));
      float dG = abs(h - 120);
      float dB = abs(h - 240);
      if (dR <= dG && dR <= dB) countR++; else if (dG <= dR && dG <= dB) countG++; else countB++;
    }
    colorMode(RGB, 255);
  }

  // apply adjustments to a copy of originalCanvas and commit when requested
  PGraphics applyAdjustments(float exposure, float contrast, float[] zoneAdjusts) {
    if (importer == null || importer.originalCanvas == null) return null;
    PGraphics src = importer.originalCanvas;
    PGraphics out = createGraphics(src.width, src.height);
    // draw the source into out first to ensure pixels array is initialized and any background preserved
    out.beginDraw();
    out.image(src, 0, 0);
    out.loadPixels();
    src.loadPixels();
    
    // Set color mode once before the loop for performance
    colorMode(HSB, 360, 100, 100);
    
    // iterate pixels and modify brightness based on exposure/contrast/zone
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        int idx = x + y * src.width;
        color c = src.pixels[idx];
        
        float h = hue(c);
        float s = saturation(c);
        float b = brightness(c); // 0..100
        // determine tonal zone by brightness (PS-like thresholds)
        // thresholds (0-100): blacks 0-21, shadows 22-37, darks 38-63, lights 64-78, highlights 79-90, whites 91-100
        int zone = 2; // default light tones
        if (b >= 91) zone = 0; // whites
        else if (b >= 79) zone = 1; // highlights
        else if (b >= 64) zone = 2; // lights
        else if (b >= 38) zone = 3; // darks
        else if (b >= 22) zone = 4; // shadows
        else zone = 5; // blacks
        // Map zone indices to slider order: [whites, highlights, lights, darks, shadows, blacks]
        float zoneAdj = zoneAdjusts[zone]; // -100..100
        // convert adjustments into effective brightness change
        float cFactor = 1.0 + (contrast / 100.0);
        float exposureShift = (exposure - 1.0) * 50.0; // exposure 1.0 -> 0

    
        float zoneShift = zoneAdj * 0.5; // scale zone effect
        float newB = (b - 50.0) * cFactor + 50.0 + exposureShift + zoneShift;
        newB = constrain(newB, 0, 100);
        
        color nc = color(h, s, newB);
        out.pixels[idx] = nc;
      }
    }
    
    // Restore color mode
    colorMode(RGB, 255);
    
    out.updatePixels();
    out.endDraw();
    return out;
  }

  // Create a small-resolution per-pixel preview to show accurate tonal adjustments interactively.
  PImage applyAdjustmentsPreview(float exposure, float contrast, float[] zoneAdjusts, int targetW) {
    if (importer == null || importer.originalCanvas == null) return null;
    PGraphics src = importer.originalCanvas;
    
    try {
      float ar = (float)src.width / (float)src.height;
      int w = targetW;
      int h = max(1, int(targetW / ar));
      
      // Use PImage instead of PGraphics for lighter weight preview
      PImage out = createImage(w, h, RGB);
      // Copy and scale content from src to out
      out.copy(src, 0, 0, src.width, src.height, 0, 0, w, h);
      out.loadPixels();
      
      // Set color mode once before the loop
      colorMode(HSB, 360, 100, 100);
      
      int pixelCount = out.pixels.length;

      // operate on out.pixels directly
      for (int i = 0; i < pixelCount; i++) {
          color c = out.pixels[i];
          
          float hh = hue(c);
          float s = saturation(c);
          float b = brightness(c);
          int zone = 2;
          if (b >= 91) zone = 0;
          else if (b >= 79) zone = 1;
          else if (b >= 64) zone = 2;
          else if (b >= 38) zone = 3;
          else if (b >= 22) zone = 4;
          else zone = 5;
          float zAdj = zoneAdjusts[zone];
          float cFactor = 1.0 + (contrast / 100.0);
          float exposureShift = (exposure - 1.0) * 50.0;
          float zoneShift = zAdj * 0.5;
          float newB = (b - 50.0) * cFactor + 50.0 + exposureShift + zoneShift;
          newB = constrain(newB, 0, 100);
          
          color nc = color(hh, s, newB);
          out.pixels[i] = nc;
      }
      
      // Restore color mode
      colorMode(RGB, 255);
      
      out.updatePixels();
      return out;
      
    } catch (Exception e) {
      println("ERROR in applyAdjustmentsPreview: " + e.toString());
      e.printStackTrace();
      return null;
    }
  }
}
