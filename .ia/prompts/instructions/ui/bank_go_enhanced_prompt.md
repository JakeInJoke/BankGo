# Enhanced Stitch Design Prompt: BankGo Personal Banking

## Core Concept
**App Type:** Modern, high-security Personal Banking Mobile App (BankGo).
**Target Audience:** Modern banking users who value security and intuitive financial management.
**Vibe:** Professional, secure, minimalist, and "alive." Use a clean interface with a primary focus on trust and clarity.

## Global Design System (from DESIGN.md)
- **Primary Color:** #2563EB (Blue) - Interactive elements and CTAs.
- **Surface:** #FFFFFF (Cards) on a #F9FAFB (Background) feed.
- **Success:** #16A34A | **Error:** #DC2626 | **Warning:** #D97706.
- **Roundness:** `ROUND_TWELVE` for all cards and containers.
- **Interactions:** Minimum touch target of 44px. uniform padding.

---

## Screen-by-Screen Specifications

### 1. Secure Login Screen
- **Components:** Top-centered BankGo logo, "Welcome back" headline.
- **Interaction:** A masked 6-digit PIN input field.
- **Special Feature:** A custom on-screen numeric keypad. **Crucial:** The keypad layout must be randomized/shuffled for security.
- **State Logic:** Include a pulse loading state for the PIN field and a red error state with helpful micro-copy.

### 2. Main Dashboard (Financial Overview)
- **Layout:** Vertical feed of account cards.
- **Components:** 
  - Hero section showing "Total Available Balance" in a large, bold `Primary` font.
  - Individual Account Cards: Showing bank icon, account name, last 4 digits, and balance.
  - Bottom Navigation: Persistent bar with icons for "Home," "Transactions," and "Profile."
- **Empty State:** Use a "No accounts yet" illustration with a Primary "Link Account" retry button.

### 3. Card Management & Movement View
- **Components:** A high-fidelity virtual card visualization at the top.
- **Actions:** 
  - "Quick Actions" row: [Pay Services], [Transfer], [Freeze Card].
  - A toggle switch for "Disable Card" (turns the card grayscale and uses Error red for the toggle).
- **List:** Scrollable "Recent Movements" section specifically for this card.

### 4. Service Payments
- **Layout:** Category grid (Water, Electricity, Internet) using clean icons and label text.
- **Process:** Data entry form for "Reference Number" and "Amount" with inline validation against the current balance.

### 5. Transaction History (Global Movements)
- **Layout:** Full-screen paginated list.
- **Styling:** Grouped by date (e.g., "Today", "Yesterday"). Positive amounts in Success Green, negative in Error Red.
- **Feature:** A top search bar to filter by merchant or category.

### 6. Transfer Flow (Review & Confirm)
- **Structure:** Two-step confirmation pattern.
- **Step 1:** Data entry (Recipient, Amount).
- **Step 2:** Summary card for review.
- **Confirmation:** On tap, trigger a distinct **In-App Alert** system notification with a success checkmark and "View Receipt" option.

---

## Technical/UX Constraints
- **Registration:** Explicitly **DO NOT** include any registration or "Sign Up" buttons. All onboarding is handled offline.
- **Loading:** Use Shimmer/Skeleton loaders that match the `ROUND_TWELVE` card geometry.
- **Retry Logic:** Every error state must include a clearly visible "Retry" button.
