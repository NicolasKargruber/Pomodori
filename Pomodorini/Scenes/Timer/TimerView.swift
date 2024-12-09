//
//  TimerView.swift
//  HyperfocusBreaker
//
//  Created by Nicolas Kargruber on 17.11.24.
//

import SwiftUI

/// A view that represents a Pomodorino timer screen.
///
/// This screen allows the user to track their Pomodoro progress, displaying the timer,
/// a count of completed Pomodorini, and a button to manage the timer state.
struct TimerView: View {
    // MARK: - State Properties

    /// A flag to indicate whether the timer should reset.
    @State private var shouldResetTimer = false

    /// The total count of collected Pomodorini.
    @State var pomodorinoCount = 0

    /// The timer manager responsible for tracking the countdown timer.
    @State var timerManager: TimerManager

    // MARK: - Initializer

    /// Initializes the `TimerView` with a specified duration.
    /// - Parameter durationInMinutes: The duration of the timer in minutes. Default is 25 minutes.
    init(durationInMinutes: Int = 25) {
        try! self.timerManager = TimerManager(
            totalMinutes: durationInMinutes, allowsOvertime: false)
    }

    // MARK: - Computed Properties

    /// Indicates whether the timer is currently running.
    private var isGrowing: Bool {
        timerManager.isRunning
    }

    /// Indicates whether the Pomodorino is ripe (timer has completed).
    private var isRipe: Bool {
        timerManager.isCompleted
    }

    /// Represents the ripeness of the Pomodorino, as a value from 0.0 to 2.0.
    private var pomodoroRipeness: Double {
        timerManager.progress
    }

    /// Determines the color of the Pomodorino based on its ripeness.
    private var pomodoroColor: Color {
        do {
            return try PomodorinoGradient.color(forRipeness: pomodoroRipeness)
        } catch {
            print("Error determining color: \(error)")
            return Color.black
        }
    }

    /// Determines the state of the timer button.
    private var timerButtonState: TimerButton.TimerState {
        if isRipe {
            return .finished
        } else if isGrowing {
            return .running
        } else {
            return .notStarted
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // MARK: Background
                createBackground()

                // MARK: Content
                VStack {
                    // Pomodorino Count Display
                    Button("\(pomodorinoCount) 🍅") {}
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .buttonStyle(.bordered)
                        .tint(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack {
                        VStack(alignment: .trailing) {
                            // Goal Display
                            Text("Goal: 25:00")
                                .font(.system(size: 24, weight: .regular))
                                .foregroundColor(.white)
                                .padding(.horizontal, 72)

                            // Timer Display
                            Text(timerManager.formattedTime)
                                .font(.system(size: 80, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)

                        // Timer Button
                        TimerButton(
                            pomodorinoCount: $pomodorinoCount,
                            shouldResetTimer: $shouldResetTimer,
                            state: timerButtonState,
                            onStart: { timerManager.start() },
                            onNavigate: {}
                        )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            .onDisappear {
                timerManager.stop()
            }
        }
        .onChange(of: shouldResetTimer, initial: false) { _, newValue in
            if newValue {
                timerManager.start()
            }
        }
    }
    
    // MARK: - Actions
    /// Creates background image.
    private func createBackground() -> some View {
        LinearGradient(
            gradient: Gradient(colors: [
                pomodoroColor,
                pomodoroColor.mix(with: Color.black, by: 0.2)
            ]),
            startPoint: .topTrailing,
            endPoint: .bottomLeading
        )
        .ignoresSafeArea()
        .overlay {
            Image("Pomodorini_Hat")
                .offset(x: 90, y: -320)
        }
    }
}

// MARK: - Preview

#Preview {
    TimerView(durationInMinutes: 1)
}
