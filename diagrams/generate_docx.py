import docx
from docx.shared import Cm, Pt
from docx.enum.text import WD_ALIGN_PARAGRAPH
from PIL import Image

doc = docx.Document()

# Set page margins based on KIPI standard
section = doc.sections[0]
section.top_margin = Cm(2.5)
section.left_margin = Cm(2.5)
section.right_margin = Cm(1.5)
section.bottom_margin = Cm(1.0)
section.page_height = Cm(29.7)
section.page_width = Cm(21.0)

figures = [
    ("fig1_system_architecture.png", "Fig. 1"),
    ("fig2_address_resolution.png", "Fig. 2"),
    ("fig3_escrow_payment.png", "Fig. 3"),
    ("fig4_courier_matching.png", "Fig. 4"),
    ("fig5_offline_architecture.png", "Fig. 5"),
    ("fig6_agent_network.png", "Fig. 6")
]

total = len(figures)

for i, (filename, title) in enumerate(figures):
    # Sheet number top right
    p_header = doc.add_paragraph()
    p_header.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    run_header = p_header.add_run(f"{i+1}/{total}")
    run_header.font.name = 'Arial'
    run_header.font.size = Pt(12)
    
    # Image
    p_img = doc.add_paragraph()
    p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run_img = p_img.add_run()
    
    try:
        # Dynamically scale the image bounds using PIL
        img = Image.open(filename)
        w, h = img.size
        ratio = w / h
        
        max_w_cm = 16.0
        max_h_cm = 20.0
        
        new_w_cm = max_w_cm
        new_h_cm = new_w_cm / ratio
        
        if new_h_cm > max_h_cm:
            new_h_cm = max_h_cm
            new_w_cm = new_h_cm * ratio
            
        run_img.add_picture(filename, width=Cm(new_w_cm), height=Cm(new_h_cm))
    except Exception as e:
        print(f"Error loading {filename}: {e}")
        
    # Figure numbering bottom center
    p_caption = doc.add_paragraph()
    p_caption.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run_cap = p_caption.add_run(title)
    run_cap.font.name = 'Arial'
    run_cap.font.size = Pt(12)
    
    # Add page break if it's not the last image
    if i < total - 1:
        doc.add_page_break()

doc.save("KIPI_Drawings.docx")
print("KIPI_Drawings.docx generated and scaled successfully.")
