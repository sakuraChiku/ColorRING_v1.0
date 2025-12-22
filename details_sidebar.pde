//sidebar for details
// details_sidebar.pde
// UI Controller for Sharpening, Noise, etc.

Details_Sidebar details_sidebar;
DetailsProcessor detailsProcessor;

void setupDetails() {
  details_sidebar = new Details_Sidebar();
  detailsProcessor = new DetailsProcessor();
}

// Global hooks
void details_sidebar_shape() { if (details_sidebar != null) details_sidebar.shape(); }
void details_sidebar_mousePressed() { if (details_sidebar != null) details_sidebar.mousePressed(); }
void details_sidebar_mouseDragged() { if (details_sidebar != null) details_sidebar.mouseDragged(); }
void details_sidebar_mouseReleased() { if (details_sidebar != null) details_sidebar.mouseReleased(); }

class Details_Sidebar {
  float left = 910;
  float top = 110;
  float w = 280;
  
  float sharpen = 0; // 0..100
  float blur = 0;    // 0..100
  float clarity = 0; // -100..100
  float texture = 0; // 0..100 (Grain)
  
  int draggingSlider = -1;
  boolean updateNeeded = false;
  
  Details_Sidebar() {}
  
  void shape() {
    pushStyle();
    noStroke();
    fill(40);
    rectMode(CORNERS);
    rect(left, top, width, height);
    
    fill(220);
    textSize(14);
    textAlign(LEFT, BASELINE);
    
    text("Sharpening", left + 10, top + 30);
    drawControlSlider("Amount", sharpen, 0, 100, left + 10, top + 60, 0);
    drawControlSlider("Blur", blur, 0, 100, left + 10, top + 100, 1);
    
    stroke(80);
    line(left+10, top+130, left+w-10, top+130);
    
    noStroke();
    fill(220);
    text("Effects", left + 10, top + 160);
    drawControlSlider("Clarity", clarity, -100, 100, left + 10, top + 190, 2);
    drawControlSlider("Texture", texture, 0, 100, left + 10, top + 230, 3);
    
    drawButton("Reset Details", left + 10, top + 270, 120, 30);
    
    fill(150);
    textSize(10);
    text("Use Clarity for local contrast.\nTexture adds film grain.\nSharpening fixes soft focus.", left + 10, top + 320);
    
    popStyle();
    
    if (updateNeeded) applyDetails();
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
    text(int(val), x + w - 25, y);
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

  void mousePressed() {
    if (checkSlider(sharpen, 0, 100, left+10, top+60, 0)) return;
    if (checkSlider(blur, 0, 100, left+10, top+100, 1)) return;
    if (checkSlider(clarity, -100, 100, left+10, top+190, 2)) return;
    if (checkSlider(texture, 0, 100, left+10, top+230, 3)) return;
    
    // Reset Button
    if (mouseX > left+10 && mouseX < left+10+120 && mouseY > top+270 && mouseY < top+270+30) {
      sharpen = 0; blur = 0; clarity = 0; texture = 0;
      updateNeeded = true;
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
  
  void mouseDragged() {
    if (draggingSlider != -1) {
       float sx = left+90; float sw = 160;
       if (draggingSlider==0) sharpen = updateSliderVal(0, 100, sx, sw);
       if (draggingSlider==1) blur = updateSliderVal(0, 100, sx, sw);
       if (draggingSlider==2) clarity = updateSliderVal(-100, 100, sx, sw);
       if (draggingSlider==3) texture = updateSliderVal(0, 100, sx, sw);
       updateNeeded = true;
    }
  }
  
  float updateSliderVal(float min, float max, float sx, float sw) {
    return constrain(map(mouseX, sx, sx+sw, min, max), min, max);
  }
  
  void mouseReleased() { draggingSlider = -1; }
  
  void applyDetails() {
     if (detailsProcessor != null && importer != null && importer.originalCanvas != null) {
        PImage src = importer.originalCanvas.get();
        PImage res = detailsProcessor.applyDetails(src, sharpen, blur, clarity, texture);
        importer.canvas.beginDraw();
        importer.canvas.image(res, 0, 0);
        importer.canvas.endDraw();
        importer.img = importer.canvas.get();
     }
  }
}