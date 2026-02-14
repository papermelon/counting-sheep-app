//
//  OnboardingFlowView.swift
//  Counting Sheep
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

struct OnboardingFlowView: View {
    @StateObject private var flowState: OnboardingFlowState
    let onComplete: () -> Void

    init(onComplete: @escaping () -> Void) {
        _flowState = StateObject(wrappedValue: OnboardingFlowState(answers: OnboardingPersistence.loadAnswers() ?? OnboardingAnswers()))
        self.onComplete = onComplete
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar: back + progress (extra top padding to clear status bar)
                HStack(alignment: .center, spacing: 12) {
                    if flowState.currentStep.canGoBack {
                        OnboardingBackButton {
                            flowState.previousStep()
                        }
                    } else {
                        Color.clear.frame(width: 44, height: 44)
                    }

                    OnboardingProgressBar(progress: flowState.progress)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 16)
                .padding(.top, 52)
                .padding(.bottom, 16)

                // Step content
                stepContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Continue / Finish
                OnboardingContinueButton(
                    title: flowState.currentStep.isLast ? "Finish" : "Continue",
                    action: handleContinue,
                    isEnabled: canContinue
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.white)
    }

    private var answersBinding: Binding<OnboardingAnswers> {
        Binding(
            get: { flowState.answers },
            set: { flowState.answers = $0 }
        )
    }

    @ViewBuilder
    private var stepContent: some View {
        switch flowState.currentStep {
        case .name:
            OnboardingNameStep(answers: answersBinding)
        case .habitTrackRecord:
            OnboardingHabitTrackRecordStep(answers: answersBinding)
        case .motivational:
            OnboardingMotivationalStep()
        case .appValue:
            OnboardingAppValueStep()
        case .bedtime:
            OnboardingBedtimeStep(answers: answersBinding)
        case .sleepDuration:
            OnboardingSleepDurationStep(answers: answersBinding)
        case .sleepChallenges:
            OnboardingSleepChallengesStep(answers: answersBinding)
        case .exerciseFrequency:
            OnboardingExerciseStep(answers: answersBinding)
        case .screentimeConcerns:
            OnboardingScreentimeStep(answers: answersBinding)
        case .dietGoals:
            OnboardingDietStep(answers: answersBinding)
        case .pickHabit:
            OnboardingPickHabitStep(answers: answersBinding)
        case .finish:
            OnboardingFinishStep()
        }
    }

    private var canContinue: Bool {
        switch flowState.currentStep {
        case .name:
            return !flowState.answers.userName.trimmingCharacters(in: .whitespaces).isEmpty
        case .habitTrackRecord:
            return flowState.answers.habitTrackRecord != nil
        case .pickHabit:
            return !flowState.answers.selectedHabitIds.isEmpty
        case .motivational, .appValue, .finish:
            return true
        case .bedtime:
            return flowState.answers.typicalBedtime != nil
        case .sleepDuration:
            return flowState.answers.sleepDurationBucket != nil
        case .sleepChallenges, .screentimeConcerns, .dietGoals:
            return true  // optional multi-select
        case .exerciseFrequency:
            return flowState.answers.exerciseFrequency != nil
        }
    }

    private func handleContinue() {
        if flowState.currentStep.isLast {
            flowState.complete()
            onComplete()
        } else {
            flowState.nextStep()
        }
    }
}

#Preview {
    OnboardingFlowView(onComplete: {})
}
