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

  // buttons (position relative to left)
  float btnX = left + 10, btnY = 350, btnW = 160, btnH = 28;
  boolean draggingTransform = false;

  Cut_Sidebar() {
  }

  void shape() {
    pushStyle();
    // background
    fill(255);
    rectMode(CORNERS);
    rect(left, top, right, bottom);

    fill(0);
    textSize(22);
    text("Crop / Transform", left + 8, top + 24);

    textSize(14);
    fill(80);
    text("Presets:", left + 8, top + 56);

    // presets
    float px = left + 8;
    float py = top + 68;
    float pw = 72;
    float ph = 26;
      rectMode(CORNER);
      for (int i = 0; i < presets.length; i++) {
        if (i == presetIndex) fill(200,220,255); else fill(240);
        stroke(150);
        rect(px + i*(pw+6), py, pw, ph, 4);
        fill(0);
        textSize(12);
        textAlign(CENTER, CENTER);
        text(presets[i], px + i*(pw+6) + pw/2, py + ph/2);
        textAlign(LEFT, BASELINE);
      }

    // scale slider
    textSize(14);
    fill(0);
    text("Scale:", left + 8, py + ph + 36);
    float sx = left + 8;
    float sy = py + ph + 44;
    float sw = 220;
    // draw rail
    stroke(150);
    strokeWeight(1);
    line(sx, sy, sx+sw, sy);
    float knobX = sx + map(scaleVal, 0.1, 3, 0, sw);
    fill(200);
    ellipse(knobX, sy, 12, 12);
    fill(0);
    text(nf(scaleVal,1,2)+"x", sx+sw+8, sy+4);

    // rotation slider
    text("Rotation:", left + 8, sy + 28);
    float rx = sx;
    float ry = sy + 36;
    float rw = 220;
    stroke(150);
    line(rx, ry, rx+rw, ry);
    float rknobX = rx + map(rotationDeg, -180, 180, 0, rw);
    fill(200);
    ellipse(rknobX, ry, 12, 12);
    fill(0);
    text(int(rotationDeg)+"°", rx+rw+8, ry+4);

    // Preset crop button (Apply Transform button removed; transforms apply live during drag)
    float ay = ry + 40;
    float pby = ay + btnH + 10;
    fill(200,220,255);
    rect(btnX, pby, btnW, btnH, 4);
    fill(0);
    textAlign(CENTER, CENTER);
    text("Apply Preset Crop", btnX+btnW/2, pby+btnH/2);
    textAlign(LEFT, BASELINE);

    // restore default to CORNERS for any callers that expect it
    rectMode(CORNERS);
    popStyle();
  }

  // Helper to check clicks inside sidebar buttons and controls
  void mousePressed() {
    // presets
    float px = left + 8;
    float py = top + 68;
    float pw = 72;
    float ph = 26;
    for (int i = 0; i < presets.length; i++) {
      if (mouseX >= px + i*(pw+6) && mouseX <= px + i*(pw+6) + pw && mouseY >= py && mouseY <= py+ph) {
        presetIndex = i;
        return;
      }
    }

    // scale knob area
    float sx = left + 8;
    float sw = 220;
    float sy = py + ph + 44; // consistent with drawing in shape()
    if (mouseX >= sx && mouseX <= sx+sw && mouseY >= sy-12 && mouseY <= sy+12) {
      scaleVal = constrain(map(mouseX, sx, sx+sw, 0.1, 3), 0.1, 3);
      draggingTransform = true;
      applyLiveTransform();
      return;
    }
    // rotation knob
    float rx = sx;
    float rw = 220;
    float ry = sy + 36;
    if (mouseX >= rx && mouseX <= rx+rw && mouseY >= ry-12 && mouseY <= ry+12) {
      rotationDeg = constrain(map(mouseX, rx, rx+rw, -180, 180), -180, 180);
      draggingTransform = true;
      applyLiveTransform();
      return;
    }
    // Apply Preset Crop
    float ay = ry + 40;
    float pby = ay + btnH + 10;
    if (mouseX >= btnX && mouseX <= btnX+btnW && mouseY >= pby && mouseY <= pby+btnH) {
      applyPresetCrop();
      return;
    }

    // Save
    float sby = pby + btnH + 10;
    if (mouseX >= btnX && mouseX <= btnX+btnW && mouseY >= sby && mouseY <= sby+btnH) {
      saveCanvasImage();
      return;
    }
  }

  void mouseDragged() {
    // allow dragging sliders
    float py = top + 68;
    float ph = 26;
    float sx = left + 8;
    float sw = 220;
    float sy = py + ph + 44; // same baseline as mousePressed/shape
    if (mouseX >= sx && mouseX <= sx+sw) {
      if (mouseY >= sy-12 && mouseY <= sy+12) {
        scaleVal = constrain(map(mouseX, sx, sx+sw, 0.1, 3), 0.1, 3);
        applyLiveTransform();
      }
      float ry = sy + 36;
      if (mouseY >= ry-12 && mouseY <= ry+12) {
        rotationDeg = constrain(map(mouseX, sx, sx+sw, -180, 180), -180, 180);
        applyLiveTransform();
      }
    }
  }

  void mouseReleased() {
    if (draggingTransform) {
      // stop live-transform mode; do NOT commit the preview to originalCanvas
      draggingTransform = false;
    }
  }

  void applyLiveTransform() {
    if (importer == null || importer.originalCanvas == null) return;
    float s = scaleVal;
    float r = radians(rotationDeg);
    PGraphics src = importer.originalCanvas;
    int srcW = src.width;
    int srcH = src.height;
    // Keep the preview canvas unchanged in size (so the gray background doesn't rotate).
    int tW = srcW;
    int tH = srcH;
    // Safety: if requested visual scale would cause extremely expensive raster ops, downscale the drawn image
    int maxPixels = 6000000;
    long requestedPixels = (long)srcW * (long)srcH * (long)ceil(s*s);
    float downscale = 1.0;
    if (requestedPixels > maxPixels) {
      downscale = sqrt((float)maxPixels / (float)requestedPixels);
    }
    float effectiveScale = s * downscale;

    PGraphics temp = createGraphics(tW, tH);
    temp.beginDraw();
    // draw gray background (this stays unrotated)
    temp.background(200);
    temp.pushMatrix();
    temp.translate(temp.width/2, temp.height/2);
    temp.rotate(r);
    temp.scale(effectiveScale);
    temp.image(src, -srcW/2, -srcH/2);
    temp.popMatrix();
    temp.endDraw();

    importer.canvas = createGraphics(temp.width, temp.height);
    importer.canvas.beginDraw();
    importer.canvas.image(temp, 0, 0);
    importer.canvas.endDraw();
    importer.img = importer.canvas.get();
    importer.scaleAndPositionImage();
  }

  void applyTransform() {
    if (importer == null || importer.canvas == null) return;
    float s = scaleVal;
    float r = radians(rotationDeg);
    // safety: avoid creating extremely large intermediate surfaces
    int maxPixels = 6000000; // ~6MP safety threshold
    int tW = max(1, int(importer.canvas.width * s));
    int tH = max(1, int(importer.canvas.height * s));
    long pixels = (long)tW * (long)tH;
    float downscale = 1.0;
    if (pixels > maxPixels) {
      downscale = sqrt((float)maxPixels / (float)pixels);
      tW = max(1, int(tW * downscale));
      tH = max(1, int(tH * downscale));
    }

    float effectiveScale = s * downscale;

    PGraphics temp = createGraphics(tW, tH);
    temp.beginDraw();
    temp.background(255,255);
    temp.pushMatrix();
    temp.translate(temp.width/2, temp.height/2);
    temp.rotate(r);
    temp.scale(effectiveScale);
    temp.image(importer.canvas, -importer.canvas.width/2, -importer.canvas.height/2);
    temp.popMatrix();
    temp.endDraw();

    // replace canvas with temp
    importer.canvas = createGraphics(temp.width, temp.height);
    importer.canvas.beginDraw();
    importer.canvas.image(temp, 0, 0);
    importer.canvas.endDraw();

    // commit transformed canvas as the new original base
    importer.originalCanvas = importer.canvas;
    // update displayed scaling and position
    importer.img = importer.canvas.get();
    importer.scaleAndPositionImage();
  }

  void applyPresetCrop() {
    if (importer == null || importer.canvas == null) return;
    if (presetIndex == 0) return; // Free
    float ar = 1.0;
    if (presetIndex == 1) ar = 1.0; //1:1
    if (presetIndex == 2) ar = 16.0/9.0;
    if (presetIndex == 3) ar = 4.0/3.0;
    if (presetIndex == 4) ar = 3.0/2.0;

    int w = importer.canvas.width;
    int h = importer.canvas.height;
    // center crop
    float canvasAR = (float)w / (float)h;
    int cw, ch;
    if (canvasAR > ar) {
      // canvas wider -> limit width
      ch = h;
      cw = int(ar * ch);
    } else {
      cw = w;
      ch = int(cw / ar);
    }
    int sx = (w - cw)/2;
    int sy = (h - ch)/2;

    // perform crop into a new PGraphics safely (avoid large intermediate PImage)
    int maxPixels = 6000000;
    long pixels = (long)cw * (long)ch;
    float downscale = 1.0;
    int targetW = cw;
    int targetH = ch;
    if (pixels > maxPixels) {
      downscale = sqrt((float)maxPixels / (float)pixels);
      targetW = max(1, int(cw * downscale));
      targetH = max(1, int(ch * downscale));
    }

    PGraphics newCanvas = createGraphics(targetW, targetH);
    newCanvas.beginDraw();
    newCanvas.image(importer.canvas, 0, 0, targetW, targetH, sx, sy, sx + cw, sy + ch);
    newCanvas.endDraw();

    importer.canvas = newCanvas;
    // commit the cropped result as the new original base
    importer.originalCanvas = importer.canvas;
    importer.img = importer.canvas.get();
    importer.scaleAndPositionImage();
  }
}

Cut_Sidebar cut_sidebar = new Cut_Sidebar();

// Forwarding helpers used by ColorRING
void cutting_sidebar_shape() { if (cut_sidebar != null) cut_sidebar.shape(); }
void cutting_sidebar_mousePressed() { if (cut_sidebar != null) cut_sidebar.mousePressed(); }
void cutting_sidebar_mouseDragged() { if (cut_sidebar != null) cut_sidebar.mouseDragged(); }
void cutting_sidebar_mouseReleased() { if (cut_sidebar != null) cut_sidebar.mouseReleased(); }
    
