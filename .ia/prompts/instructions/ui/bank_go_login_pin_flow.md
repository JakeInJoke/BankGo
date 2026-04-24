# Enhanced Design Prompt: BankGo Login & PIN Setup Flow

## Overview
Design a secure and modern authentication flow for **BankGo**, a professional banking application. The flow consists of two primary screens: a brand-focused Login screen and a secondary 6-digit PIN setup screen for quick access.

## Visual Style & Branding
- **Color Palette:** 
  - Primary: `#1A56DB` (Deep Royal Blue)
  - Secondary: `#0EA5E9` (Sky Blue)
  - Background: `#F9FAFB` (Soft Light Grey)
  - Accents: `#10B981` (Success Green for confirmations)
- **Typography:** Professional sans-serif (e.g., Inter or Public Sans).
- **UI Elements:** 
  - Rounded corners (`8px` to `12px`).
  - Subtle shadows for elevation.
  - Clean, high-contrast text for accessibility.
- **Imagery:** Minimalist illustrative icons matching the primary blue theme.

---

## Screen 1: Initial Login
**Goal:** Authenticate the user securely.

### Components
1.  **Header:** BankGo logo prominently displayed at the top.
2.  **Input Fields:**
    - "Email or Username" field with a leading user icon.
    - "Password" field with a trailing "eye" icon to toggle visibility.
3.  **Actions:**
    - Large "Sign In" primary button (`#1A56DB`).
    - "Forgot Password?" link below the password field.
    - "Biometric Login" (Face ID/Fingerprint) icon as an alternative option.
4.  **Footer:** "New to BankGo? Sign Up" link.

---

## Screen 2: PIN Setup
**Goal:** Allow the user to set a 6-digit security PIN for future quick logins.

### Components
1.  **Instructional Text:** "Set your Security PIN. Use this 6-digit code for quick and secure access to your account."
2.  **PIN Input:**
    - Six distinct numeric entry slots with focused state animation.
    - Masked input (dots or asterisks) for privacy.
3.  **Numeric Keypad:** A clean, custom in-app keypad (0-9) at the bottom half of the screen.
4.  **Actions:**
    - "Confirm PIN" button (initially disabled until 6 digits are entered).
    - "Skip for now" subtle text button for users who prefer biometric-only or password-only.

---

## Technical Considerations for Stitch
- Ensure the transition between Login and PIN setup feels seamless.
- Use card-based layouts for input groups to create a "containerized" feel.
- Maintain consistent padding and margin spacing (e.g., `24px` horizontal margins).
- Matching illustrative icons for "Security" and "Access" throughout.
