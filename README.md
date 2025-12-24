# iOS Motion Bubble Level

## Overview
A SwiftUI application visualizing device orientation (roll, pitch) using Core Motion. Features a custom bubble level UI, signal smoothing, and a synthesized Demo Mode.

## Settings & Specs
* **Update Frequency:** 60 Hz
* **Smoothing Factor ($\alpha$):** 0.15 (Low-pass filter)
* **Concurrency:** Swift 6 `Task` isolation (No legacy Timers)
* **Architecture:** MVVM with `@MainActor`

## Environment
* **IDE:** Xcode 16+
* **System:** iOS 17+
* **Hardware:** iOS Simulator & Physical iOS Device

## Filter Logic
Implemented using an exponential moving average to reduce sensor jitter:

```swift
private func processMotionData(_ motion: CMDeviceMotion)
{
    // Low-Pass Filter Formula
    self.rawRoll = (smoothingAlpha * newRoll) + ((1 - smoothingAlpha) * self.rawRoll)
}
