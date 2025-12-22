// Sidebar for crop / scale / rotate
class Cut_Sidebar {
  // UI positions
  float left = 910;
  float top = 110;
  float right = 1190;
  float bottom = 590;

  // sliders and values
  float scaleVal = 1.0; // multiplicative
  float rotationDeg = 0;

  // crop preset aspect ratios
  String[] presets = {"Free","1:1","16:9","4:3","3:2"};
  int presetIndex = 0;

  // Interaction
  int draggingSlider = -1; // 0:Scale, 1:Rotation
  boolean draggingTransform = false;

  Cut_Sidebar() {
  }

  void shape() {
    pushStyle();
    // background
    noStroke();
    fill(40);
    rectMode(CORNERS);
    rect(left, top, right, bottom);

    // Header
    fill(220);
    textSize(14);
    textAlign(LEFT, BASELINE);
    text("Crop / Transform", left + 10, top + 30);

    // Presets
    fill(180);
    textSize(12);
    text("Presets", left + 10, top + 60);

    float px = left + 10;
    float py = top + 70;
    float pw = 50;
    float ph = 25;
    float gap = 5;
    
    for (int i = 0; i < presets.length; i++) {
        // Wrap to next line if needed
        if (px + pw > right - 10) {
            px = left + 10;
            py += ph + gap;
        }
        
        drawPresetButton(presets[i], px, py, pw, ph, i == presetIndex);
        px += pw + gap;
    }

    // Sliders
    float sliderY = py + ph + 30;
    drawControlSlider("Scale", scaleVal, 0.1, 3.0, left + 10, sliderY, 0);
    drawControlSlider("Rotation", rotationDeg, -180, 180, left + 10, sliderY + 40, 1);

    // Reset Button
    float btnY = sliderY + 80;
    drawButton("Reset Crop", left + 10, btnY, 160, 30);

    popStyle();
  }
  
  void drawPresetButton(String label, float x, float y, float w, float h, boolean active) {
      rectMode(CORNER);
      if (active) fill(100, 120, 180);
      else if (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h) fill(100);
      else fill(80);
      
      stroke(80);
      strokeWeight(1);
      rect(x, y, w, h, 4);
      
      fill(220);
      textSize(10);
      textAlign(CENTER, CENTER);
      text(label, x + w/2, y + h/2);
      textAlign(LEFT, BASELINE);
  }
  
  void drawButton(String label, float x, float y, float w, float h) {
      rectMode(CORNER);
      if (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h) {
          fill(100);
      } else {
          fill(80);
      }
      stroke(80);
      strokeWeight(1);
      rect(x, y, w, h, 4);
      
      fill(220);
      textSize(12);
      textAlign(CENTER, CENTER);
      text(label, x + w/2, y + h/2);
      textAlign(LEFT, BASELINE);
  }

  void drawControlSlider(String label, float val, float min, float max, float x, float y, int id) {
      float sliderW = 160;
      float sliderX = x + 80;
      fill(180);
      textSize(12);
      textAlign(LEFT, CENTER);
      text(label, x, y);
      stroke(80);
      strokeWeight(2);
      line(sliderX, y, sliderX + sliderW, y);
      float kx = map(val, min, max, sliderX, sliderX + sliderW);
      noStroke();
      if (id == draggingSlider) fill(255); else fill(180);
      ellipse(kx, y, 12, 12);
      fill(150);
      textAlign(RIGHT, CENTER);
      if (id == 0) text(nf(val, 1, 1) + "x", x + 280 - 10, y);
      else text(int(val) + "°", x + 280 - 10, y);
  }
  
  void updateSliders() {
      float sx = left + 90;
      float sw = 160;
      
      if (draggingSlider == 0) {
          scaleVal = updateSliderVal(0.1, 3.0, sx, sw);
          applyPipeline();
      }
      else if (draggingSlider == 1) {
          rotationDeg = updateSliderVal(-180, 180, sx, sw);
          applyPipeline();
      }
  }
  
  float updateSliderVal(float min, float max, float sx, float sw) {
      return constrain(map(mouseX, sx, sx+sw, min, max), min, max);
  }

  void mousePressed() {
      // Check Presets
      float px = left + 10;
      float py = top + 70;
      float pw = 50;
      float ph = 25;
      float gap = 5;
      
      for (int i = 0; i < presets.length; i++) {
          if (px + pw > right - 10) {
              px = left + 10;
              py += ph + gap;
          }
          if (mouseX >= px && mouseX <= px + pw && mouseY >= py && mouseY <= py + ph) {
              presetIndex = i;
              return;
          }
          px += pw + gap;
      }
      
      // Check Sliders
      float sliderY = py + ph + 30;
      if (checkSlider(scaleVal, 0.1, 3.0, left+10, sliderY, 0)) return;
      if (checkSlider(rotationDeg, -180, 180, left+10, sliderY+40, 1)) return;
      
      // Check Reset Button
      float btnY = sliderY + 80;
      if (mouseX >= left + 10 && mouseX <= left + 10 + 160 && mouseY >= btnY && mouseY <= btnY + 30) {
          resetCrop();
      }
  }
  
  boolean checkSlider(float val, float min, float max, float x, float y, int id) {
      float sx = x+80; float sw = 160;
      float kx = map(val, min, max, sx, sx+sw);
      if (dist(mouseX, mouseY, kx, y) < 15 || (mouseX>=sx && mouseX<=sx+sw && abs(mouseY-y)<10)) {
          draggingSlider = id;
          updateSliders();
          return true;
      }
      return false;
  }
  
  void mouseReleased() {
      draggingSlider = -1;
      if (draggingTransform) {
          draggingTransform = false;
      }
  }
  
  void mouseDragged() {
      if (draggingSlider != -1) updateSliders();
  }
  
  void resetCrop() {
      if (importer != null) {
          importer.resetToRaw();
          scaleVal = 1.0;
          rotationDeg = 0;
          applyPipeline();
      }
  }
}

Cut_Sidebar cut_sidebar = new Cut_Sidebar();

// Forwarding helpers used by ColorRING
void cutting_sidebar_shape() { if (cut_sidebar != null) cut_sidebar.shape(); }
void cutting_sidebar_mousePressed() { if (cut_sidebar != null) cut_sidebar.mousePressed(); }
void cutting_sidebar_mouseDragged() { if (cut_sidebar != null) cut_sidebar.mouseDragged(); }
void cutting_sidebar_mouseReleased() { if (cut_sidebar != null) cut_sidebar.mouseReleased(); }
    
