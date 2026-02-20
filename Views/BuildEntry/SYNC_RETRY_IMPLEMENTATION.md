# Sync Retry Feature Implementation

## Overview
This document explains the implementation of the **Sync Retry** feature, which allows users to retry failed Google Sheets uploads from the Archive section.

---

## What Was Changed

### 1. **Core Data Model Updates** (`BuildEntity+CoreDataProperties.swift`)
Added three new properties to track sync status:
- `syncStatus: String?` - Tracks if build is "synced", "pending", or "failed"
- `lastSyncAttempt: Date?` - Timestamp of last sync attempt
- `syncError: String?` - Error message if sync failed

**Why?** We need to know which builds failed to upload so we can retry them later.

---

### 2. **Data Service Protocol Updates** (`DataServiceProtocol.swift`)
Updated the protocol and implementation:
- Modified `saveBuild()` to accept a `syncStatus` parameter (defaults to "pending")
- Added `updateSyncStatus()` method to update sync status after upload attempts

**Why?** This allows us to mark builds with their sync status when saving and update them after retry attempts.

---

### 3. **Build Entry View Model Updates** (`BuildEntryViewModel.swift`)
Updated the save logic to properly track sync status:
- When saving a build, it's initially marked as "pending"
- After successful upload → marked as "synced"
- After failed upload → marked as "failed" with error message
- Added helper method `fetchBuildEntity()` to retrieve saved entities for status updates
- Added CoreData import

**Why?** The app now knows when an upload fails and can inform the user they can retry from Archive.

---

### 4. **Archive View Model Updates** (`ArchiveViewModel.swift`)
Added retry functionality with three new methods:

#### `retrySyncBuild(_ build:sheetsURL:)`
- Retries syncing a single build
- Updates sync status based on success/failure
- Shows alert with result

#### `syncAllPendingBuilds(_ builds:sheetsURL:)`
- Finds all builds with "pending" or "failed" status
- Attempts to sync each one
- Includes 0.5 second delay between uploads to avoid overwhelming the server
- Shows summary of results (success count vs failure count)

#### `buildRecordFrom(_ entity:)`
- Helper method to convert `BuildEntity` (Core Data) back to `BuildRecord` (upload format)

**Why?** This is the core retry logic that handles re-uploading failed builds.

---

### 5. **Archive View UI Updates** (`ArchiveView.swift`)
Enhanced the UI with visual sync indicators and retry controls:

#### Visual Indicators
Each build now shows its sync status:
- 🟢 **Green checkmark cloud** (`checkmark.icloud`) - Successfully synced
- 🟠 **Orange clock** (`clock.arrow.circlepath`) - Pending sync
- 🔴 **Red exclamation cloud** (`exclamationmark.icloud`) - Failed sync
- Shows error message below failed builds

#### Individual Retry Button
- Blue circular arrow button appears next to pending/failed builds
- Tap to retry just that one build
- Disabled during sync operations

#### "Sync All" Button
- Appears in top-left toolbar when there are pending/failed builds
- Retries all failed builds at once
- Shows progress indicator during sync
- Great for batch retries after connectivity issues

#### Sync Status Alert
- Shows results after retry attempts
- Displays success/failure messages

---

## How It Works

### When Saving a New Build:
```
1. User fills form and taps "Save Build"
2. Build saved to Core Data with syncStatus = "pending"
3. App attempts Google Sheets upload
4. If successful → syncStatus = "synced" ✅
5. If failed → syncStatus = "failed", error stored ❌
6. User sees message: "You can retry from the Archive"
```

### When Retrying from Archive:
```
1. User opens Archive tab
2. Failed builds show red cloud icon 🔴
3. User taps retry button on a build (or "Sync All")
4. App converts BuildEntity back to BuildRecord
5. App attempts Google Sheets upload again
6. Status updated based on result
7. Alert shows success/failure message
```

---

## Benefits

✅ **No Data Loss** - Builds always saved locally first
✅ **Visual Feedback** - Clear indicators show sync status at a glance
✅ **Individual Control** - Retry specific builds or all at once
✅ **Error Transparency** - See exactly why a sync failed
✅ **Batch Operations** - Sync multiple failed builds with one tap
✅ **User-Friendly** - Clear instructions and feedback throughout

---

## User Experience Flow

### Scenario: Network Failure During Save
```
User fills out build form
    ↓
Taps "Save Build"
    ↓
Build saved locally ✅
    ↓
Google Sheets upload fails ❌ (no internet)
    ↓
Alert: "Build saved locally! ⚠️ Upload failed: The Internet connection appears to be offline. You can retry from the Archive."
    ↓
User goes to Archive tab
    ↓
Sees build with red cloud icon 🔴
    ↓
Taps retry button when internet is back
    ↓
Build synced successfully! ✅
    ↓
Icon changes to green checkmark cloud 🟢
```

---

## Technical Notes

### Database Migration
⚠️ **Important**: Since we added new properties to `BuildEntity`, you'll need to:
1. Update your Core Data model in Xcode (`.xcdatamodeld` file)
2. Add the three new attributes: `syncStatus`, `lastSyncAttempt`, `syncError`
3. Create a new model version OR mark attributes as optional (they already are in code)
4. Existing builds will have `nil` for these fields (treated as synced)

### Sync Status Values
- `"synced"` - Successfully uploaded to Google Sheets
- `"pending"` - Waiting to be uploaded (or initial state)
- `"failed"` - Upload attempt failed
- `nil` - Legacy builds created before this feature (treated as synced)

### Thread Safety
- All sync operations run on background tasks
- UI updates explicitly done on `MainActor`
- Core Data saves happen on main context

---

## Testing Checklist

- [ ] Save new build with valid Google Sheets URL → should show "synced"
- [ ] Save new build with invalid URL → should show "failed" with retry option
- [ ] Save new build with no URL → should show "synced" (no upload needed)
- [ ] Retry single failed build → status should update
- [ ] Retry all pending builds → should process all and show summary
- [ ] Check that sync indicators display correctly in Archive
- [ ] Verify error messages are helpful and actionable

---

## Future Enhancements (Optional)

- [ ] Automatic retry on app launch for pending builds
- [ ] Background sync using Background Tasks framework
- [ ] Sync queue with retry exponential backoff
- [ ] Filtering in Archive by sync status
- [ ] Bulk delete failed builds
- [ ] Settings option to auto-retry X times before marking as failed

---

Made by Lexter S. Tapawan
UPT Build Tracker™ 2025
