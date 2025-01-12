# Project Description

## Features

### Settings

The settings feature allows user to customize different aspect of the application

### Timer

The timer functionality allows user to start a work or rest session, and to know when the session is complete,
or how much time there is left.

## Glossary

### Domain Terms

- **Timer**: A countdown mechanism that tracks elapsed time for work and rest periods
- **Work**: A focused work session with a specific duration
- **Rest**: A break period between work sessions
- **Duration**: The length of time for work or rest periods
- **Cycle**: A complete sequence of one work period followed by one rest period

## Naming Conventions

### General Guidelines
- Use consistent terminology from the glossary
- Prefer domain-specific names to technical implementation names
- Use clear, descriptive names that reflect the purpose of the entity

### Specific Patterns
- Timer-related entities should use "Timer" prefix (e.g., TimerState, TimerSettings)
- Settings-related entities should use "Settings" prefix (e.g., SettingsRepository)
- Duration-related values should use "Duration" suffix (e.g., workDuration, restDuration)

## Domain Concepts

### Work-Rest Cycle
The fundamental pattern of alternating between focused work and rest periods. The durations are configurable through settings.

### Timer States
The timer can be in one of several states:
- Running (actively counting down)
- Paused (stopped but retaining current time)
- Reset (ready to start a new period)
