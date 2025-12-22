class Paint_Sidebar {
    // RGB color parameters
    int r, g, b;
    
    // Brush size parameters
    float brushSize;
    
    // Alpha (transparency) parameters
    int alpha;
    
    // Layout
    float left = 910;
    float top = 110;
    float w = 280;
    
    // Interaction
    int draggingSlider = -1; // 0:R, 1:G, 2:B, 3:Size, 4:Alpha
    
    // Eraser and Reset parameters
    boolean isEraser = false;
    float storedBrushSize = 5;
    float storedEraserSize = 10;
    boolean resetClicked = false;
    
    Paint_Sidebar() {
        r = 0;
        g = 0;
        b = 0;
        brushSize = 5;
        alpha = 255;
    }
    
    void shape() {
        pushStyle();
        
        // Background
        noStroke();
        fill(40); // Dark background
        rectMode(CORNERS);
        rect(left, top, width, height);
        
        // Header
        fill(220);
        textSize(14);
        textAlign(LEFT, BASELINE);
        text("Paint Brush", left + 10, top + 30);
        
        // RGB Sliders
        drawControlSlider("Red", r, 0, 255, left + 10, top + 60, 0);
        drawControlSlider("Green", g, 0, 255, left + 10, top + 100, 1);
        drawControlSlider("Blue", b, 0, 255, left + 10, top + 140, 2);
        
        // Brush Settings
        text("Settings", left + 10, top + 190);
        drawControlSlider("Size", brushSize, 1, 30, left + 10, top + 220, 3);
        drawControlSlider("Opacity", alpha, 0, 255, left + 10, top + 260, 4);
        
        // Buttons
        drawButton(isEraser ? "Eraser: ON" : "Eraser: OFF", left + 10, top + 310);
        drawButton("Reset Canvas", left + 120, top + 310);
        
        popStyle();
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
    
    void drawButton(String label, float x, float y) {
        float bw = 100;
        float bh = 25;
        fill(60);
        stroke(80);
        if (mouseX > x && mouseX < x+bw && mouseY > y && mouseY < y+bh) fill(80);
        rectMode(CORNER);
        rect(x, y, bw, bh, 4);
        fill(200);
        textSize(12); // Consistent with slider labels
        textAlign(CENTER, CENTER);
        text(label, x + bw/2, y + bh/2);
    }
    
    void updateSliders() {
        float sx = left + 90; // x + 80 where x = left + 10
        float sw = 160;
        
        if (draggingSlider == 0) r = (int)updateSliderVal(0, 255, sx, sw);
        else if (draggingSlider == 1) g = (int)updateSliderVal(0, 255, sx, sw);
        else if (draggingSlider == 2) b = (int)updateSliderVal(0, 255, sx, sw);
        else if (draggingSlider == 3) brushSize = updateSliderVal(1, 30, sx, sw);
        else if (draggingSlider == 4) alpha = (int)updateSliderVal(0, 255, sx, sw);
    }
    
    float updateSliderVal(float min, float max, float sx, float sw) {
        return constrain(map(mouseX, sx, sx+sw, min, max), min, max);
    }
    
    void mousePressed() {
        // Check Sliders
        if (checkSlider(r, 0, 255, left+10, top+60, 0)) return;
        if (checkSlider(g, 0, 255, left+10, top+100, 1)) return;
        if (checkSlider(b, 0, 255, left+10, top+140, 2)) return;
        if (checkSlider(brushSize, 1, 30, left+10, top+220, 3)) return;
        if (checkSlider(alpha, 0, 255, left+10, top+260, 4)) return;
        
        // Check Buttons
        // Eraser
        if (mouseX > left+10 && mouseX < left+110 && mouseY > top+310 && mouseY < top+335) {
            toggleEraser();
        }
        // Reset
        if (mouseX > left+120 && mouseX < left+220 && mouseY > top+310 && mouseY < top+335) {
            resetClicked = true;
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
    }
    
    void toggleEraser() {
        if (isEraser) {
            storedEraserSize = brushSize;
            brushSize = storedBrushSize;
            isEraser = false;
        } else {
            storedBrushSize = brushSize;
            brushSize = storedEraserSize;
            isEraser = true;
        }
    }
}
