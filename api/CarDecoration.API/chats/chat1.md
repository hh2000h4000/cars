# Car Decoration Marketplace App

_Started 2026-06-18 12:22 UTC_

---

## User

Create a complete modern marketplace mobile application called:

"Car Decoration Services"

The application connects car owners with car decoration shops that can provide services at the customer's location (home, office, etc).

IMPORTANT:

This is NOT a directory app.

This is NOT an e-commerce app.

This is a full marketplace with customers, shops, requests, chat, quotations, approvals, reviews, disputes and admin approval workflow.

================================================

DESIGN REQUIREMENTS

Create a modern premium Arabic-first mobile app.

Style:

* Similar quality to Uber, Careem, Airbnb and Noon
* Modern cards
* Professional dashboard
* Clean UX
* Mobile-first
* Arabic RTL support
* Elegant dark and light mode
* Premium automotive feeling

Primary colors:

* Black
* Gold
* White

The UI must look investor-ready.

================================================

USER TYPES

1. Customer

2. Shop

3. Admin

================================================

AUTHENTICATION FLOW

First screen:

"Choose Account Type"

Option 1:
Customer

Option 2:
Shop

================================================

CUSTOMER REGISTRATION

Fields:

* Full Name
* Mobile Number
* Email
* Password

Customer account becomes active immediately.

================================================

SHOP REGISTRATION

Fields:

* Shop Name
* Commercial Registration Number
* Owner Name
* Mobile Number
* Email
* Password
* City
* Shop Address
* Shop Description
* Shop Logo
* Commercial Registration Document Upload

After registration:

Status = Pending Approval

Shop CANNOT:

* Receive requests
* Send quotations
* Appear in search

Until Admin approves the shop.

================================================

ADMIN SHOP APPROVAL

Admin dashboard must include:

Pending Shops

Admin can:

* Approve Shop
* Reject Shop
* Request Additional Documents

================================================

CUSTOMER FLOW

Customer can:

* Create profile
* Add multiple vehicles
* Manage vehicles
* Upload vehicle photos
* Create service requests
* Chat with shops
* Receive quotations
* Approve quotation
* Track request status
* Submit review
* Open complaint

================================================

VEHICLE MANAGEMENT

Customer can add unlimited vehicles.

Vehicle Fields:

* Brand
* Model
* Year
* Color
* Plate Number (Optional)

Vehicle Photos:

* Front
* Rear
* Side
* Interior
* Additional Photos

================================================

SERVICE REQUEST FLOW

Customer creates request:

Fields:

* Vehicle
* Service Description
* Photos
* Preferred Date
* Preferred Time
* Customer Location
* Notes

================================================

SHOP SELECTION

After request creation:

Display shops ordered by:

1. Distance
2. Rating
3. Completed Jobs

Customer can choose:

* One Shop
* Multiple Shops
* All Nearby Shops

Request is sent only to selected shops.

================================================

SHOP REQUEST MANAGEMENT

Shop receives request.

Actions:

* View Request
* View Vehicle Photos
* Start Chat
* Ask Questions
* Send Quotation
* Ignore Request

================================================

CHAT SYSTEM

VERY IMPORTANT

Chat must be fully functional.

Request-based chat.

Each request has its own chat room.

Support:

* Text Messages
* Images
* Attachments

Chats are stored permanently.

================================================

QUOTATION SYSTEM

VERY IMPORTANT

Quotation is NOT a chat message.

Quotation is a formal object.

Fields:

* Service Details
* Parts Used
* Warranty Period
* Visit Fee
* Execution Time
* Final Price

Customer Actions:

* Accept
* Reject

================================================

QUOTATION APPROVAL FLOW

When customer accepts one quotation:

Request status changes to:

Shop Selected

System automatically:

* Locks request
* Rejects other quotations
* Prevents new quotations
* Keeps chat open only with selected shop

================================================

REQUEST STATUS FLOW

Draft

Pending Shops Response

Offers Received

Shop Selected

Appointment Scheduled

In Progress

Completed

Cancelled

Disputed

================================================

SHOP PROFILE PAGE

Must contain:

* Shop Logo
* Cover Image
* Description
* Rating
* Reviews
* Number of Completed Jobs
* City
* Address
* Services Offered
* Photo Gallery

================================================

CUSTOMER PROFILE PAGE

Must contain:

* Personal Information
* Vehicles
* Active Requests
* Request History
* Reviews Given

================================================

REVIEW SYSTEM

After completion:

Customer can rate:

* Work Quality
* Communication
* Timeliness
* Overall Experience

And write a review.

================================================

COMPLAINT SYSTEM

Customer can open dispute.

Reasons:

* Price Changed
* Late Arrival
* No Show
* Poor Quality
* Different Service
* Other

Admin can manage disputes.

================================================

ADMIN DASHBOARD

Manage:

* Customers
* Shops
* Requests
* Chats
* Quotations
* Complaints
* Reviews

================================================

IMPORTANT

Generate ALL screens.

Generate ALL user flows.

Generate realistic sample data.

Generate database structure.

Generate relationships.

Generate clickable production-ready UI design.

Do not generate placeholders.

Do not generate generic cards.

Create a real marketplace experience similar to Uber and Airbnb quality.

## Assistant

This is a large, detailed brief. Before I build, a few decisions will shape the whole app — let me lock those down.

_[tool: questions_v2]_

## User

Questions answered:
- primary_mode: Light mode primary (white + gold)
- arabic_font: Tajawal (geometric, premium — like Careem)
- scope_depth: Decide for me
- device_frame: Yes — iOS phone bezel around every screen
- content_lang: Fully Arabic (names, shops, services, chat)
- city_context: Saudi Arabia (Riyadh, Jeddah — SAR)
- hero_screens: Customer home / shop discovery

## Assistant

This is a big build. Let me set up a task list, then start constructing the app as a single streaming Design Component.

_[tool: update_todos]_

Now the foundation — logic class with all sample data, navigation router, and interactive state (chat, quotations, reviews, complaints).

_[tool: dc_write]_

Let me check the render and fix the broken logo gradient I spotted.

_[tool: show_html]_

_[tool: dc_html_str_replace]_

_[tool: show_html]_

The foundation renders beautifully — premium dark hero, clean RTL, gold accents, working index. Now let me append the remaining screens. First batch: customer registration, shop registration, pending, home (hero), and shop profile.

_[tool: dc_html_str_replace]_

I referenced `shopFields` — need to add it to the logic.

_[tool: dc_js_str_replace]_

_[tool: dc_js_str_replace]_

Now the hero home screen and shop profile — the most important screens.

_[tool: dc_html_str_replace]_

The `<dc-icon>` tag isn't real — let me replace the category grid with explicit inline-SVG tiles.

_[tool: dc_html_str_replace]_

_[tool: multi_screenshot]_

Let me navigate to the home screen to verify it.

_[tool: multi_screenshot]_

_[tool: eval_js]_

_[tool: get_webview_logs]_

_[tool: eval_js]_

_[tool: eval_js]_

_[tool: show_html]_

_[tool: eval_js]_

Works now — that was stale state from before the reload. Let me capture home and shop screens.

_[tool: multi_screenshot]_

The live DOM has content (6.7KB) — html-to-image just isn't capturing the absolutely-positioned screen. Let me use a real pixel capture instead.

_[tool: save_screenshot]_

_[tool: save_screenshot]_

_[tool: save_screenshot]_

_[tool: eval_js]_

Found it — the `animation:fadeUp` entry animation starts at `opacity:0`, and the capture grabs it mid-animation. These entry animations break screenshots. Let me remove them.

_[tool: grep]_

_[tool: dc_html_str_replace]_

_[tool: dc_html_str_replace]_

_[tool: dc_html_str_replace]_

_[tool: dc_html_str_replace]_

Also fix the `popIn` ring in the pending screen (same opacity issue). Let me reload and verify home + shop render now.

_[tool: show_html]_

_[tool: save_screenshot]_

Home looks great now. Let me continue with the vehicles, add-vehicle, service-request, and shop-selection screens.

_[tool: dc_html_str_replace]_

Adding the computed selection-style helpers I referenced.

_[tool: dc_js_str_replace]_

_[tool: dc_js_str_replace]_

Now the core flow — requests list, tracking with quotations, formal quotation, chat, review, complaint, and profile.

_[tool: dc_js_str_replace]_

_[tool: dc_html_str_replace]_

Now wiring up all the computed values these screens reference.

_[tool: dc_js_str_replace]_

_[tool: dc_js_str_replace]_

_[tool: dc_js_str_replace]_

_[tool: dc_js_str_replace]_

Now the steps stepper data, `acceptBest`, `complaintDone` nav, and profile menu — plus the return values.

_[tool: dc_js_str_replace]_

_[tool: dc_js_str_replace]_

_[tool: dc_js_str_replace]_

_[tool: dc_js_str_replace]_

Now fix the profile menu — replace the `{{ m.icon }}` text-hole rows with explicit icon rows.

_[tool: dc_html_str_replace]_

Let me verify this batch renders correctly across the key screens.

_[tool: show_html]_

## User

continue

## Assistant

_[tool: save_screenshot]_

_[tool: show_html]_

_[tool: show_html]_

_[tool: save_screenshot]_

Excellent — tracking stepper, chat (RTL bubbles correct), and profile all look premium. Customer flow is complete. Now the Shop side: dashboard, request inbox, request detail, and send-quotation.

_[tool: dc_html_str_replace]_

`sentQuote` isn't exposed. Let me add it, then build the Admin screens.

_[tool: dc_js_str_replace]_

_[tool: dc_html_str_replace]_

Now the admin computed data: `adminManage`, pending status styling, dispute severity/status colors.

_[tool: dc_js_str_replace]_

_[tool: dc_js_str_replace]_

_[tool: dc_js_str_replace]_

All screens built. Let me update todos and verify the shop + admin screens.

_[tool: update_todos]_

_[tool: show_html]_

_[tool: save_screenshot]_

All shop and admin screens look polished — premium dark admin theme contrasts beautifully with the light customer app. The brief also asks for the database structure & relationships, so let me add a clean schema board beside the phone (and drop the empty dark slot).

_[tool: dc_html_str_replace]_

_[tool: dc_js_str_replace]_

_[tool: dc_js_str_replace]_

_[tool: update_todos]_

_[tool: show_html]_

_[tool: save_screenshot]_

Everything renders — the onboarding hero, the navigation index, and the data model board are all in place. The full marketplace is complete: customer app (light), shop app, admin (dark), plus the database schema board. Let me hand it to verification.

_[tool: ready_for_verification]_

Done. **خدمات تزيين السيارات — Car Decoration Services** is a complete, clickable Arabic-first marketplace prototype.

**What's built** (25 screens, fully navigable via the left index or in-app taps):
- **Customer** (light/gold): onboarding & registration, home/shop discovery, shop profile, vehicle management with photo slots, service request creation, shop selection (single/multiple/all-nearby), requests list + live status tracker, formal quotations (accept/reject with auto-lock & rejection of others), request-based chat with working text/image send, multi-dimension reviews, complaint/dispute flow, profile.
- **Shop**: dashboard with KPIs, incoming request inbox, request detail with vehicle photos, formal quotation builder, pending-approval gate.
- **Admin** (premium dark): dashboard, shop approval (approve / reject / request docs — interactive), dispute management.
- **Data model board** beside the phone: 10 entities with PK/FK fields and all relationships.

The chat input, shop multi-select, star ratings, complaint reasons, quotation acceptance, and admin approval buttons are all live and stateful.

Two notes: the seven-step status tracker reflects the *Shop Selected* state once you accept a quotation; and account-type / shop status are demo toggles (no backend), so registration always lands on the right next screen.

