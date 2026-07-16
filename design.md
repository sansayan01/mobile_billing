# Design

## Theme
- **Material 3** — Flutter Material Design 3
- **Primary Color**: `#6C63FF` (Purple-ish)
- **Secondary**: `#03DAC6` (Teal)
- **Background**: `#F2F2F7` (Light gray)
- **Surface**: White
- **Error**: `#B00020` (Red)

## Typography
- **Font Family**: IBM Plex Sans (`google_fonts`)
- **Body Large**: 15px, w500
- **Headings**: Bold, various sizes
- **Monetary values**: w900 for ₹ amounts

## Component Specs

### Cards
- Border radius: 16px
- Elevation: 4
- Shadow: black 10% (custom `withValues`)

### Buttons (PrimaryButton)
- Background: Primary color (`#6C63FF`)
- Text: White, bold
- Border radius: 12px
- Elevation: 4 (shadow at 40% opacity)
- Padding: 16px vertical, 24px horizontal

### Input Fields
- Filled background: White
- Border radius: 12px
- Focused border: Primary color, 2px width
- Content padding: 16px horizontal, 16px vertical

### Scanner Screen
- Camera occupies top 40% of screen
- Bottom panel has 24px overlap (rounded top corners)
- Scanner overlay: 250×250 bounding box with green accent corners
- Floating overlay buttons: circular, black45 background

### Icons
- Settings gear (top right, scanner screen)
- Flash toggle
- Camera on/off toggle

## Screens

| Screen | Route | Purpose |
|--------|-------|---------|
| Home | `/` | Barcode scanner + cart panel |
| Checkout | `/checkout` | Order summary, QR, print |
| Products | `/products` | List all products |
| Add Product | `/products/add` | Add new product |
| Edit Product | `/products/edit/:id` | Edit existing product |
| Shop Details | `/shop` | Shop name, UPI ID, address, etc. |
| Settings | `/settings` | Printer config |

## Layout Considerations
- Portrait-first design
- Bottom sheets with rounded top corners
- Floating action buttons
- Empty states with illustrations/icons + helper text
