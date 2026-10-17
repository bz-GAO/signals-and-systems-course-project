# Signals and Systems Course Project

This two-part MATLAB course project demonstrates time-domain transformations, discrete Fourier analysis, ideal filtering, and stereo centre-source reduction. The second part compares three cancellation methods in a controlled benchmark with known source components.

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
  course_project_report.tex      LaTeX report source
  course_project_report.pdf      Compiled report
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

## Scope and academic use

The controlled benchmark is reproducible without external recordings. Listening examples require user-supplied audio; source songs are not distributed with this repository. See the report for the assumptions and limitations of centre cancellation.

This is a course project for learning and reproducibility. Cite the source when referencing it, and do not submit it as your own coursework. No open-source license is included.
