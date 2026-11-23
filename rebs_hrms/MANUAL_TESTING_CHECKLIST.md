# Manual Testing Checklist

Use this checklist before recording the demo and submitting the assignment.

## Launch and dashboard

- [x] Launch the app and confirm the dashboard loads employee details, leave balance, and attendance history.
- [x] After at least one successful load, disable connectivity and confirm cached dashboard data remains visible.
- [x] Confirm the dashboard has a clear loading, error, and offline-cached state.

## Bottom navigation

- [x] Tap **Leave** and confirm it switches tabs instead of pushing a new route.
- [x] Tap **Dashboard** and confirm it returns to the existing dashboard state.
- [x] Enter dates and a reason in the leave form, switch tabs, then return and confirm the entered form data remains.

## Check-in and check-out

- [ ] Tap **Check In** once and confirm the button shows a progress spinner immediately.
- [ ] Confirm a new attendance event appears promptly after the local save.
- [ ] With a slow API or no internet, confirm the event shows **Pending**.
- [ ] With connectivity, confirm the event changes to **Synced** after synchronization.
- [ ] Rapidly tap **Check In** and confirm only one event is created.
- [ ] Try **Check Out** before Check In and confirm it is rejected.
- [ ] Try Check In twice and Check Out twice and confirm duplicates are rejected.
- [ ] Test outside the configured office radius and confirm the error message includes meaningful distance feedback.
- [ ] Test denied and permanently denied location permission, including the **Open Settings** action.

## Offline persistence and sync

- [ ] Disable connectivity and create a valid check-in or check-out event.
- [ ] Confirm the event has **Pending** status.
- [ ] Force-close and reopen the app; confirm the pending event remains.
- [ ] Re-enable connectivity and use **Sync Now**; confirm the event becomes **Synced**.
- [ ] Test the mock server's slow/timeout scenario; confirm the event remains pending for a retry.
- [ ] Test the mock server's duplicate-conflict scenario; confirm the same event ID is not duplicated on the server.

## Leave application

- [ ] Submit a valid Casual leave request.
- [ ] Submit a valid Sick leave request.
- [ ] Confirm the validation message appears for a past start date.
- [ ] Confirm the validation message appears when the end date is before the start date.
- [ ] Confirm the validation message appears for a reason with fewer than 10 non-whitespace characters.
- [ ] Confirm the validation message appears when requested days exceed available balance.
- [ ] Confirm the validation message appears for overlap with Pending or Approved leave.
- [ ] Disable connectivity and attempt leave submission; confirm it is refused.
- [ ] While offline, confirm already loaded leave requests remain visible.
- [ ] Test the mock server's leave rejection and confirm the returned error is shown.

## Layout and delivery

- [ ] Test on a small Android emulator and a larger device/emulator.
- [ ] Confirm cards, buttons, date controls, and bottom navigation do not overflow.
- [ ] Build and install the debug APK.
- [ ] Record the required demo: dashboard loading, online check-in, offline attendance action, restart with pending action preserved, synchronization after reconnecting, and leave validation/submission.
