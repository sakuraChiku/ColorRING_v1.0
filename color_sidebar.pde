//sidebar for color
// color_sidebar.pde
// UI Controller for Advanced Color (WB, Vibrance, Split Toning)

Color_Sidebar color_sidebar;
ColorProcessor colorProcessor; // 全局实例

void setupColor() {
  color_sidebar = new Color_Sidebar();
  colorProcessor = new ColorProcessor();
}

// Global hooks
void color_sidebar_shape() { if (color_sidebar != null) color_sidebar.shape(); }
void color_sidebar_mousePressed() { if (color_sidebar != null) color_sidebar.mousePressed(); }
void color_sidebar_mouseDragged() { if (color_sidebar != null) color_sidebar.mouseDragged(); }
void color_sidebar_mouseReleased() { if (color_sidebar != null) color_sidebar.mouseReleased(); }

class Color_Sidebar {
  float left = 910;
  float top = 110;
  float w = 280;
  
  // Basic Color
  float temp = 0;   // -50..50
  float tint = 0;   // -50..50
  float vibrance = 0; // -100..100
  float saturation = 0; // -100..100
  
  // Split Toning Colors (H, S, B=100)
  // We store them as colors for the processor
  color shadowT = color(128);
  color midT = color(128);
  color highT = color(128);
  
  // Interaction state
  int draggingSlider = -1; 
  int draggingWheel = -1; // 0:Shadow, 1:Mid, 2:High
  boolean updateNeeded = false;
  
  Color_Sidebar() {}

  void shape() {
    pushStyle();
    noStroke();
    fill(40);
    rectMode(CORNERS);
    rect(left, top, width, height);

    // 1. White Balance & Presence
    fill(220);
    textSize(14);
    textAlign(LEFT, BASELINE);
    text("White Balance", left + 10, top + 30);
    
    drawControlSlider("Temp", temp, -50, 50, left + 10, top + 45, 0);
    drawControlSlider("Tint", tint, -50, 50, left + 10, top + 85, 1);
    
    text("Presence", left + 60, top + 120);
    drawControlSlider("Vibrance", vibrance, -100, 100, left + 10, top + 155, 2);
    drawControlSlider("Saturation", saturation, -100, 100, left + 10, top + 195, 3);
    
    stroke(60);
    line(left+10, top+235, left+w-10, top+235);
    
    // 2. Color Grading (Wheels)
    noStroke();
    fill(220);
    text("Color Grading (Split Toning)", left + 165, top + 265);
    
    float wheelY = top + 330;
    drawColorWheel("Shadows", left + 50, wheelY, shadowT);
    drawColorWheel("Midtones", left + 140, wheelY, midT);
    drawColorWheel("Highlights", left + 230, wheelY, highT);
    
    // 3. Reset Button
    drawButton("Reset Color", left + 10, wheelY + 60);

    // 4. Instruction
    fill(100);
    textSize(10);
    text("INSTRUCTION: Use Color Wheels to tint specific tonal ranges. Drag inside the circle to pick Hue and Saturation.", left + 10, height - 20, w - 20, 40);

    popStyle();
    
    if (updateNeeded) applyColor();
  }

  // Helper: Draw Color Wheel
  void drawColorWheel(String label, float cx, float cy, color c) {
    float r = 35; // radius
    
    // Draw Wheel Gradient
    pushMatrix();
    translate(cx, cy);
    colorMode(HSB, 360, 100, 100);
    noStroke();
    beginShape(TRIANGLE_FAN);
    vertex(0, 0);
    for (int angle = 0; angle <= 360; angle += 10) {
      fill(angle, 100, 100);
      vertex(cos(radians(angle)) * r, sin(radians(angle)) * r);
    }
    endShape();
    
    // Draw Current Selector
    // hue(c) returns 0-360 because of colorMode(HSB, 360, 100, 100)
    // saturation(c) returns 0-100
    float ang = hue(c);
    float dist = map(saturation(c), 0, 100, 0, r);
    
    // If color is gray (no sat), put in center
    if (saturation(c) < 5) dist = 0;
    
    stroke(0, 0, 100);
    strokeWeight(2);
    noFill();
    ellipse(cos(radians(ang)) * dist, sin(radians(ang)) * dist, 6, 6);
    
    colorMode(RGB, 255);
    popMatrix();
    
    fill(180);
    textAlign(CENTER);
    text(label, cx, cy + r + 15);
  }

  // Consistent Slider (Same as Basics)
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
    text(int(val), x + w - 25, y);
  }
  
  void drawButton(String label, float x, float y) {
    float bw = 100;
    float bh = 25;
    fill(60);
    stroke(80);
    if (mouseX > x && mouseX < x+bw && mouseY > y && mouseY < y+bh) fill(80);
    rectMode(CORNER);
    rect(x, y, bw, bh, 4);
    fill(200);
    textAlign(CENTER, CENTER);
    text(label, x + bw/2, y + bh/2);
  }

  void mousePressed() {
    if (checkSlider(temp, -50, 50, left+10, top+45, 0)) return;
    if (checkSlider(tint, -50, 50, left+10, top+85, 1)) return;
    if (checkSlider(vibrance, -100, 100, left+10, top+155, 2)) return;
    if (checkSlider(saturation, -100, 100, left+10, top+195, 3)) return;
    
    // Check Wheels
    float wheelY = top + 330;
    if (checkWheel(left+50, wheelY, 0)) return;
    if (checkWheel(left+140, wheelY, 1)) return;
    if (checkWheel(left+230, wheelY, 2)) return;
    
    // Reset
    if (mouseX > left+10 && mouseX < left+110 && mouseY > wheelY+60 && mouseY < wheelY+85) {
      reset();
    }
  }
  
  boolean checkSlider(float val, float min, float max, float x, float y, int id) {
    float sx = x+80; float sw = 160;
    float kx = map(val, min, max, sx, sx+sw);
    if (dist(mouseX, mouseY, kx, y) < 15 || (mouseX>=sx && mouseX<=sx+sw && abs(mouseY-y)<10)) {
      draggingSlider = id;
      updateSliderVal(min, max, sx, sw);
      return true;
    }
    return false;
  }
  
  boolean checkWheel(float cx, float cy, int id) {
    if (dist(mouseX, mouseY, cx, cy) < 35) {
      draggingWheel = id;
      updateWheelVal(cx, cy);
      return true;
    }
    return false;
  }

  void mouseDragged() {
    if (draggingSlider != -1) {
       float sx = left+90; float sw = 160;
       if (draggingSlider==0) temp = updateSliderVal(-50, 50, sx, sw);
       if (draggingSlider==1) tint = updateSliderVal(-50, 50, sx, sw);
       if (draggingSlider==2) vibrance = updateSliderVal(-100, 100, sx, sw);
       if (draggingSlider==3) saturation = updateSliderVal(-100, 100, sx, sw);
       updateNeeded = true;
    }
    if (draggingWheel != -1) {
       float wheelY = top + 330;
       float cx = (draggingWheel==0) ? left+50 : (draggingWheel==1 ? left+140 : left+230);
       updateWheelVal(cx, wheelY);
       updateNeeded = true;
    }
  }

  float updateSliderVal(float min, float max, float sx, float sw) {
    return constrain(map(mouseX, sx, sx+sw, min, max), min, max);
  }
  
  void updateWheelVal(float cx, float cy) {
    float dx = mouseX - cx;
    float dy = mouseY - cy;
    float angle = degrees(atan2(dy, dx));
    if (angle < 0) angle += 360;
    float dist = constrain(dist(mouseX, mouseY, cx, cy), 0, 35);
    
    // Map to color
    colorMode(HSB, 360, 100, 100);
    float s = map(dist, 0, 35, 0, 100); // Saturation
    color c = color(angle, s, 100);
    colorMode(RGB, 255);
    
    if (draggingWheel == 0) shadowT = c;
    else if (draggingWheel == 1) midT = c;
    else if (draggingWheel == 2) highT = c;
  }

  void mouseReleased() {
    draggingSlider = -1;
    draggingWheel = -1;
  }
  
  void reset() {
    temp = 0; tint = 0; vibrance = 0; saturation = 0;
    shadowT = color(128); midT = color(128); highT = color(128);
    updateNeeded = true;
  }
  
  void applyColor() {
     if (colorProcessor != null && importer != null && importer.originalCanvas != null) {
        PImage src = importer.originalCanvas.get();
        // If basics was applied, we might need to chain them. 
        // Ideally: Original -> Basics -> Color -> Details
        // For now, let's assume we edit directly or chain manually. 
        // Simplification: Apply directly to current State (which might reset others if not chained carefully).
        // A robust system would pipe: original -> basic.process() -> color.process() -> ...
        // Here we just apply Color to the current base.
        
        PImage res = colorProcessor.process(src, temp, tint, vibrance, saturation, shadowT, midT, highT);
        
        importer.canvas.beginDraw();
        importer.canvas.image(res, 0, 0);
        importer.canvas.endDraw();
        importer.img = importer.canvas.get();
     }
  }
}