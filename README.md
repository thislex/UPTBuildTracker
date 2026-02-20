# UPT Build Tracker

A SwiftUI iOS application for tracking product builds with serial number scanning, data validation, and cloud synchronization.

## Overview

UPT Build Tracker is a production tracking app designed for small manufacturing teams. It streamlines the process of logging product builds by using barcode scanning for serial numbers and syncing data to Google Sheets for team-wide access.

## Features

### 📱 Core Functionality
- **Barcode Scanning**: Fast and accurate barcode/QR code scanning for serial numbers
- **Manual Entry**: Fallback text input for all fields
- **Multiple Product Types**: Track BMV, Orion, MPPT, and Shore Charger serial numbers
- **Configuration Options**: Orion charge rate selection (18A/50A)
- **Build Metadata**: Capture builder/tester initials and dates
- **Unique Build IDs**: Auto-generated unique identifiers for each build

### 💾 Data Management
- **Local Storage**: Core Data persistence for offline access
- **Cloud Sync**: Automatic synchronization with Google Sheets
- **Archive View**: Browse and search all historical builds
- **CSV Export**: Export build data for backup or analysis
- **Search Functionality**: Filter builds by ID, serial number, or initials

### 🎨 User Experience
- **Clean UI**: Modern SwiftUI interface with intuitive navigation
- **Tab Navigation**: Easy access to New Build, Archive, and Settings
- **Input Validation**: 6-character limit on PIN codes
- **Keyboard Handling**: Auto-dismiss keyboard after save
- **Form Validation**: Required fields checked before submission

## Tech Stack

- **Language**: Swift
- **Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Minimum iOS**: 16.0
- **Storage**: Core Data
- **Camera**: AVFoundation for barcode scanning
- **Cloud Sync**: Google Sheets via Apps Script

## Requirements

- iOS 16.0+
- Xcode 15.0+
- iPhone or iPad with camera
- Google account (for cloud sync)

## Installation

### For Developers

1. Clone the repository:
```bash
git clone https://github.com/yourusername/UPTBuildTracker.git
cd UPTBuildTracker
```

2. Open the project in Xcode:
```bash
open UPTBuildTracker.xcodeproj
```

3. Build and run on your device (Simulator won't have camera access)

### For End Users

#### Option 1: TestFlight (Recommended)
1. Install TestFlight from the App Store
2. Use the invite link provided by your admin
3. Install UPT Build Tracker from TestFlight

#### Option 2: Direct Install
1. Connect your iPhone to the developer's Mac
2. Developer runs the app from Xcode onto your device

## Setup

### Google Sheets Integration

1. **Create a Google Sheet** with these column headers:
```
   Unique ID | BMV Serial Number | BMV PIN | Orion Serial Number | Orion PIN | 
   Orion Charge Rate | MPPT Serial Number | MPPT PIN | Shore Charger Serial Number | 
   Builder Initials | Build Date | Tester Initials | Test Date
```

2. **Create Google Apps Script**:
   - In your sheet: Extensions → Apps Script
   - Paste the following code:
```javascript
function doPost(e) {
  try {
    var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
    var data = JSON.parse(e.postData.contents);
    
    sheet.appendRow([
      data.uniqueID,
      data.bmvSerialNumber,
      data.bmvPIN,
      data.orionSerialNumber,
      data.orionPIN,
      data.orionChargeRate,
      data.mpptSerialNumber,
      data.mpptPIN,
      data.shoreChargerSerialNumber,
      data.builderInitials,
      data.buildDate,
      data.testerInitials,
      data.testDate
    ]);
    
    return ContentService.createTextOutput(JSON.stringify({
      result: "success",
      row: sheet.getLastRow()
    })).setMimeType(ContentService.MimeType.JSON);
    
  } catch(error) {
    return ContentService.createTextOutput(JSON.stringify({
      result: "error",
      error: error.toString()
    })).setMimeType(ContentService.MimeType.JSON);
  }
}
```

3. **Deploy the Script**:
   - Click Deploy → New deployment
   - Type: Web app
   - Execute as: Me
   - Who has access: Anyone
   - Copy the web app URL

4. **Configure the App**:
   - Open UPT Build Tracker
   - Go to Settings tab
   - Paste the web app URL
   - Done!

## Usage

### Adding a New Build

1. Tap **"New Build"** tab
2. Generate a unique ID (tap refresh icon)
3. For each serial number field:
   - **Scan**: Tap camera icon, point at barcode
   - **Type**: Tap field and enter manually
4. Enter PIN codes (6 digits max)
5. Select Orion charge rate (18A or 50A)
6. Enter builder initials and date
7. Enter tester initials and date
8. Tap **"Save Build"**

### Viewing Build History

1. Tap **"Archive"** tab
2. Browse all builds (newest first)
3. Use search bar to filter
4. Tap any build to see full details
5. Swipe left to delete a build

### Exporting Data

1. Go to **"Archive"** tab
2. Tap export button (top right)
3. Choose destination (Files, Email, AirDrop, etc.)
4. Data exported as CSV format

## Project Structure
```
UPTBuildTracker/
├── Models/
│   ├── BuildRecord.swift           # Data model
│   └── ScanField.swift             # Enum for scan types
├── ViewModels/
│   ├── BuildEntryViewModel.swift   # New build form logic
│   └── ArchiveViewModel.swift      # Archive/search logic
├── Views/
│   ├── BuildEntry/
│   │   └── BuildEntryView.swift    # New build form
│   ├── Archive/
│   │   ├── ArchiveView.swift       # Build list
│   │   └── BuildDetailView.swift   # Build details
│   ├── Scanner/
│   │   ├── CameraScannerView.swift # Scanner wrapper
│   │   └── SimpleBarcodeScanner.swift # Barcode scanner
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   └── GoogleSheetsInstructionsView.swift
│   └── Components/
│       └── DetailRow.swift          # Reusable UI component
├── Services/
│   ├── DataService.swift            # Core Data operations
│   └── GoogleSheetsService.swift    # Cloud sync
└── CoreData/
    ├── PersistenceController.swift  # Core Data setup
    ├── BuildEntity+CoreDataClass.swift
    ├── BuildEntity+CoreDataProperties.swift
    └── UPTBuildTracker.xcdatamodeld # Data model
```

## Architecture

The app follows the **MVVM (Model-View-ViewModel)** pattern:

- **Models**: Plain Swift structs for data (`BuildRecord`)
- **Views**: SwiftUI views (UI only, no business logic)
- **ViewModels**: `ObservableObject` classes containing business logic
- **Services**: Protocols and implementations for data operations

### Key Design Decisions

- **Dependency Injection**: ViewModels receive services via protocols
- **Single Source of Truth**: Core Data is primary storage
- **Optimistic Sync**: Local save always succeeds, cloud sync is best-effort
- **Barcode Priority**: Barcode scanning is primary input method
- **Manual Fallback**: Every field can be entered manually

## Data Flow
```
User Input → ViewModel → Service → Core Data (Local)
                      ↓
                 Google Sheets (Cloud)
```

1. User enters data via View
2. ViewModel validates and processes
3. DataService saves to Core Data (always succeeds)
4. GoogleSheetsService uploads to cloud (best effort)
5. Archive refreshes from Core Data

## Privacy & Permissions

- **Camera**: Required for barcode scanning (user prompted on first use)
- **Internet**: Required for Google Sheets sync (optional - app works offline)

## Known Limitations

- **Offline Mode**: Builds saved locally when offline, require manual sync later
- **PIN Format**: Leading zeros may be removed in Google Sheets (display issue only)
- **Concurrent Editing**: Last-write-wins for Google Sheets (no conflict resolution)
- **Barcode Types**: Supports Code128, Code39, EAN13, QR codes

## Troubleshooting

### Camera Not Working
1. Check Settings → Privacy → Camera → UPT Build Tracker is enabled
2. Delete and reinstall the app to reset permissions
3. Ensure you're testing on a real device (not simulator)

### Google Sheets Not Syncing
1. Verify the Apps Script URL in Settings
2. Check internet connection
3. Confirm Google Apps Script is deployed as "Anyone" access
4. Check Xcode console for error messages

### App Crashes on Save
1. Verify Core Data model matches entity definitions
2. Clean build folder (Shift + Cmd + K)
3. Delete app and reinstall

## Contributing

This is an internal company tool. For feature requests or bug reports, contact the development team.

## License

Proprietary - Internal Use Only

## Version History

### 1.0.0 (Current)
- Initial release
- Barcode scanning for all serial number fields
- Google Sheets integration
- Local Core Data storage
- Archive with search
- CSV export
- Orion charge rate selection

## Support

For questions or issues:
- Check the **Settings → Setup Instructions** in the app
- Contact your team administrator
- Review console logs in Xcode for debugging

## Credits

Developed for Crooked Finger Designs -- Fife, WA.

Built with SwiftUI, Core Data, and AVFoundation.
