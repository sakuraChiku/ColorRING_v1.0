// Export sidebar and helper for saving the current canvas

class Export_Sidebar {
    int btnX = 910 + 10, btnY = 350, btnW = 160, btnH = 28;
    boolean hovering = false;

    Export_Sidebar() {}

    void shape() {
        pushStyle();
        fill(255);
        rectMode(CORNERS);
        // moved sidebar to right area left = 910
        rect(910, 110, 1190, 590);

        fill(0);
        textSize(22);
        text("Export / Save", 915, 135);

        textSize(14);
        fill(80);
        text("Save your current canvas as PNG.", 915, 170);

        // Save button
        checkHover();
        if (hovering) fill(180,200,255); else fill(200,220,255);
        stroke(100,120,200);
        strokeWeight(2);
        rectMode(CORNER);
        rect(btnX, btnY, btnW, btnH, 4);

        fill(0);
        textSize(14);
        textAlign(CENTER, CENTER);
        text("Save Canvas", btnX + btnW/2, btnY + btnH/2);
        textAlign(LEFT, BASELINE);

        popStyle();
    }

    void checkHover() {
        hovering = (mouseX >= btnX && mouseX <= btnX + btnW &&
                    mouseY >= btnY && mouseY <= btnY + btnH);
    }

    void mousePressed() {
        if (mouseX >= btnX && mouseX <= btnX + btnW && mouseY >= btnY && mouseY <= btnY + btnH) {
            saveCanvasImage();
        }
    }
}

// Global helper so other modules (like cutting_sidebar) can call it
void saveCanvasImage() {
    if (importer == null || importer.canvas == null) return;
    String fname = "export_canvas_" + year() + nf(month(),2) + nf(day(),2) + "_" + hour() + nf(minute(),2) + nf(second(),2) + ".png";
    importer.canvas.save(fname);
    println("Saved canvas: " + fname);
}

// Export sidebar instance is initialized in ColorRING.pde setup()