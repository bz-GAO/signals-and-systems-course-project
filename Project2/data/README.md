# Local stereo inputs

Place stereo WAV excerpts in:

```text
Project2/data/local_audio/
```

Run `Project2/main.m`. Each input creates a matching folder under `Project2/outputs/` containing:

- `basic_L_minus_R.wav`
- `legacy_bass_rescue.wav`
- `adaptive_cancellation.wav`
- `waveform_comparison.png`
- `diagnostic_metrics.txt`

Source audio and generated WAV files are ignored by Git. The controlled synthetic benchmark does not need external audio.
