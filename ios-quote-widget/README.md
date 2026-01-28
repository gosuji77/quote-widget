# iOS Daily Motivational Quote App (SwiftUI)

This folder contains the SwiftUI source files for an iOS 16 app that fetches the ZenQuotes daily quote and shows a daily notification.

## Requirements
- Xcode 15.x (recommended)
- iOS 16 deployment target

## How to use these files
1) In Xcode, create a new project:
   - iOS App
   - Interface: SwiftUI
   - Language: Swift
   - Deployment Target: iOS 16
2) Replace the generated `ContentView.swift` with the file in this folder.
3) Add the other Swift files from this folder to the project:
   - QuoteOfDayApp.swift
   - QuoteService.swift
   - QuoteStore.swift
   - NotificationManager.swift
4) Build and run on a simulator or device.

## Behavior notes
- The app caches the quote per ZenQuotes daily schedule (midnight CST).\n- ZenQuotes "today" changes at midnight CST per their docs. The app uses that CST date for caching, which may differ from your local day boundary.
- Notifications use the most recently fetched quote and schedule a single notification for the next selected time.
  To keep the quote fresh every day, open the app once daily so it can fetch the new quote.

## Attribution
The free ZenQuotes API requires attribution. The UI includes a link to ZenQuotes.

API docs: https://docs.zenquotes.io/zenquotes-documentation/


