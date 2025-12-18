class Texting_Color {
    //parameters RGB
    int r;
    int g;
    int b;
    // slider parameters
    float r_pos, g_pos, b_pos;  // x position of knobs (0-150 range)
    float slider_y;
    float knob_radius = 8;
    int dragging = -1;  // -1=none, 0=R, 1=G, 2=B
    int slider_x = 590, slider_width = 150;  // slider bar x and width

    Texting_Color(int temp_r, int temp_g, int temp_b) {
        r = temp_r;
        g = temp_g;
        b = temp_b;
        // initialize slider positions based on RGB values
        r_pos = map(r, 0, 255, 0, slider_width);
        g_pos = map(g, 0, 255, 0, slider_width);
        b_pos = map(b, 0, 255, 0, slider_width);
        slider_y = 160;  // baseline for sliders
    }

    void shape() {
        pushStyle();
        
        textSize(24);
        //the frame rectangle placed at right area (left = 910)
        int left = 910;
        int top = 110;
        fill(255);
        rectMode(CORNERS);
        // extend bottom to include preview and any controls
        rect(left, top, 1190, 450);

        //function name
        fill(0);
        textMode(CORNERS);
        text("Text Color", left + 5, top + 25);

        //RGB
        rectMode(CORNER);
        // draw slider bars (positions relative to sidebar left)
        slider_x = left + 30;
        // draw slider bars
        rect(slider_x, top + 45, slider_width, 5);
        rect(slider_x, top + 85, slider_width, 5);
        rect(slider_x, top + 125, slider_width, 5);
        
        // draw knobs and values
        drawSlider(155, r_pos, r);
        drawSlider(195, g_pos, g);
        drawSlider(235, b_pos, b);

        //Text preview
        textSize(24);
        fill(0);  // draw preview text in RGB color
        text("Text Preview", left + 5, top + 165);
        
        // draw preview text with current RGB color
        fill(r, g, b);
        textSize(24);
        text("Sample", left + 95, top + 200);

        //Signs of RGB
        fill(0);
        textSize(18);
        text("R", left + 10, top + 55);
        text("G", left + 10, top + 95);
        text("B", left + 10, top + 135);
        
        popStyle();
    }
    
    void drawSlider(float bar_y, float knob_x, int value) {
        // draw knob centered on slider bar (bar height is 5, so center at bar_y + 2.5)
        fill(100);
        circle(slider_x + knob_x, bar_y + 2.5, knob_radius * 2);
        
        // draw value on the right
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
        }
    }
    
    void mousePressed() {
        // check if clicking on R slider knob (centered at bar_y + 2.5)
        if (dist(mouseX, mouseY, slider_x + r_pos, 155 + 2.5) < knob_radius + 5) {
            dragging = 0;
        }
        // check if clicking on G slider knob
        else if (dist(mouseX, mouseY, slider_x + g_pos, 195 + 2.5) < knob_radius + 5) {
            dragging = 1;
        }
        // check if clicking on B slider knob
        else if (dist(mouseX, mouseY, slider_x + b_pos, 235 + 2.5) < knob_radius + 5) {
            dragging = 2;
        }
    }
    
    void mouseReleased() {
        dragging = -1;
    }
}

class Texting_Format {
    // font dropdown parameters
    String[] fontNames = {"Arial", "Times", "Courier", "Georgia"};
    int selectedFont = 0;  // index of selected font
    boolean dropdownOpen = false;
    int dropdown_x = 610, dropdown_y = 410, dropdown_w = 150, dropdown_h = 30;
    
    // font size slider parameters
    int fontSize = 24;  // default font size
    float size_pos;  // slider position (0-150 range)
    int slider_x = 590, slider_width = 150;
    float size_slider_y = 500;
    float knob_radius = 8;
    boolean draggingSize = false;

    Texting_Format() {
        // initialize size slider position based on default fontSize (range 12-48)
        size_pos = map(fontSize, 12, 48, 0, slider_width);
    }

    void shape() {
        pushStyle();
        
        textSize(24);
        // the frame rectangle placed at right area (moved down to sit below divider)
        int left = 910;
        int top = 450;
        fill(255);
        rectMode(CORNERS);
        // expand bottom to allow dropdown items and preview text to fit
        rect(left, top, 1190, 720);
        
        //function name
        fill(0);
        text("Text Font & Size", left + 5, top + 25);
        
        // Font dropdown label
        textSize(18);
        fill(0);
        text("Font:", left + 5, top + 60);
        
        // Draw dropdown button (position relative to left)
        dropdown_x = left + 50;
        dropdown_y = top + 50;
        fill(240);
        stroke(0);
        rectMode(CORNER);
        rect(dropdown_x, dropdown_y, dropdown_w, dropdown_h);
        
        // Draw selected font name
        fill(0);
        textSize(16);
        text(fontNames[selectedFont], dropdown_x + 5, dropdown_y + 20);
        
        // Draw dropdown arrow
        fill(0);
        triangle(dropdown_x + dropdown_w - 20, dropdown_y + 12,
                 dropdown_x + dropdown_w - 10, dropdown_y + 12,
                 dropdown_x + dropdown_w - 15, dropdown_y + 18);
        
        // Font size slider label
        textSize(18);
        fill(0);
        text("Size:", left + 5, top + 125);
        
        // Draw size slider bar
        slider_x = left + 50;
        size_slider_y = top + 125;
        fill(200);
        rectMode(CORNER);
        rect(slider_x, size_slider_y, slider_width, 5);
        
        // Draw size slider knob
        fill(100);
        circle(slider_x + size_pos, size_slider_y + 2.5, knob_radius * 2);
        
        // Draw size value
        fill(0);
        textSize(16);
        text(fontSize, slider_x + slider_width + 10, size_slider_y + 5);
        
        // Font preview
        textSize(18);
        fill(0);
        text("Preview:", left + 5, top + 195);
        
        // Draw preview text with selected font and size
        textSize(fontSize);
        text("Sample", left + 145, top + 195);
        
        popStyle();
    }
    
    // Draw dropdown menu on top layer (called after everything else)
    void drawDropdown() {
        if (!dropdownOpen) return;
        
        pushStyle();
        
        // Draw dropdown menu items
        for (int i = 0; i < fontNames.length; i++) {
            fill(i == selectedFont ? 200 : 240);
            stroke(0);
            rectMode(CORNER);
            rect(dropdown_x, dropdown_y + (i + 1) * dropdown_h, dropdown_w, dropdown_h);
            fill(0);
            textSize(16);
            text(fontNames[i], dropdown_x + 5, dropdown_y + (i + 1) * dropdown_h + 20);
        }
        
        popStyle();
    }
    
    // Update format settings from a textbox
    void updateFromTextBox(int fontIndex, int size) {
        selectedFont = constrain(fontIndex, 0, fontNames.length - 1);
        fontSize = constrain(size, 12, 48);
        size_pos = map(fontSize, 12, 48, 0, slider_width);
    }
    
    void mousePressed() {
        // Check if clicking on dropdown button
        if (mouseX >= dropdown_x && mouseX <= dropdown_x + dropdown_w &&
            mouseY >= dropdown_y && mouseY <= dropdown_y + dropdown_h) {
            dropdownOpen = !dropdownOpen;
            return;
        }
        
        // Check if clicking on dropdown menu items
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
        
        // Check if clicking on size slider knob
        if (dist(mouseX, mouseY, slider_x + size_pos, size_slider_y + 2.5) < knob_radius + 5) {
            draggingSize = true;
        }
        
        // Close dropdown if clicking elsewhere
        if (dropdownOpen) {
            dropdownOpen = false;
        }
    }
    
    void updateSlider() {
        if (draggingSize) {
            size_pos = constrain(mouseX - slider_x, 0, slider_width);
            fontSize = (int)map(size_pos, 0, slider_width, 12, 48);
        }
    }
    
    void mouseReleased() {
        draggingSize = false;
    }
}