# FitBook 2026 — What would make it production-grade

Short list of **simple** features users would actually open every day.

---

## 1. Habit streak (highest impact)
- **What:** “1 day / 7 days / 30 days” streak + flame badge on home.
- **Why:** People come back to keep the streak alive.
- **How:** One `streak` table + daily check when they open Exercises/Foods.

## 2. One-tap “Done” on exercises
- **What:** Big **I did this** button on exercise detail → logs a session.
- **Why:** Feels like a workout app without building a full planner.
- **How:** Hive/Supabase `sessions` + weekly counter on home.

## 3. Saved meal plan (day picker)
- **What:** “My Mon–Sun plan” — drag foods into Breakfast / Lunch / Dinner.
- **Why:** Turns food tips into something they follow.
- **How:** Simple list + localStorage/Supabase; export as text.

## 4. Body metrics + progress ring
- **What:** Log weight (kg) weekly; ring shows Δ from start.
- **Why:** Visible change = real usage.
- **How:** Already have height/weight in settings — just add history chart.

## 5. Offline pack
- **What:** After first load, app works with **no internet**.
- **Why:** Gym basements / poor data; looks “real product”.
- **How:** Hive cache already exists — make UI offline-first, queue sync.

## 6. Search + filters that feel smart
- **What:** Recent searches, “bodyweight only”, “high protein”, sort by protein.
- **Why:** Faster find = more opens.
- **How:** Already half-built; add recent + 2 quick chips.

## 7. Push reminders (beyond 9 AM food)
- **What:** “Gym day?” at user-picked time + rest-day tip.
- **Why:** Reminders drive daily active users.
- **How:** Same local notifications channel; let user pick time in Settings.

## 8. Share cards
- **What:** “I trained today” / food tip card → Instagram/WhatsApp image.
- **Why:** Free growth.
- **How:** `share_plus` + simple card screenshot.

## 9. Auth + cloud backup (optional but trusted)
- **What:** Email/Google login; favourites + history sync.
- **Why:** Multi-device users stay.
- **How:** Supabase Auth (you already have the project).

## 10. Pro polish (low effort, high trust)
- App icon + Play screenshots  
- Empty/error/offline states in **every language** you ship  
- Crash reporting (Sentry/Crashlytics)  
- Rate-us after 3rd successful session  

---

### Build order (if you only do 5 things)
1. Streak  
2. I-did-this logging  
3. Offline-first UI  
4. Reminder time picker  
5. Share cards  

Those five turn a **library** into a **habit product**.

### Data you already have
| Asset | Use for |
|--------|---------|
| 1,300+ exercises + Hero detail | Gym browse + logs |
| 150+ foods + daily amount | Meal habit + 9 AM tips |
| Height / weight / goal | Streak + plan personalization |
| Supabase + Hive | Sync + offline |

Keep UI light, white, and one clear primary action per screen.
