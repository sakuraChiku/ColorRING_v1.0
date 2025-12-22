// basics_sidebar.pde
// UI Controller for Basic Adjustments (Histogram, Exposure, Contrast, Zones)

Basics_Sidebar basics_sidebar;

void setupBasicsSidebar() {
  basics_sidebar = new Basics_Sidebar();
}

// Global hooks called by ColorRING.pde
void basics_sidebar_shape() { if (basics_sidebar != null) basics_sidebar.shape(); }
void basics_sidebar_mousePressed() { if (basics_sidebar != null) basics_sidebar.mousePressed(); }
void basics_sidebar_mouseDragged() { if (basics_sidebar != null) basics_sidebar.mouseDragged(); }
void basics_sidebar_mouseReleased() { if (basics_sidebar != null) basics_sidebar.mouseReleased(); }

class Basics_Sidebar {
  // UI Layout
  float left = 910;
  float top = 110;
  float right = 1190;
  float w = 280;
  
  // Parameters
  float exposure = 0.0;    // Range: -2.0 to 2.0
  float contrast = 0.0;    // Range: -50 to 50
  
  // 6 Zones: Whites, Highlights, Lights, Darks, Shadows, Blacks
  // Range: -50 to 50
  float[] zoneValues = {0, 0, 0, 0, 0, 0}; 
  String[] zoneLabels = {"Whites", "Highlights", "Lights", "Darks", "Shadows", "Blacks"};
  
  // Interaction State
  int draggingSlider = -1; // -1:None, 0:Exp, 1:Con, 2-7:Zones
  boolean updateNeeded = false;

  Basics_Sidebar() {
     // Default values
  }

  void shape() {
    pushStyle();
    
    // 1. Background Panel (Dark Lightroom Style)
    noStroke();
    fill(40); // Dark Gray
    rectMode(CORNERS);
    rect(left, top, width, height); // Fill to bottom right
    
    rectMode(CORNER);
    
    // 2. Histogram Area
    fill(20);
    rect(left + 10, top + 10, w - 20, 100);
    
    // Draw Live Histogram
    if (basics != null) {
      // Recompute only if needed or periodically (optimized)
      if (frameCount % 5 == 0) basics.computeHistogram(); 
      basics.drawHistogram(left + 10, top + 10, w - 20, 100);
    }
    
    // 3. Basic Tone Sliders
    fill(220);
    textSize(14);
    textAlign(LEFT, BASELINE);
    text("Tone", left + 10, top + 135);
    
    drawControlSlider("Exposure", exposure, -2.0, 2.0, left + 10, top + 150, 0);
    drawControlSlider("Contrast", contrast, -50, 50, left + 10, top + 190, 1);
    
    // Divider
    stroke(60);
    line(left + 10, top + 225, right - 10, top + 225);
    
    // 4. Zone Adjustments (Equalizer style)
    noStroke();
    fill(220);
    text("Zone Equalizer", left + 90, top + 245);
    
    float startY = top + 270;
    for(int i=0; i<6; i++) {
       drawControlSlider(zoneLabels[i], zoneValues[i], -50, 50, left + 10, startY + i * 40, 2 + i);
    }

    // 5. Reset Button
    drawButton("Reset All", left + 10, startY + 6 * 40 + 10);

    // 6. Instruction (Requested feature)
    fill(100);
    textSize(10);
    text("INSTRUCTION: Adjust exposure to fix lighting. Use Zone Equalizer to fine-tune specific brightness ranges without affecting the whole image.", left + 10, height - 20, w - 20, 40);

    popStyle();
    
    // Apply processing if changed
    if (updateNeeded) {
      applyToCanvas();
      updateNeeded = false;
    }
  }

  // Helper to draw consistent sliders
  void drawControlSlider(String label, float val, float min, float max, float x, float y, int id) {
    float sliderW = 160;
    float sliderX = x + 80;
    
    // Label
    fill(180);
    textSize(12);
    textAlign(LEFT, CENTER);
    text(label, x, y);
    
    // Rail
    stroke(80);
    strokeWeight(2);
    line(sliderX, y, sliderX + sliderW, y);
    
    // Knob
    float kx = map(val, min, max, sliderX, sliderX + sliderW);
    noStroke();
    if (id == draggingSlider) fill(255); else fill(180);
    ellipse(kx, y, 12, 12);
    
    // Value Display
    fill(150);
    textAlign(RIGHT, CENTER);
    if (id == 0) text(nf(val, 1, 2), x + w - 25, y); // Exposure gets 2 decimals
    else text(int(val), x + w - 25, y);
  }
  
  void drawButton(String label, float x, float y) {
    float bw = 100;
    float bh = 25;
    fill(60);
    stroke(80);
    if (mouseX > x && mouseX < x+bw && mouseY > y && mouseY < y+bh) {
       fill(80); // Hover
    }
    rectMode(CORNER);
    rect(x, y, bw, bh, 4);
    
    fill(200);
    textAlign(CENTER, CENTER);
    text(label, x + bw/2, y + bh/2);
  }

  void mousePressed() {
    // Check Sliders
    if (checkSliderClick(exposure, -2.0, 2.0, left + 10, top + 150, 0)) return;
    if (checkSliderClick(contrast, -50, 50, left + 10, top + 190, 1)) return;
    
    float startY = top + 270;
    for(int i=0; i<6; i++) {
       if (checkSliderClick(zoneValues[i], -50, 50, left + 10, startY + i * 40, 2 + i)) return;
    }
    
    // Check Reset Button
    float btnY = startY + 6 * 40 + 10;
    if (mouseX > left + 10 && mouseX < left + 110 && mouseY > btnY && mouseY < btnY + 25) {
       resetAll();
    }
  }
  
  boolean checkSliderClick(float val, float min, float max, float x, float y, int id) {
    float sliderX = x + 80;
    float sliderW = 160;
    float kx = map(val, min, max, sliderX, sliderX + sliderW);
    // Hit detection around knob
    if (dist(mouseX, mouseY, kx, y) < 15 || (mouseX >= sliderX && mouseX <= sliderX + sliderW && abs(mouseY - y) < 10)) {
      draggingSlider = id;
      updateValueFromMouse(min, max, sliderX, sliderW);
      return true;
    }
    return false;
  }

  void mouseDragged() {
    if (draggingSlider != -1) {
      float sliderX = left + 10 + 80;
      float sliderW = 160;
      
      if (draggingSlider == 0) exposure = updateValueFromMouse(-2.0, 2.0, sliderX, sliderW);
      else if (draggingSlider == 1) contrast = updateValueFromMouse(-50, 50, sliderX, sliderW);
      else if (draggingSlider >= 2 && draggingSlider <= 7) {
        int zoneIdx = draggingSlider - 2;
        zoneValues[zoneIdx] = updateValueFromMouse(-50, 50, sliderX, sliderW);
      }
      updateNeeded = true;
    }
  }

  float updateValueFromMouse(float min, float max, float sx, float sw) {
    float val = map(mouseX, sx, sx + sw, min, max);
    return constrain(val, min, max);
  }

  void mouseReleased() {
    draggingSlider = -1;
    // Final high-quality apply could happen here if needed
  }
  
  void resetAll() {
    exposure = 0;
    contrast = 0;
    for(int i=0; i<6; i++) zoneValues[i] = 0;
    updateNeeded = true;
  }
  
  // Link to the Backend (Basics.pde)
  void applyToCanvas() {
    if (basics != null && importer != null && importer.originalCanvas != null) {
       // Get clean source
       PImage src = importer.originalCanvas.get();
       
       // Process using our new Basics engine
       PImage result = basics.applyAdjustments(src, exposure, contrast, zoneValues);
       
       // Send back to importer display
       importer.canvas.beginDraw();
       importer.canvas.image(result, 0, 0);
       importer.canvas.endDraw();
       
       // Update the display image reference
       importer.img = importer.canvas.get();
       // importer.scaleAndPositionImage(); // Optional: keeps position stable
    }
  }
}