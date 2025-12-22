PImage img;
// check if a function is turned on
int[] run = {0,0,0,0,0,0,0,0};
int[] preview = {0,0,0,0,0,0,0,0};
// layout tuning
int iconBaseX = 50;
int iconBaseY = 50;
int iconSpacing = 157;
// Text editor instance (from texting.pde)
TextEditor editor;
Texting_Color text_color;
Texting_Format text_format;
ImageImporter importer;
Import_Sidebar import_sidebar;
PaintBrush paintBrush;
Paint_Sidebar paint_sidebar;
Export_Sidebar export_sidebar;

void setup() {
    size(1200, 800);
    // initialize text editor run[4]
    editor = new TextEditor();
    editor.setup();
    text_color = new Texting_Color(0, 0, 0);
    text_format = new Texting_Format();
    importer = new ImageImporter("data/example.PNG", 50, 150);
    import_sidebar = new Import_Sidebar();
    paintBrush = new PaintBrush();
    paint_sidebar = new Paint_Sidebar();
    export_sidebar = new Export_Sidebar();
    // basics helper + sidebar
    setupBasics();
    setupBasicsSidebar();
    setupColor();
    setupDetails();

    //decide when and where the cursor is TEXT
    if ((editor != null) && (run[4] == 1) && (mouseX > 0 && mouseX < 550) && (mouseY > 100 && mouseY < 600)) cursor(TEXT);
}

void click_a_button(int x_pos, int y_pos, color c_put, color c_click, int i) {
    /* this function enable every icon to show 2 different colors when clicked
    parameters
    x_pos, y_pos: the central location of the icon
    c_put: the color when mouse is put on the icon
    c_click: the color when clicking the icon*/
    boolean hovered = (mouseX > x_pos-40 && mouseX < x_pos+40 && mouseY < y_pos+40 && mouseY > y_pos-40);
    if (hovered && mousePressed) {
        fill(c_click);
        for (int j = 0; j < run.length; j++) run[j] = 0;
        run[i] = 1;
    } else if (hovered) {
        fill(c_put);
        preview[i] = 1;
    } else {
        fill(255);
    }
    // ensure icon rect uses CENTER mode and stays fully visible
    rectMode(CENTER);
    float halfW = 40;
    float drawX = constrain(x_pos, halfW, width - halfW);
    rect(drawX, y_pos, 80, 80);
}

void draw() {
    background(30);
    // reset preview flags each frame; icons will set the relevant one when hovered
    for (int i = 0; i < preview.length; i++) preview[i] = 0;
    // Draw imported image if available
    if (importer != null && importer.img != null) {
        importer.display();
    }
    
    stroke(0); // Ensure border lines are black
    line(0, 100, width, 100);
    line(900, 100, 900, height);
    rectMode(CENTER);
    // draw toolbar icons with adjustable spacing
    click_a_button(iconBaseX + 0*iconSpacing, iconBaseY, (127), (0), 0); //import
    click_a_button(iconBaseX + 1*iconSpacing, iconBaseY, (127), (0), 1); //cut
    click_a_button(iconBaseX + 2*iconSpacing, iconBaseY, (127), (0), 2); //basic
    click_a_button(iconBaseX + 3*iconSpacing, iconBaseY, (127), (0), 3);//color
    click_a_button(iconBaseX + 4*iconSpacing, iconBaseY, (127), (0), 4);//text
    click_a_button(iconBaseX + 5*iconSpacing, iconBaseY, (127), (0), 5);//details
    click_a_button(iconBaseX + 6*iconSpacing, iconBaseY, (127), (0), 6);//paint
    click_a_button(iconBaseX + 7*iconSpacing, iconBaseY, (127), (0), 7);//export

    // draw saved text always (non-editable view)
    if (editor != null) editor.drawStatic();
    
    // draw paint brush strokes always
    if (paintBrush != null) paintBrush.display();

    // set cursor type and draw caret only when text tool is active
    if (run[4] == 1 && editor != null) {
        if (mouseX >= 0 && mouseX <= 550 && mouseY >= 100 && mouseY <= 600) cursor(TEXT);
        else cursor(ARROW);
        editor.drawActiveCaret();

        rectMode(CORNERS);
        // draw divider line between canvas area and sidebars at y=450
        //line(550, 450, 910, 450);

        //initialize the functions
        text_color.shape();
        text_format.shape();
        
        // sync active text box color with slider
        editor.setActiveBoxColor(text_color.r, text_color.g, text_color.b);
        // sync active text box font and size
        editor.setActiveBoxFont(text_format.selectedFont);
        editor.setActiveBoxSize(text_format.fontSize);
        
        // Draw dropdown menu on top layer (after everything else)
        text_format.drawDropdown();
    } else if (run[0] == 1) {
        // Show import sidebar when import tool is selected
        cursor(ARROW);
        import_sidebar.shape();
    } else if (run[1] == 1) {
        // Show cutting sidebar and draw selection overlay
        cursor(ARROW);
        cutting_sidebar_shape();
        cutting_draw();
    } else if (run[2] == 1) {
        // Show basics sidebar when basic tool is selected
        cursor(ARROW);
        basics_sidebar_shape();
    } else if (run[3] == 1) {
        // Show Color sidebar
        cursor(ARROW);
        color_sidebar_shape();
        
    } else if (run[5] == 1) {
        // Show Details sidebar
        cursor(ARROW);
        details_sidebar_shape();
    } else if (run[6] == 1) {
        // Show paint sidebar when paint tool is selected
        cursor(ARROW);
        paint_sidebar.shape();
        // Update brush settings
        paintBrush.setEraser(paint_sidebar.isEraser);
        paintBrush.setSize(paint_sidebar.brushSize);
        
        if (!paint_sidebar.isEraser) {
            paintBrush.setColor(paint_sidebar.r, paint_sidebar.g, paint_sidebar.b);
            paintBrush.setAlpha(paint_sidebar.alpha);
        }
        
        // Check for reset action
        if (paint_sidebar.resetClicked) {
            paintBrush.clear();
            paint_sidebar.resetClicked = false;
        }

        // Show brush preview when paint tool is selected
        if (mouseX < 900 && mouseY > 100) {
            noCursor();
            paintBrush.mousePreview();
        }
        
    } else if (run[7] == 1) {
        // Show export sidebar when export tool is selected
        cursor(ARROW);
        export_sidebar.shape();
    } else {
        cursor(ARROW);
        if (editor != null) editor.deactivate();
    }
    
    fill(0);
    text(mouseX, 25, 125);
    text(mouseY, 25, 150);

    // draw preview box under each icon if hovered
    for (int i = 0; i < preview.length; i++) {
        if (preview[i] == 1) {
            int ix = iconBaseX + i * iconSpacing;
            int iy = 50;
            String msg = "";
            switch(i) {
                case 0: msg = "Import Tool: Load an image file into the canvas area."; break;
                case 1: msg = "Cut Tool: Select and crop a portion of the image."; break;
                case 2: msg = "Basic Tool: Basic image adjustments and filters."; break;
                case 3: msg = "Color Tool: Advanced color correction and grading."; break;
                case 4: msg = "Text Tool: Add and edit text boxes on the canvas."; break;
                case 5: msg = "Details Tool: Fine-tune image details and sharpness."; break;
                case 6: msg = "Paint Tool: Paint directly onto the canvas with customizable brushes."; break;
                case 7: msg = "Export Tool: Save your current canvas as a PNG file."; break;
            }
            pushStyle();
            textSize(12);
            float pad = 10;
            float tw = textWidth(msg);
            float boxW = max(140, tw + pad*2);
            float boxH = 28;
            // constrain preview box so it doesn't overflow canvas horizontally
            float boxX = constrain(ix, boxW/2 + 4, width - boxW/2 - 4);
            rectMode(CENTER);
            fill(255, 250, 230);
            stroke(60);
            rect(boxX, iy + 58, boxW, boxH, 6);
            fill(20);
            textAlign(CENTER, CENTER);
            text(msg, boxX, iy + 58);
            textAlign(LEFT, BASELINE);
            popStyle();
        }
    }

}

void mouseClicked() {
    // Icon bar click handling: set active tool only on intentional clicks
    for (int i = 0; i <= 7; i++) {
        int x_pos = iconBaseX + i * iconSpacing;
        int y_pos = 50;
        if (mouseX > x_pos-40 && mouseX < x_pos+40 && mouseY < y_pos+40 && mouseY > y_pos-40) {
            // toggle tool
            for (int j = 0; j < run.length; j++) run[j] = 0;
            run[i] = 1;
            if (i != 4 && editor != null) editor.deactivate();
            if (i == 4 && editor != null) editor.ensureActiveBox(20, 130);
            return; // consumed click
        }
    }
    // Handle import sidebar button click
    if (run[0] == 1 && import_sidebar.isButtonClicked()) {
        selectInput("Select an image file:", "fileSelected");
        return;
    }
    // forward other import sidebar clicks (canvas +/-)
    if (run[0] == 1) import_sidebar.mousePressed();
    // Basics sidebar clicks
    if (run[2] == 1) basics_sidebar_mousePressed();
    // Cutting sidebar clicks
    if (run[1] == 1) {
        cutting_sidebar_mousePressed();
    }
    // Export sidebar clicks
    if (run[7] == 1) {
        export_sidebar.mousePressed();
        return;
    }
    
    // Handle paint sidebar slider clicks
    // Removed to prevent double-toggling of buttons (handled in mousePressed)
    // if (run[6] == 1) {
    //    paint_sidebar.mousePressed();
    // }
    
    // handle text format clicks first (dropdown has priority)
    if (run[4] == 1) {
        text_format.mousePressed();
    }
    // only forward clicks to editor when text tool is selected and not clicking on sidebar
    if (editor != null && run[4] == 1 && mouseX < 550) {
        editor.mouseClicked();
        // After clicking, update format controls to match active textbox
        if (editor.activeBox != null) {
            int fontIndex = editor.getActiveBoxFontIndex();
            int size = editor.getActiveBoxSize();
            text_format.updateFromTextBox(fontIndex, size);
            // Also update color to match textbox
            color boxColor = editor.activeBox.textColor;
            text_color.r = (int)red(boxColor);
            text_color.g = (int)green(boxColor);
            text_color.b = (int)blue(boxColor);
        }
    }
    // also handle text color slider clicks
    if (run[4] == 1) text_color.mousePressed();

    // Basics sidebar press forward (for sliders)
    if (run[2] == 1) basics_sidebar_mousePressed();
}

void mousePressed() {
    // Start painting when paint tool is selected and clicking in canvas area
    if (run[6] == 1 && mouseX < 900 && mouseY > 100) {
        paintBrush.startStroke(mouseX, mouseY);
    }
    
    // handle slider drag start when text tool is selected
    if (run[4] == 1) {
        text_color.mousePressed();
        text_format.mousePressed();
    }
    
    // handle paint sidebar slider drag
    if (run[6] == 1) {
        paint_sidebar.mousePressed();
    }

    // Cutting interactions
    if (run[1] == 1) {
        cutting_mousePressed();
        cutting_sidebar_mousePressed();
    }
    // Basics sidebar press forward
    if (run[2] == 1) basics_sidebar_mousePressed();
    if (run[3] == 1) color_sidebar_mousePressed();
    if (run[5] == 1) details_sidebar_mousePressed();
    // Forward press to export sidebar
    if (run[7] == 1) {
        export_sidebar.mousePressed();
    }
}

void mouseDragged() {
    // Continue painting when dragging
    if (run[6] == 1 && mouseX < 900 && mouseY > 100) {
        paintBrush.continueStroke(mouseX, mouseY);
    }
    
    // update slider when dragging and text tool is selected
    if (run[4] == 1) {
        text_color.updateSliders();
        text_format.updateSlider();
    }
    
    // update paint sidebar sliders
    if (run[6] == 1) {
        paint_sidebar.updateSliders();
    }

    if (run[1] == 1) {
        cutting_mouseDragged();
        cutting_sidebar_mouseDragged();
    }
    // Basics sidebar drag forward
    if (run[2] == 1) basics_sidebar_mouseDragged();
    if (run[3] == 1) color_sidebar_mouseDragged();
    if (run[5] == 1) details_sidebar_mouseDragged();
}

void mouseReleased() {
    // End painting stroke
    if (run[6] == 1) {
        paintBrush.endStroke();
        paint_sidebar.mouseReleased();
    }
    
    if (run[4] == 1) {
        text_color.mouseReleased();
        text_format.mouseReleased();
    }

    if (run[1] == 1) {
        cutting_mouseReleased();
        cutting_sidebar_mouseReleased();
    }
    // Basics sidebar release forward
    if (run[2] == 1) basics_sidebar_mouseReleased();
    if (run[3] == 1) color_sidebar_mouseReleased();
    if (run[5] == 1) details_sidebar_mouseReleased();
}

void keyPressed() {
    // only forward keyboard input to editor when text tool is selected
    if (editor != null && run[4] == 1) editor.keyPressed();
    // forward keyboard input to export sidebar when export tool is selected
    if (export_sidebar != null && run[7] == 1) export_sidebar.keyPressed();
}

// Callback function for file selection
void fileSelected(File selection) {
    if (selection == null) {
        println("Window was closed or the user hit cancel.");
    } else {
        println("User selected " + selection.getAbsolutePath());
        // Load the selected image
        importer.updateImage(selection.getAbsolutePath());
    }
}

void drawModernSlider(float x, float y, float w, float val, float min, float max, String label) {
  pushStyle();
  stroke(80);
  strokeWeight(2);
  line(x, y, x + w, y); // 轨道
  float kx = map(val, min, max, x, x + w);
  noStroke();
  fill(150, 180, 255);
  ellipse(kx, y, 12, 12); // 滑块
  fill(200);
  textSize(11);
  text(label, x, y - 8);
  text(nf(val, 1, 1), x + w + 10, y + 4);
  popStyle();
}

// Global Pipeline to chain all effects
void applyPipeline() {
    if (importer == null || importer.originalCanvas == null) return;
    
    // 1. Start with the base image (which might be cropped)
    // Note: Crop is destructive to originalCanvas, so we don't need to re-apply crop here.
    // But Scale and Rotation are currently parameters in Cut_Sidebar.
    // We need to apply Scale/Rotation first.
    
    PGraphics src = importer.originalCanvas;
    int w = src.width;
    int h = src.height;
    
    // Apply Scale & Rotation (Non-destructive preview)
    if (cut_sidebar != null) {
        float s = cut_sidebar.scaleVal;
        float r = radians(cut_sidebar.rotationDeg);
        
        if (s != 1.0 || r != 0) {
            // Calculate new dimensions if needed, or keep canvas size?
            // For now, let's keep canvas size same as originalCanvas to avoid complexity,
            // or use the logic from Cut_Sidebar to resize.
            // Cut_Sidebar logic:
            int tW = max(1, int(w * s));
            int tH = max(1, int(h * s));
            // Limit size
            int maxPixels = 6000000;
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
            temp.background(200); // Gray background for rotation
            temp.pushMatrix();
            temp.translate(temp.width/2, temp.height/2);
            temp.rotate(r);
            temp.scale(effectiveScale);
            temp.image(src, -w/2, -h/2);
            temp.popMatrix();
            temp.endDraw();
            
            // Update src to point to this transformed image for next steps
            // We need to convert PGraphics to PImage for filters
            src = temp; 
        }
    }
    
    PImage workingImg = src.get();
    
    // 2. Apply Basics (Exposure, Contrast, Zones)
    if (basics != null && basics_sidebar != null) {
        workingImg = basics.applyAdjustments(workingImg, 
                                           basics_sidebar.exposure, 
                                           basics_sidebar.contrast, 
                                           basics_sidebar.zoneValues);
    }
    
    // 3. Apply Color (Temp, Tint, Vibrance, Saturation, Split Toning)
    if (colorProcessor != null && color_sidebar != null) {
        workingImg = colorProcessor.process(workingImg, 
                                          color_sidebar.temp, 
                                          color_sidebar.tint, 
                                          color_sidebar.vibrance, 
                                          color_sidebar.saturation, 
                                          color_sidebar.shadowT, 
                                          color_sidebar.midT, 
                                          color_sidebar.highT);
    }
    
    // 4. Apply Details (Sharpen, Blur, Clarity, Texture)
    if (detailsProcessor != null && details_sidebar != null) {
        workingImg = detailsProcessor.applyDetails(workingImg, 
                                                 details_sidebar.sharpen, 
                                                 details_sidebar.blur, 
                                                 details_sidebar.clarity, 
                                                 details_sidebar.texture);
    }
    
    // 5. Update Display Canvas
    // Optimization: Reuse canvas if dimensions match to avoid heavy allocation
    if (importer.canvas == null || importer.canvas.width != workingImg.width || importer.canvas.height != workingImg.height) {
        importer.canvas = createGraphics(workingImg.width, workingImg.height);
    }
    
    importer.canvas.beginDraw();
    importer.canvas.background(0, 0); // Clear with transparent background
    importer.canvas.image(workingImg, 0, 0);
    importer.canvas.endDraw();
    
    // Optimization: Point img directly to canvas to avoid heavy .get() copy
    // PGraphics is a PImage, so this works and is much faster.
    importer.img = importer.canvas;
    
    importer.scaleAndPositionImage();
}