# AirWaveLab

MATLAB framework for an end-to-end audio communication demo.

## Week 1

Requires base MATLAB only.

```matlab
convert_audio_assets
run_tests
run_week1_demo
```

Place a supported audio file in `assets/audio`, then run `convert_audio_assets`.
The converter preserves the source and does not overwrite existing WAV files.
`reference.wav` is preferred; otherwise the demo uses the first WAV alphabetically.

## Week 2: sound model and PCM

Lecture 2 concepts are integrated into the first PRD communication stage:

- fundamental-frequency estimation from an 80 ms voiced frame;
- harmonic synthesis and Fourier-coefficient analysis;
- ADSR envelope generation and waveform multiplication;
- configurable sample-rate conversion with anti-alias filtering;
- 4/8/12/16-bit PCM encoding and decoding;
- measured bitrate, MSE, reconstruction SNR, and pitch deviation.

Run the complete experiment with base MATLAB:

```matlab
run_tests
run_week2_demo
```

The demo writes listenable audio, CSV measurements, and two summary figures to
`results/week2`. Generated results and converted audio stay out of version control.

The Week 2 flow is:

```text
speech -> 16 kHz sampling -> PCM quantization -> decoded audio
   |                                  |
   +-> voiced frame -> f0/harmonics <-+-> quality and bitrate metrics
```
