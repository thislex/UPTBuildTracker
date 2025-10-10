import SwiftUI

struct GoogleSheetsInstructionsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Google Sheets Setup")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Group {
                        Text("Step 1: Create a Google Sheet")
                            .font(.headline)
                        Text("Create a new Google Sheet with these column headers in row 1:\nUnique ID, BMV Serial Number, BMV PIN, Orion Serial Number, Orion PIN, MPPT Serial Number, MPPT PIN, Builder Initials, Build Date, Tester Initials, Test Date")
                            .font(.subheadline)
                    }
                    
                    Group {
                        Text("Step 2: Create Apps Script")
                            .font(.headline)
                        Text("1. In your Google Sheet, go to Extensions > Apps Script\n2. Delete any code and paste the following:")
                            .font(.subheadline)
                    }
                    
                    Text("""
                    function doPost(e) {
                      var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
                      var data = JSON.parse(e.postData.contents);
                      
                      sheet.appendRow([
                        data.uniqueID,
                        data.bmvSerialNumber,
                        data.bmvPIN,
                        data.orionSerialNumber,
                        data.orionPIN,
                        data.mpptSerialNumber,
                        data.mpptPIN,
                        data.builderInitials,
                        data.buildDate,
                        data.testerInitials,
                        data.testDate
                      ]);
                      
                      return ContentService.createTextOutput(JSON.stringify({result: "success"}))
                        .setMimeType(ContentService.MimeType.JSON);
                    }
                    """)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    
                    Group {
                        Text("Step 3: Deploy")
                            .font(.headline)
                        Text("1. Click 'Deploy' > 'New deployment'\n2. Click gear icon, select 'Web app'\n3. Set 'Execute as' to 'Me'\n4. Set 'Who has access' to 'Anyone'\n5. Click 'Deploy' and copy the URL\n6. Paste the URL in Settings")
                            .font(.subheadline)
                    }
                }
                .padding()
            }
            .navigationTitle("Setup Instructions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}