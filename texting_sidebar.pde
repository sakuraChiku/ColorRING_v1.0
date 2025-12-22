class Texting_Color {
    int r, g, b;
    
    // Layout
    float left = 910;
    float top = 110;
    float w = 280;
    
    // Interaction
    int draggingSlider = -1; // 0:R, 1:G, 2:B
    
    Texting_Color(int temp_r, int temp_g, int temp_b) {
        r = temp_r;
        g = temp_g;
        b = temp_b;
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
        text("Text Color", left + 10, top + 30);
        
        // RGB Sliders
        drawControlSlider("Red", r, 0, 255, left + 10, top + 60, 0);
        drawControlSlider("Green", g, 0, 255, left + 10, top + 100, 1);
        drawControlSlider("Blue", b, 0, 255, left + 10, top + 140, 2);
        
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
    
    void updateSliders() {
        float sx = left + 90;
        float sw = 160;
        
        if (draggingSlider == 0) r = (int)updateSliderVal(0, 255, sx, sw);
        else if (draggingSlider == 1) g = (int)updateSliderVal(0, 255, sx, sw);
        else if (draggingSlider == 2) b = (int)updateSliderVal(0, 255, sx, sw);
    }
    
    float updateSliderVal(float min, float max, float sx, float sw) {
        return constrain(map(mouseX, sx, sx+sw, min, max), min, max);
    }
    
    void mousePressed() {
        if (checkSlider(r, 0, 255, left+10, top+60, 0)) return;
        if (checkSlider(g, 0, 255, left+10, top+100, 1)) return;
        if (checkSlider(b, 0, 255, left+10, top+140, 2)) return;
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
}

class Texting_Format {
    // font dropdown parameters
    String[] fontNames = {"Arial", "Times", "Courier", "Georgia"};
    int selectedFont = 0;  // index of selected font
    boolean dropdownOpen = false;
    int dropdown_x = 910 + 60, dropdown_y = 300 + 50, dropdown_w = 150, dropdown_h = 25;
    
    // font size slider parameters
    int fontSize = 24;  // default font size
    
    // Layout
    float left = 910;
    float top = 300;
    float w = 280;
    
    // Interaction
    int draggingSlider = -1; // 0:Size
    
    Texting_Format() {
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
        text("Text Format", left + 10, top + 30);
        
        // Font Dropdown
        fill(180);
        textSize(12);
        textAlign(LEFT, CENTER);
        text("Font", left + 10, top + 60);
        
        // Dropdown Button
        dropdown_x = (int)(left + 60);
        dropdown_y = (int)(top + 50);
        
        fill(60);
        stroke(80);
        rectMode(CORNER);
        rect(dropdown_x, dropdown_y, dropdown_w, dropdown_h, 4);
        
        fill(200);
        textAlign(LEFT, CENTER);
        text(fontNames[selectedFont], dropdown_x + 10, dropdown_y + dropdown_h/2);
        
        // Arrow
        fill(200);
        triangle(dropdown_x + dropdown_w - 15, dropdown_y + 10,
                 dropdown_x + dropdown_w - 5, dropdown_y + 10,
                 dropdown_x + dropdown_w - 10, dropdown_y + 16);
        
        // Size Slider
        drawControlSlider("Size", fontSize, 12, 48, left + 10, top + 100, 0);
        
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
    
    void drawDropdown() {
        if (!dropdownOpen) return;
        
        pushStyle();
        for (int i = 0; i < fontNames.length; i++) {
            fill(i == selectedFont ? 80 : 60);
            stroke(80);
            rectMode(CORNER);
            rect(dropdown_x, dropdown_y + (i + 1) * dropdown_h, dropdown_w, dropdown_h);
            fill(200);
            textSize(12);
            textAlign(LEFT, CENTER);
            text(fontNames[i], dropdown_x + 10, dropdown_y + (i + 1) * dropdown_h + dropdown_h/2);
        }
        popStyle();
    }
    
    void updateFromTextBox(int fontIndex, int size) {
        selectedFont = constrain(fontIndex, 0, fontNames.length - 1);
        fontSize = constrain(size, 12, 48);
    }
    
    void updateSliders() {
        float sx = left + 90;
        float sw = 160;
        if (draggingSlider == 0) fontSize = (int)updateSliderVal(12, 48, sx, sw);
    }
    
    float updateSliderVal(float min, float max, float sx, float sw) {
        return constrain(map(mouseX, sx, sx+sw, min, max), min, max);
    }
    
    void mousePressed() {
        // Check Dropdown
        if (mouseX >= dropdown_x && mouseX <= dropdown_x + dropdown_w &&
            mouseY >= dropdown_y && mouseY <= dropdown_y + dropdown_h) {
            dropdownOpen = !dropdownOpen;
            return;
        }
        
        if (dropdownOpen) {
            for (int i = 0; i < fontNames.length; i++) {
                if (mouseX >= dropdown_x && mouseX <= dropdown_x + dropdown_w &&
                    mouseY >= dropdown_y + (i + 1) * dropdown_h &&
                    mouseY <= dropdown_y + (i + 2) * dropdown_h) {
                    selectedFont = i;
                    dropdownOpen = false;
                    return;
                }
            }
        }
        
        // Check Slider
        if (checkSlider(fontSize, 12, 48, left+10, top+100, 0)) return;
        
        if (dropdownOpen) dropdownOpen = false;
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
    
    void updateSlider() {
        if (draggingSlider != -1) updateSliders();
    }
    
    void mouseReleased() {
        draggingSlider = -1;
    }
}