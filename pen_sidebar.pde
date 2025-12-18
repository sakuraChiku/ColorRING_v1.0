class Paint_Sidebar {
    // RGB color parameters
    int r, g, b;
    float r_pos, g_pos, b_pos;
    
    // Brush size parameters
    float brushSize;
    float size_pos;
    
    // Alpha (transparency) parameters
    int alpha;
    float alpha_pos;
    
    // Slider parameters
    int slider_x = 590, slider_width = 150;
    float knob_radius = 8;
    int dragging = -1;  // -1=none, 0=R, 1=G, 2=B, 3=size, 4=alpha
    
    Paint_Sidebar() {
        r = 0;
        g = 0;
        b = 0;
        brushSize = 5;
        alpha = 255;
        
        // Initialize slider positions
        r_pos = map(r, 0, 255, 0, slider_width);
        g_pos = map(g, 0, 255, 0, slider_width);
        b_pos = map(b, 0, 255, 0, slider_width);
        size_pos = map(brushSize, 1, 30, 0, slider_width);
        alpha_pos = map(alpha, 0, 255, 0, slider_width);
    }
    
    void shape() {
        pushStyle();
        
        textSize(24);
        // Frame rectangle placed at right area (left = 910)
        int left = 910;
        int top = 110;
        
        
        // Function name
        fill(0);
        text("Paint Brush", left + 5, top + 25);
        
        // RGB Color section
        textSize(18);
        fill(0);
        text("Color:", 565, 170);
        
        // RGB sliders (positions relative to sidebar left)
        slider_x = left + 30;
        rectMode(CORNER);
        fill(200);
        rect(slider_x, top + 65, slider_width, 5);
        rect(slider_x, top + 105, slider_width, 5);
        rect(slider_x, top + 145, slider_width, 5);
        
        // Draw knobs and values for RGB
        drawSlider(175, r_pos, r);
        drawSlider(215, g_pos, g);
        drawSlider(255, b_pos, b);
        
        // RGB labels
        fill(0);
        textSize(16);
        text("R", left + 10, top + 75);
        text("G", left + 10, top + 115);
        text("B", left + 10, top + 155);
        
        // Brush size section
        textSize(18);
        fill(0);
        text("Size:", left + 5, top + 205);
        
        fill(200);
        rect(slider_x, top + 210, slider_width, 5);
        drawSlider(top + 210, size_pos, (int)brushSize);
        
        // Alpha (transparency) section
        textSize(18);
        fill(0);
        text("Opacity:", left + 5, top + 265);
        
        fill(200);
        rect(slider_x, top + 270, slider_width, 5);
        drawSlider(top + 270, alpha_pos, alpha);
        
        // Preview section
        textSize(18);
        fill(0);
        text("Preview:", left + 5, top + 325);
        
        // Draw preview line (aligned so divider sits at y=450)
        stroke(r, g, b, alpha);
        strokeWeight(brushSize);
        strokeCap(ROUND);
        line(left + 90, top + 340, left + 240, top + 340);
        
        // Draw preview circle (slightly below the line)
        noStroke();
        fill(r, g, b, alpha);
        circle(left + 215, top + 380, brushSize * 2);
        
        popStyle();
    }
    
    void drawSlider(float bar_y, float knob_x, int value) {
        // Draw knob
        fill(100);
        noStroke();
        circle(slider_x + knob_x, bar_y + 2.5, knob_radius * 2);
        
        // Draw value
        fill(0);
        textSize(16);
        text(value, slider_x + slider_width + 10, bar_y + 5);
    }
    
    void updateSliders() {
        if (dragging == 0) {
            r_pos = constrain(mouseX - slider_x, 0, slider_width);
            r = (int)map(r_pos, 0, slider_width, 0, 255);
        } else if (dragging == 1) {
            g_pos = constrain(mouseX - slider_x, 0, slider_width);
            g = (int)map(g_pos, 0, slider_width, 0, 255);
        } else if (dragging == 2) {
            b_pos = constrain(mouseX - slider_x, 0, slider_width);
            b = (int)map(b_pos, 0, slider_width, 0, 255);
        } else if (dragging == 3) {
            size_pos = constrain(mouseX - slider_x, 0, slider_width);
            brushSize = map(size_pos, 0, slider_width, 1, 30);
        } else if (dragging == 4) {
            alpha_pos = constrain(mouseX - slider_x, 0, slider_width);
            alpha = (int)map(alpha_pos, 0, slider_width, 0, 255);
        }
    }
    
    void mousePressed() {
        // Check RGB slider knobs
        if (dist(mouseX, mouseY, slider_x + r_pos, 175 + 2.5) < knob_radius + 5) {
            dragging = 0;
        } else if (dist(mouseX, mouseY, slider_x + g_pos, 215 + 2.5) < knob_radius + 5) {
            dragging = 1;
        } else if (dist(mouseX, mouseY, slider_x + b_pos, 255 + 2.5) < knob_radius + 5) {
            dragging = 2;
        }
        // Check size slider knob
        else if (dist(mouseX, mouseY, slider_x + size_pos, 320 + 2.5) < knob_radius + 5) {
            dragging = 3;
        }
        // Check alpha slider knob
        else if (dist(mouseX, mouseY, slider_x + alpha_pos, 380 + 2.5) < knob_radius + 5) {
            dragging = 4;
        }
    }
    
    void mouseReleased() {
        dragging = -1;
    }
}
