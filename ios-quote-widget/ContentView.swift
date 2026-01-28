import SwiftUI

struct ContentView: View {
    @StateObject private var store = QuoteStore()
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("notificationMinutes") private var notificationMinutes: Int = 9 * 60
    @State private var notificationStatusMessage: String?

    private var notificationDate: Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return calendar.date(byAdding: .minute, value: notificationMinutes, to: today) ?? Date()
    }

    private var notificationBinding: Binding<Date> {
        Binding(
            get: { notificationDate },
            set: { newDate in
                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: newDate)
                let minute = calendar.component(.minute, from: newDate)
                notificationMinutes = hour * 60 + minute
            }
        )
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Daily Motivation")
                .font(.title)
                .fontWeight(.semibold)

            if let quote = store.quote {
                Text("\"\(quote.text)\"")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text("- \(quote.author)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else if store.isLoading {
                ProgressView("Loading quote...")
            } else {
                Text(store.errorMessage ?? "No quote yet.")
                    .foregroundColor(.secondary)
            }

            Button {
                Task {
                    await store.refreshIfNeeded(force: true)
                }
            } label: {
                Text(store.isLoading ? "Loading..." : "Refresh Now")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(store.isLoading)
            .padding(.horizontal)

            VStack(spacing: 8) {
                Toggle("Daily Notification", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { enabled in
                        if enabled {
                            Task {
                                let granted = await NotificationManager.shared.requestAuthorization()
                                if granted {
                                    notificationsEnabled = true
                                    scheduleNotificationIfPossible()
                                    notificationStatusMessage = nil
                                } else {
                                    notificationsEnabled = false
                                    notificationStatusMessage = "Notifications are disabled in Settings."
                                }
                            }
                        } else {
                            NotificationManager.shared.cancelNotifications()
                        }
                    }

                DatePicker("Notification Time", selection: notificationBinding, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .disabled(!notificationsEnabled)
                    .onChange(of: notificationMinutes) { _ in
                        if notificationsEnabled {
                            scheduleNotificationIfPossible()
                        }
                    }

                if let notificationStatusMessage {
                    Text(notificationStatusMessage)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)

            Spacer()

            Link("Inspirational quotes provided by ZenQuotes API", destination: URL(string: "https://zenquotes.io/")!)
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
        }
        .padding(.top, 32)
        .onAppear {
            store.loadCachedQuote()
            Task {
                await store.refreshIfNeeded(force: false)
            }
        }
        .onChange(of: store.quote) { _ in
            if notificationsEnabled {
                scheduleNotificationIfPossible()
            }
        }
    }

    private func scheduleNotificationIfPossible() {
        guard let quote = store.quote else { return }
        NotificationManager.shared.scheduleNextNotification(quote: quote, minutesAfterMidnight: notificationMinutes)
    }
}

#Preview {
    ContentView()
}

