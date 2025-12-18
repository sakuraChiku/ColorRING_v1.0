//create a class for only for importing images
class ImageImporter {
    PImage img;
    PGraphics canvas; // full-resolution canvas matching original image size
    PGraphics originalCanvas; // unmodified base canvas for transforms
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
    int button_x = 590, button_y = 230;
    int button_w = 130, button_h = 40;
    boolean hovering = false;
    
    Import_Sidebar() {
    }
    
    void shape() {
        pushStyle();
        
        textSize(24);
        // Frame rectangle placed at the right area (left = 910)
        fill(255);
        rectMode(CORNERS);
        
        
        // Function name
        fill(0);
        text("Import Image", 915, 135);
        
        // Instructions
        textSize(16);
        fill(80);
        text("Click the button below", 915, 180);
        text("to select an image", 915, 200);
        text("from your computer.", 915, 220);
        
        // Draw button (positioned inside right sidebar)
        button_x = 910 + 10;
        button_y = 230;
        checkHover();
        if (hovering) {
            fill(180, 200, 255);
        } else {
            fill(200, 220, 255);
        }
        stroke(100, 120, 200);
        strokeWeight(2);
        rectMode(CORNER);
        rect(button_x, button_y, button_w, button_h, 5);
        
        // Button text
        fill(0);
        textSize(18);
        textAlign(CENTER, CENTER);
        text("Select Image", button_x + button_w/2, button_y + button_h/2);
        textAlign(LEFT, BASELINE);
        
        // Info text
        textSize(14);
        fill(100);
        text("Image will be centered in the canvas area.", 915, 320);
        text("Displayed preview is scaled; full canvas matches image size.", 915, 340);
        text("Imported images are constrained to max 900x700.", 915, 360);

        // Canvas preview and controls
        if (importer != null && importer.canvas != null) {
            int cw = importer.canvas.width;
            int ch = importer.canvas.height;
            textSize(14);
            fill(80);
            text("Canvas: " + cw + " x " + ch, 915, 390);

            // preview box (scaled down)
            float pvW = 220;
            float pvH = 120;
            float scale = min(pvW / cw, pvH / ch);
            float drawW = cw * scale;
            float drawH = ch * scale;
            float pvX = 915;
            float pvY = 410;
            rectMode(CORNER);
            fill(230);
            stroke(150);
            rect(pvX, pvY, pvW, pvH);
            // draw canvas preview centered in pv box
            if (importer.originalCanvas != null) image(importer.originalCanvas, pvX + (pvW - drawW)/2, pvY + (pvH - drawH)/2, drawW, drawH);

            // width/height adjust buttons
            int bx = int(pvX + pvW + 8);
            int by = int(pvY);
            int bw = 28;
            int bh = 20;
            // width -
            rect(bx, by, bw, bh);
            fill(0); textSize(14); textAlign(CENTER, CENTER); text("-W", bx + bw/2, by + bh/2);
            // width +
            fill(255); rect(bx, by + bh + 6, bw, bh); fill(0); text("+W", bx + bw/2, by + bh + 6 + bh/2);
            // height -
            fill(255); rect(bx, by + 2*(bh + 6), bw, bh); fill(0); text("-H", bx + bw/2, by + 2*(bh + 6) + bh/2);
            // height +
            fill(255); rect(bx, by + 3*(bh + 6), bw, bh); fill(0); text("+H", bx + bw/2, by + 3*(bh + 6) + bh/2);
            textAlign(LEFT, BASELINE);
        }
        
        popStyle();
    }
    
    void checkHover() {
        hovering = (mouseX >= button_x && mouseX <= button_x + button_w &&
                    mouseY >= button_y && mouseY <= button_y + button_h);
    }
    
    boolean isButtonClicked() {
        return (mouseX >= button_x && mouseX <= button_x + button_w &&
                mouseY >= button_y && mouseY <= button_y + button_h);
    }

    void mousePressed() {
        // width/height buttons are to the right of preview area
        float pvX = 915;
        float pvY = 410;
        int bw = 28;
        int bh = 20;
        int bx = int(pvX + 220 + 8);
        int by = int(pvY);
        // width -
        if (mouseX >= bx && mouseX <= bx + bw && mouseY >= by && mouseY <= by + bh) {
            if (importer != null && importer.originalCanvas != null) importer.resizeCanvas(max(64, importer.originalCanvas.width - 50), importer.originalCanvas.height);
            else if (importer != null && importer.img != null) importer.resizeCanvas(max(64, importer.img.width - 50), importer.img.height);
            return;
        }
        // width +
        if (mouseX >= bx && mouseX <= bx + bw && mouseY >= by + bh + 6 && mouseY <= by + 2*bh + 6) {
            if (importer != null && importer.originalCanvas != null) importer.resizeCanvas(importer.originalCanvas.width + 50, importer.originalCanvas.height);
            else if (importer != null && importer.img != null) importer.resizeCanvas(importer.img.width + 50, importer.img.height);
            return;
        }
        // height -
        if (mouseX >= bx && mouseX <= bx + bw && mouseY >= by + 2*(bh + 6) && mouseY <= by + 2*(bh + 6) + bh) {
            if (importer != null && importer.originalCanvas != null) importer.resizeCanvas(importer.originalCanvas.width, max(64, importer.originalCanvas.height - 50));
            else if (importer != null && importer.img != null) importer.resizeCanvas(importer.img.width, max(64, importer.img.height - 50));
            return;
        }
        // height +
        if (mouseX >= bx && mouseX <= bx + bw && mouseY >= by + 3*(bh + 6) && mouseY <= by + 3*(bh + 6) + bh) {
            if (importer != null && importer.originalCanvas != null) importer.resizeCanvas(importer.originalCanvas.width, importer.originalCanvas.height + 50);
            else if (importer != null && importer.img != null) importer.resizeCanvas(importer.img.width, importer.img.height + 50);
            return;
        }
    }
}