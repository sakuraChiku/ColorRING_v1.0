// basics_sidebar.pde
// Sidebar UI showing RGB histogram and exposure/contrast / tonal zone controls

class Basics_Sidebar {
  float left = 910, top = 110, right = 1190, bottom = 720;

  // histogram data
  int rCount = 0, gCount = 0, bCount = 0;

  // exposure & contrast
  float exposure = 1.0; // 0.5 .. 1.5
  float contrast = 0; // -100 .. 100

  // tonal zone adjustments (whites, highlights, lights, darks, shadows, blacks)
  float[] zoneAdj = {0,0,0,0,0,0}; // -100..100

  // UI slider params
  float slider_x, slider_w = 220;
  float knob_r = 8;
  int dragging = -1; // 0=exposure,1=contrast, 10-15 zones
  // cached slider Y positions (kept in shape() so hit tests match visuals)
  float exY = 0;
  float cY = 0;
  float[] zoneY = new float[6];

  Basics_Sidebar() {
    slider_x = left + 30;
  }

  void shape() {
    pushStyle();
    fill(255);
    rectMode(CORNERS);
    rect(left, top, right, bottom);

    // Title
    fill(0);
    textSize(22);
    text("Basics", left + 8, top + 24);

    // Compute histogram from basics helper
    if (basics == null) setupBasics();
    basics.computeHistogram();
    rCount = basics.countR;
    gCount = basics.countG;
    bCount = basics.countB;

    // Draw a simple 3-bar histogram
    int histX = int(left + 20);
    int histY = int(top + 40);
    int histW = int(right - left - 40);
    int histH = 80;
    // background (use CORNER mode for width/height)
    rectMode(CORNER);
    fill(240);
    rect(histX, histY, histW, histH);

    int maxCount = max(rCount, max(gCount, bCount));
    if (maxCount == 0) maxCount = 1;
    // three bars side by side
    float barW = histW / 6.0;
    float gap = barW;
    // red
    float rH = map(rCount, 0, maxCount, 0, histH);
    fill(200, 30, 30);
    rect(histX + gap*0.5, histY + histH - rH, barW, rH);
    // green
    float gH = map(gCount, 0, maxCount, 0, histH);
    fill(30, 180, 30);
    rect(histX + gap*2.0, histY + histH - gH, barW, gH);
    // blue
    float bH = map(bCount, 0, maxCount, 0, histH);
    fill(30, 80, 200);
    rect(histX + gap*3.5, histY + histH - bH, barW, bH);
    // restore rect mode to CORNERS for other callers
    rectMode(CORNERS);

    // Exposure slider
    textSize(14);
    fill(0);
    text("Exposure", left + 8, histY + histH + 22);
    exY = histY + histH + 30;
    drawSlider(exY, map(exposure, 0.5, 1.5, 0, slider_w));
    fill(0); text(nf(exposure,1,2)+"x", slider_x + slider_w + 8, exY + 4);

    // Contrast slider
    text("Contrast", left + 8, exY + 30);
    cY = exY + 38;
    drawSlider(cY, map(contrast, -100, 100, 0, slider_w));
    fill(0); text(int(contrast), slider_x + slider_w + 8, cY + 4);

    // Tonal zones
    text("Tonal Zones (white -> black)", left + 8, cY + 36);
    String[] names = {"Whites","Highlights","Lights","Darks","Shadows","Blacks"};
    for (int i = 0; i < 6; i++) {
      zoneY[i] = cY + 60 + i*34;
      float y = zoneY[i];
      fill(0); text(names[i], left + 8, y + 4);
      drawSlider(y, map(zoneAdj[i], -100, 100, 0, slider_w));
      fill(0); text(int(zoneAdj[i]), slider_x + slider_w + 8, y + 4);
    }

    // Reset button (centered). Adjustments preview live during drag; no Apply commit button.
    float btnW = 120; float btnH = 28;
    float totalW = btnW; // only one button
    float centerX = (left + right) / 2.0;
    float startX = centerX - totalW/2.0;
    float btnX = startX; float btnY = bottom - 60;
    rectMode(CORNER);
    fill(240); rect(btnX, btnY, btnW, btnH, 4);
    fill(0); textAlign(CENTER, CENTER); text("Reset", btnX + btnW/2, btnY + btnH/2);
    textAlign(LEFT, BASELINE);
    rectMode(CORNERS);

    popStyle();
  }

  void drawSlider(float bar_y, float knob_x) {
    // rail
    stroke(150); strokeWeight(1);
    line(slider_x, bar_y, slider_x + slider_w, bar_y);
    noStroke(); fill(200);
    rectMode(CORNER);
    rect(slider_x, bar_y - 4, slider_w, 8);
    rectMode(CORNERS);
    fill(100);
    circle(slider_x + knob_x, bar_y, knob_r*2);
  }

  void mousePressed() {
    // check sliders: exposure (index 0), contrast (1), zones 10..15
    if (mouseX >= slider_x && mouseX <= slider_x + slider_w) {
      // exposure
      if (abs(mouseY - exY) < 12) { dragging = 0; updateFromMouse(); return; }
      // contrast
      if (abs(mouseY - cY) < 12) { dragging = 1; updateFromMouse(); return; }
      // tonal zones
      for (int i = 0; i < 6; i++) {
        if (abs(mouseY - zoneY[i]) < 12) { dragging = 10 + i; updateFromMouse(); return; }
      }
    }
    // Reset button (centered) - just reset adjustments and preview
    float btnW = 120; float btnH = 28;
    float totalW = btnW; // only one button
    float centerX = (left + right) / 2.0;
    float startX = centerX - totalW/2.0;
    float btnX = startX; float btnY = bottom - 60;
    if (mouseX >= btnX && mouseX <= btnX+btnW && mouseY >= btnY && mouseY <= btnY+btnH) {
      // Reset adjustments and restore preview to original canvas
      exposure = 1.0; contrast = 0;
      for (int i=0;i<6;i++) zoneAdj[i]=0;
      if (importer != null && importer.originalCanvas != null) {
        importer.canvas = importer.originalCanvas;
        importer.img = importer.canvas.get();
        importer.scaleAndPositionImage();
        importer.clearPreview();
      }
      return;
    }
  }

  void mouseDragged() {
    if (dragging >= 0) updateFromMouse();
  }

  void mouseReleased() { dragging = -1; }

  void updateFromMouse() {
    if (dragging == 0) {
      float v = constrain((mouseX - slider_x) / slider_w, 0, 1);
      exposure = map(v, 0, 1, 0.5, 1.5);
    } else if (dragging == 1) {
      float v = constrain((mouseX - slider_x) / slider_w, 0, 1);
      contrast = map(v, 0, 1, -100, 100);
    } else if (dragging >= 10) {
      int idx = dragging - 10;
      float v = constrain((mouseX - slider_x) / slider_w, 0, 1);
      zoneAdj[idx] = map(v, 0, 1, -100, 100);
    }
    // Live preview: apply adjustments to originalCanvas and show in importer.canvas (do not commit)
    if (importer != null) {
        if (basics != null && importer != null && importer.originalCanvas != null) {
          float[] zones = new float[6]; for (int i=0;i<6;i++) zones[i]=zoneAdj[i];
          int targetW = min(400, importer.originalCanvas.width);
          PImage preview = basics.applyAdjustmentsPreview(exposure, contrast, zones, targetW);
          if (preview != null) {
            importer.setPreview(1.0, true); // keep previewActive true
            importer.setPreviewCanvas(preview);
          }
        }
    }
  }
}

Basics_Sidebar basics_sidebar = new Basics_Sidebar();

// Forwarders
void basics_sidebar_shape() { if (basics_sidebar != null) basics_sidebar.shape(); }
void basics_sidebar_mousePressed() { if (basics_sidebar != null) basics_sidebar.mousePressed(); }
void basics_sidebar_mouseDragged() { if (basics_sidebar != null) basics_sidebar.mouseDragged(); }
void basics_sidebar_mouseReleased() { if (basics_sidebar != null) basics_sidebar.mouseReleased(); }
