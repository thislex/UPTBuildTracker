# Core Data Model Update Instructions

## Important: Update Your .xcdatamodeld File

The code changes have been made, but you need to update your Core Data model in Xcode to add the new sync tracking properties.

---

## Steps to Update Core Data Model

### Option 1: Add Properties to Existing Model (Simple - Use This)

1. **Open your project in Xcode**

2. **Find your `.xcdatamodeld` file** in the Project Navigator (probably named `UPTBuildTracker.xcdatamodeld`)

3. **Click on it** to open the Data Model Editor

4. **Select the `BuildEntity` entity** in the left panel

5. **Click the "+" button** under the Attributes section

6. **Add these three new attributes:**

   | Attribute Name | Type | Optional | Default Value |
   |---------------|------|----------|---------------|
   | `syncStatus` | String | ✅ Yes | (none) |
   | `lastSyncAttempt` | Date | ✅ Yes | (none) |
   | `syncError` | String | ✅ Yes | (none) |

7. **Save the file** (⌘S)

8. **Clean Build Folder** (⌘⇧K)

9. **Build and Run** (⌘R)

That's it! Since the attributes are optional, existing data will work fine with `nil` values.

---

## What Each Property Does

### `syncStatus` (String, Optional)
- Stores: `"synced"`, `"pending"`, or `"failed"`
- Purpose: Tracks whether the build has been uploaded to Google Sheets
- `nil` = treated as synced (for backward compatibility)

### `lastSyncAttempt` (Date, Optional)
- Stores: Timestamp of the last upload attempt
- Purpose: Helps track when we last tried to sync
- `nil` = never attempted or not tracked

### `syncError` (String, Optional)
- Stores: Error message from failed upload
- Purpose: Shows user why sync failed so they can fix it
- `nil` = no error or successful sync

---

## Verification

After updating the model, verify it worked:

1. **Build the app** - Should compile without errors
2. **Run the app** - Should launch without crashing
3. **Check existing builds** - Old builds should still appear in Archive
4. **Save a new build** - Should work and show sync status icon
5. **Test retry** - Failed builds should show retry button

---

## Troubleshooting

### "The model used to open the store is incompatible" Error

This means Core Data detected schema changes. Solutions:

**Quick Fix (Development Only):**
- Delete the app from simulator/device
- This clears the old database
- Rebuild and run - fresh database will be created

**Production Fix (Preserves Data):**
- Create a new model version (Model → Add Model Version)
- Set up lightweight migration
- This is more complex but preserves user data

For now, since you're in development, just delete and reinstall the app.

---

## Alternative: Manual Testing Without Model Update

If you want to test the code before updating the model:

1. The app will build but sync features won't work properly
2. You'll get runtime warnings about unknown properties
3. The code is there but Core Data will ignore the new properties

**Not recommended** - Better to update the model properly now.

---

## Next Steps

After updating the Core Data model:

1. ✅ Test saving a build with valid Google Sheets URL
2. ✅ Test saving a build with invalid URL (should fail)
3. ✅ Check Archive view shows sync status icons
4. ✅ Test retry button on failed build
5. ✅ Test "Sync All" button with multiple failed builds

---

Need help? The code is already updated - you just need to update the visual model in Xcode!
