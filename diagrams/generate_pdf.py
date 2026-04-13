import os
from PIL import Image, ImageDraw, ImageFont

A4_WIDTH = int(21.0 / 2.54 * 300)   # ~2480 pixels
A4_HEIGHT = int(29.7 / 2.54 * 300)  # ~3508 pixels

MARGIN_TOP = int(2.5 / 2.54 * 300)
MARGIN_LEFT = int(2.5 / 2.54 * 300)
MARGIN_RIGHT = int(1.5 / 2.54 * 300)
MARGIN_BOTTOM = int(1.0 / 2.54 * 300)

usable_width = A4_WIDTH - MARGIN_LEFT - MARGIN_RIGHT
usable_height = A4_HEIGHT - MARGIN_TOP - MARGIN_BOTTOM - 200 # Leave 200px for text padding

try:
    font_path = "/Library/Fonts/Arial.ttf"
    if not os.path.exists(font_path):
        font_path = "/System/Library/Fonts/Supplemental/Arial.ttf"
    font = ImageFont.truetype(font_path, 60)
except:
    font = ImageFont.load_default()

figures = [
    ("fig1_system_architecture.png", "Fig. 1"),
    ("fig2_address_resolution.png", "Fig. 2"),
    ("fig3_escrow_payment.png", "Fig. 3"),
    ("fig4_courier_matching.png", "Fig. 4"),
    ("fig5_offline_architecture.png", "Fig. 5"),
    ("fig6_agent_network.png", "Fig. 6")
]

pages = []

for i, (filename, title) in enumerate(figures):
    page = Image.new('RGB', (A4_WIDTH, A4_HEIGHT), 'white')
    draw = ImageDraw.Draw(page)
    
    # Draw Sheet Number at top right boundary inside the margin
    sheet_text = f"{i+1}/{len(figures)}"
    # Rough estimate of text width is 100px so subtracting 150px is safe
    draw.text((A4_WIDTH - MARGIN_RIGHT - 150, MARGIN_TOP), sheet_text, fill="black", font=font)
    
    # Draw Figure Name at bottom center
    draw.text((A4_WIDTH // 2 - 100, A4_HEIGHT - MARGIN_BOTTOM - 100), title, fill="black", font=font)
    
    if os.path.exists(filename):
        img = Image.open(filename)
        
        # If image is transparent, compose it on white background
        if img.mode in ('RGBA', 'LA'):
            bg = Image.new('RGB', img.size, 'white')
            bg.paste(img, mask=img.split()[-1])
            img = bg
            
        # Scale image gracefully so it fits in the allowed area without stretching
        img.thumbnail((usable_width, usable_height), Image.Resampling.LANCZOS)
        
        # Center the scaled image within the page boundaries
        x_offset = MARGIN_LEFT + (usable_width - img.width) // 2
        y_offset = MARGIN_TOP + 100 + (usable_height - img.height) // 2
        
        page.paste(img, (x_offset, y_offset))
    else:
        print(f"Warning: {filename} not found.")

    pages.append(page)

if pages:
    output_filename = 'KIPI_Drawings.pdf'
    pages[0].save(output_filename, save_all=True, append_images=pages[1:], resolution=300.0)
    print(f"{output_filename} generated successfully.")
