# Signals and Systems Course Project

This folder contains the report source, MATLAB source code, figures, and generated audio files for the Signals and Systems course project.

## Task Coverage

- Project 1: all five required tasks are completed, including waveform display, time-domain transformations, Fourier spectrum comparison, magnitude/phase reconstruction, and ideal low-pass filtering.
- Project 2: Option 1, Voice Eliminator, is selected and implemented. Option 2, Speech Sampler, is not included.

## Main Deliverables

- `Course_Project_Report_Revised.md`: Markdown source of the report.
- `Course_Project_Report.pdf`: final PDF report to submit after export.
- `Project1/`: MATLAB source code and audio results for Project 1.
- `Project2/`: MATLAB source code and audio results for Project 2.
- `Figure1.jpg` to `Figure6.jpg`: figures used in the report.

## Project 1

Project 1 analyzes one audio signal in the time domain and frequency domain.

### Files

- `main.m`: main script for reading the audio signal, plotting waveforms, calculating spectra, reconstructing signals from magnitude/phase, and applying low-pass filtering.
- `audio1.wav`: source audio used as the signal \( f(t) \).
- `outputs/`: generated audio results.

### Functions

- `functions/myTimeScale.m`: implements time scaling for a discrete audio signal using linear interpolation.
- `functions/mySpectrumPlot.m`: computes FFT, shifts the spectrum with `fftshift`, builds the frequency axis, and plots the magnitude spectrum.
- `functions/myIdealLPF.m`: implements an ideal low-pass filter in the frequency domain and reconstructs the filtered signal using IFFT.

## Project 2

Project 2 implements the Voice Eliminator option.

### Files

- `main.m`: main script for running the voice eliminator and exporting original, basic, and advanced output audio.
- `rollinginthedeep.wav`: case/example song.
- `夜空はなんでも知ってるの.wav`: selected pop song for comparison.
- `rollinginthedeep/`: generated outputs for the case song.
- `夜空はなんでも知ってるの/`: generated outputs for the selected pop song.

### Functions

- `functions/myVoiceEliminator.m`: implements the voice eliminator. The basic output is `L - R`; the advanced output adds low-frequency center-channel content back to reduce bass loss.
- `functions/myIdealLPF.m`: reused low-pass filter for extracting low-frequency content from the estimated center channel.

