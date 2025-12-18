PImage img;
// check if a function is turned on
int[] run = {0,0,0,0,0,0,0,0};
int[] preview = {0,0,0,0,0,0,0,0};
// layout tuning
int iconBaseX = 50;
int iconBaseY = 50;
int iconSpacing = 160;
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
    background(255);
    // reset preview flags each frame; icons will set the relevant one when hovered
    for (int i = 0; i < preview.length; i++) preview[i] = 0;
    // Draw imported image if available
    if (importer != null && importer.img != null) {
        importer.display();
    }
    
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
    } else if (run[6] == 1) {
        // Show paint sidebar when paint tool is selected
        cursor(ARROW);
        paint_sidebar.shape();
        // Update brush settings
        paintBrush.setColor(paint_sidebar.r, paint_sidebar.g, paint_sidebar.b);
        paintBrush.setSize(paint_sidebar.brushSize);
        paintBrush.setAlpha(paint_sidebar.alpha);
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
            stroke(120);
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
    if (run[6] == 1) {
        paint_sidebar.mousePressed();
    }
    
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
            text_color.r_pos = map(text_color.r, 0, 255, 0, text_color.slider_width);
            text_color.g_pos = map(text_color.g, 0, 255, 0, text_color.slider_width);
            text_color.b_pos = map(text_color.b, 0, 255, 0, text_color.slider_width);
        }
    }
    // also handle text color slider clicks
    if (run[4] == 1) text_color.mousePressed();

    // Basics sidebar press forward (for sliders)
    if (run[2] == 1) basics_sidebar_mousePressed();
}

void mousePressed() {
    // Start painting when paint tool is selected and clicking in canvas area
    if (run[6] == 1 && mouseX < 550 && mouseY > 100) {
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
    // Forward press to export sidebar
    if (run[7] == 1) {
        export_sidebar.mousePressed();
    }
}

void mouseDragged() {
    // Continue painting when dragging
    if (run[6] == 1 && mouseX < 550 && mouseY > 100) {
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
}

void keyPressed() {
    // only forward keyboard input to editor when text tool is selected
    if (editor != null && run[4] == 1) editor.keyPressed();
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
