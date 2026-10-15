# Signals and Systems Course Project

This repository is a cleaned and reproducible version of a two-part MATLAB course project. It demonstrates time-domain transformations, discrete Fourier analysis, ideal filtering, and stereo centre-source reduction. The second part includes both the original baselines and a new controlled benchmark with known source components.

## Repository structure

```text
Project1/
  main.m                         Time/frequency-domain exercises
  functions/                    Reusable MATLAB functions
  data/local_audio/             Local-only source audio (ignored by Git)
  results/                      Reproducible figures
Project2/
  main.m                         Real-audio comparison runner
  functions/                    Three vocal-reduction methods
  data/local_audio/             Local-only song excerpts (ignored by Git)
  experiments/
    run_vocal_benchmark.m        Synthetic ground-truth experiment
    results/                     CSV metrics and benchmark figure
report/
  course_project_report.tex      Anonymized LaTeX report
  course_project_report.pdf      Compiled report
private/                         Course handout and identified legacy report
archive/                         Original submissions and superseded outputs
```

## Methods

- **Project 1:** time reversal and scaling, FFT spectrum comparison, magnitude-only and phase-only reconstruction, and an ideal low-pass filter.
- **Basic vocal reduction:** subtracts the right channel from the left channel (`L - R`).
- **Legacy bass rescue:** adds a small low-frequency centre component to the side signal. It can restore bass, but may also restore low vocal fundamentals.
- **Adaptive cancellation:** estimates a small inter-channel delay and gain mismatch, aligns the channels, and blends compensated subtraction into a smoothly tapered speech band.

The methods reduce any coherent centre-panned material, not only vocals. They are intentionally presented as classical signal-processing baselines rather than modern source-separation systems.

## Reproducing the results

MATLAB R2024b or newer is recommended. No Signal Processing Toolbox is required.

1. Put the course-provided `audio1.wav` in `Project1/data/local_audio/`.
2. Optionally put legally usable stereo WAV files in `Project2/data/local_audio/`.
3. Run `Project1/main.m`.
4. Run `Project2/experiments/run_vocal_benchmark.m` for the objective benchmark.
5. Run `Project2/main.m` to generate listening examples for local audio files.

Audio files are intentionally excluded from version control. The controlled benchmark generates its own test signal, so the key experiment remains reproducible without copyrighted music.

## Publication and academic-use note

This repository is suitable for a portfolio after the cleanup in this version, provided that copyrighted songs, student identifiers, the original assignment PDF, and submission archives remain excluded. The report is anonymized. If published, describe it as a course project and keep the limitations section intact.

The code is shared for learning and reproducibility. Do not submit it as another student's coursework.
