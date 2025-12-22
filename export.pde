// Export sidebar and helper for saving the current canvas

class Export_Sidebar {
    String filename = "my_artwork";
    boolean saved = false;
    int saveTimer = 0;
    
    // Layout
    float left = 910;
    float top = 110;
    
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
        text("Export", left + 10, top + 30);
        
        // Filename Label
        fill(180);
        textSize(12);
        text("Filename", left + 10, top + 60);
        
        // Filename Input
        fill(60);
        stroke(80);
        rectMode(CORNER);
        rect(left + 10, top + 70, 180, 30, 4);
        
        fill(220);
        textAlign(LEFT, CENTER);
        text(filename + (frameCount / 30 % 2 == 0 ? "|" : ""), left + 15, top + 85);
        
        // Save Button
        drawButton("Save as PNG", left + 10, top + 120, 150, 40);
        
        // Save confirmation
        if (saved) {
            fill(100, 255, 100);
            textSize(12);
            textAlign(CENTER);
            text("Saved Successfully!", left + 85, top + 180);
            if (millis() - saveTimer > 2000) {
                saved = false;
            }
        }
        
        popStyle();
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
        // Check Save Button
        if (mouseX >= left + 10 && mouseX <= left + 10 + 150 && mouseY >= top + 120 && mouseY <= top + 120 + 40) {
            saveCanvasImage();
            saved = true;
            saveTimer = millis();
        }
    }
    
    void keyPressed() {
        if (key == BACKSPACE) {
            if (filename.length() > 0) {
                filename = filename.substring(0, filename.length() - 1);
            }
        } else if (key != CODED && key != ENTER && key != TAB && key != ESC) {
            filename += key;
        }
    }
}

void saveCanvasImage() {
    String name = export_sidebar.filename;
    if (name.length() == 0) name = "untitled";
    
    if (importer != null) {
        // Prefer saving the high-res canvas if available
        if (importer.canvas != null) {
            importer.canvas.save(name + ".png");
            return;
        } 
        // Fallback to the loaded image if no canvas created yet
        else if (importer.img != null) {
            importer.img.save(name + ".png");
            return;
        }
    }
    println("No image to export");
}