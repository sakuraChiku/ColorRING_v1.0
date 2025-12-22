//create a class for only for importing images
class ImageImporter {
    PImage img;
    PGraphics canvas; // full-resolution canvas matching original image size
    PGraphics originalCanvas; // unmodified base canvas for transforms
    PImage rawImage; // Backup of the initial loaded image for reset
    
    // preview controls for non-destructive tint/brightness preview
    boolean previewActive = false;
    float previewExposure = 1.0;
    PImage previewCanvas; // low-res per-pixel preview (PImage is lighter than PGraphics)
    float x, y; // position to draw the image
    float displayWidth, displayHeight; // scaled dimensions
    
    ImageImporter(String path, float x_pos, float y_pos) {
        if (path != null && path.length() > 0) {
            img = loadImage(path);
            if (img != null) {
                rawImage = img.get(); // Save backup
                scaleAndPositionImage();
            }
        }
        x = x_pos;
        y = y_pos;
    }
    
    // Scale image to fit constraints and center at (275, 350)
    void scaleAndPositionImage() {
        if (img == null) return;
        // Display constraints: use workspace area up to 900x700 and center inside left area (0..910)
        float maxWidth = 900;
        float maxHeight = 700;
        float imgWidth = img.width;
        float imgHeight = img.height;

        // Calculate scale factor to fit into max display area
        float scaleW = maxWidth / imgWidth;
        float scaleH = maxHeight / imgHeight;
        float scale = 1.0;
        if (imgWidth > maxWidth || imgHeight > maxHeight) {
            scale = min(scaleW, scaleH);
        }

        displayWidth = imgWidth * scale;
        displayHeight = imgHeight * scale;

        // Center the image at the requested point (450, 450)
        x = 450 - displayWidth / 2.0;
        y = 450 - displayHeight / 2.0;
    }
    
    // Load image from selected file
    void updateImage(String path) {
        if (path != null) {
            PImage newImg = loadImage(path);
            if (newImg != null) {
                // Enforce a maximum imported image size (width x height)
                int maxW = 900;
                int maxH = 700;
                int w = newImg.width;
                int h = newImg.height;
                if (w > maxW || h > maxH) {
                    float scaleW = (float)maxW / (float)w;
                    float scaleH = (float)maxH / (float)h;
                    float scale = min(scaleW, scaleH);
                    int newW = max(1, int(w * scale));
                    int newH = max(1, int(h * scale));
                    newImg.resize(newW, newH);
                }
                img = newImg;
                rawImage = img.get(); // Save backup
                // create a full-resolution canvas same size as the original (or resized) image
                // create both originalCanvas (base) and working canvas
                originalCanvas = createGraphics(img.width, img.height);
                originalCanvas.beginDraw();
                originalCanvas.image(img, 0, 0, img.width, img.height);
                originalCanvas.endDraw();

                canvas = createGraphics(img.width, img.height);
                canvas.beginDraw();
                canvas.image(originalCanvas, 0, 0);
                canvas.endDraw();
                scaleAndPositionImage();
                println("Image loaded: " + path + " (" + img.width + "x" + img.height + ")");
            } else {
                println("Failed to load image: " + path);
            }
        }
    }

    // Reset originalCanvas to the raw loaded image
    void resetToRaw() {
        if (rawImage != null) {
            originalCanvas = createGraphics(rawImage.width, rawImage.height);
            originalCanvas.beginDraw();
            originalCanvas.image(rawImage, 0, 0);
            originalCanvas.endDraw();
            
            // Also reset working canvas
            canvas = createGraphics(rawImage.width, rawImage.height);
            canvas.beginDraw();
            canvas.image(originalCanvas, 0, 0);
            canvas.endDraw();
            
            img = canvas; // Point display to canvas
            scaleAndPositionImage();
        }
    }

    // Resize the working/original canvas; content is centered on a gray background
    void resizeCanvas(int newW, int newH) {
        if (newW < 1 || newH < 1) return;
        PGraphics base = createGraphics(newW, newH);
        base.beginDraw();
        base.background(200); // gray canvas
        if (originalCanvas != null) {
            int ox = (newW - originalCanvas.width)/2;
            int oy = (newH - originalCanvas.height)/2;
            base.image(originalCanvas, ox, oy);
        } else if (img != null) {
            int ox = (newW - img.width)/2;
            int oy = (newH - img.height)/2;
            base.image(img, ox, oy);
        }
        base.endDraw();

        // commit both original and working canvas
        originalCanvas = createGraphics(newW, newH);
        originalCanvas.beginDraw();
        originalCanvas.image(base, 0, 0);
        originalCanvas.endDraw();

        canvas = createGraphics(newW, newH);
        canvas.beginDraw();
        canvas.image(originalCanvas, 0, 0);
        canvas.endDraw();

        img = canvas.get();
        scaleAndPositionImage();
    }
    
    // Draw the image with scaling
    void display() {
        if (img != null) {
            // draw the current canvas if available (keeps edits at full res)
            if (canvas != null) {
                if (previewActive && previewCanvas != null) {
                    // draw the low-res preview scaled to display area
                    image(previewCanvas, x, y, displayWidth, displayHeight);
                } else {
                    image(canvas, x, y, displayWidth, displayHeight);
                }
            } else {
                image(img, x, y, displayWidth, displayHeight);
            }
        }
    }

    // set preview parameters (non-destructive)
        void setPreview(float exposure, boolean active) {
            previewExposure = exposure;
            previewActive = active;
            if (!active) {
                clearPreview();
            }
        }

        void setPreviewCanvas(PImage p) {
            previewCanvas = p;
            previewActive = (p != null);
        }

        void clearPreview() {
            previewCanvas = null;
            previewActive = false;
            // restore working canvas from original
            if (originalCanvas != null) {
                canvas = createGraphics(originalCanvas.width, originalCanvas.height);
                canvas.beginDraw();
                canvas.image(originalCanvas, 0, 0);
                canvas.endDraw();
                img = canvas.get();
                scaleAndPositionImage();
            }
        }
}

class Import_Sidebar {
    // Layout
    float left = 910;
    float top = 110;
    
    // Button
    float button_x, button_y;
    float button_w = 150, button_h = 40;
    
    Import_Sidebar() {
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
        text("Import Image", left + 10, top + 30);
        
        // Instructions
        fill(180);
        textSize(12);
        text("Click to select an image", left + 10, top + 60);
        text("from your computer.", left + 10, top + 80);
        
        // Select Button
        button_x = left + 10;
        button_y = top + 100;
        drawButton("Select Image", button_x, button_y, button_w, button_h);
        
        // Info text
        fill(150);
        textSize(12);
        text("Image will be centered.", left + 10, top + 160);
        text("Max size: 900x700.", left + 10, top + 180);

        // Canvas preview and controls
        if (importer != null && importer.canvas != null) {
            int cw = importer.canvas.width;
            int ch = importer.canvas.height;
            
            fill(220);
            textSize(14);
            text("Canvas Size", left + 10, top + 220);
            
            fill(180);
            textSize(12);
            text(cw + " x " + ch, left + 10, top + 240);

            // preview box (scaled down)
            float pvW = 200;
            float pvH = 120;
            float scale = min(pvW / cw, pvH / ch);
            float drawW = cw * scale;
            float drawH = ch * scale;
            float pvX = left + 10;
            float pvY = top + 260;
            
            rectMode(CORNER);
            fill(60);
            stroke(80);
            rect(pvX, pvY, pvW, pvH);
            
            // draw canvas preview centered in pv box
            if (importer.originalCanvas != null) {
                image(importer.originalCanvas, pvX + (pvW - drawW)/2, pvY + (pvH - drawH)/2, drawW, drawH);
            }

            // Resize Controls
            float cx = left + 10;
            float cy = pvY + pvH + 20;
            
            fill(220);
            textSize(14);
            text("Resize Canvas", cx, cy);
            
            // Buttons
            float bw = 40;
            float bh = 25;
            float gap = 10;
            
            drawSmallButton("-W", cx, cy + 10, bw, bh);
            drawSmallButton("+W", cx + bw + gap, cy + 10, bw, bh);
            drawSmallButton("-H", cx + 2*(bw + gap), cy + 10, bw, bh);
            drawSmallButton("+H", cx + 3*(bw + gap), cy + 10, bw, bh);
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
    
    void drawSmallButton(String label, float x, float y, float w, float h) {
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
        textSize(10);
        textAlign(CENTER, CENTER);
        text(label, x + w/2, y + h/2);
        textAlign(LEFT, BASELINE);
    }
    
    boolean isButtonClicked() {
        return (mouseX >= button_x && mouseX <= button_x + button_w &&
                mouseY >= button_y && mouseY <= button_y + button_h);
    }

    void mousePressed() {
        if (importer == null || importer.canvas == null) return;
        
        // Recalculate positions for hit testing
        float pvH = 120;
        float pvY = top + 260;
        float cx = left + 10;
        float cy = pvY + pvH + 20;
        float bw = 40;
        float bh = 25;
        float gap = 10;
        
        // -W
        if (checkHit(cx, cy + 10, bw, bh)) {
             resize(max(64, importer.originalCanvas.width - 50), importer.originalCanvas.height);
             return;
        }
        // +W
        if (checkHit(cx + bw + gap, cy + 10, bw, bh)) {
             resize(importer.originalCanvas.width + 50, importer.originalCanvas.height);
             return;
        }
        // -H
        if (checkHit(cx + 2*(bw + gap), cy + 10, bw, bh)) {
             resize(importer.originalCanvas.width, max(64, importer.originalCanvas.height - 50));
             return;
        }
        // +H
        if (checkHit(cx + 3*(bw + gap), cy + 10, bw, bh)) {
             resize(importer.originalCanvas.width, importer.originalCanvas.height + 50);
             return;
        }
    }
    
    boolean checkHit(float x, float y, float w, float h) {
        return (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h);
    }
    
    void resize(int w, int h) {
        if (importer != null) importer.resizeCanvas(w, h);
    }
}