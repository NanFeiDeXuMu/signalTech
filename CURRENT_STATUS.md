# Current Status

**Updated:** 2026-09-30  
**Phase:** M1 - Week 2 sound model and PCM complete  
**Overall:** In progress

## Done

- Confirmed MATLAB R2026a Update 3; no additional toolboxes detected.
- Added the canonical signal structure and audio I/O.
- Implemented amplitude/time scaling, shift, reversal, addition, and multiplication.
- Added signal metrics and empirical system-property checks.
- Added a deterministic Week 1 demo and automated tests.
- Added automatic supported-audio-to-WAV conversion without overwrite.
- Converted `sye.m4a` to 48 kHz stereo `sye.wav`; the demo selects it automatically.
- Verified 10/10 tests and the complete demo successfully.
- Removed disposable PDF-inspection and generated demo artifacts.
- Normalized system-analysis inputs to column vectors to prevent orientation errors.
- Integrated Lecture 2 periodicity, pitch, harmonics, Fourier coefficients, and ADSR
  into reusable base-MATLAB modules.
- Added configurable sample-rate conversion with an explicit anti-alias FIR stage.
- Added self-contained PCM bitstream encoding/decoding for 4 to 24 bits.
- Added MSE, reconstruction-SNR, bitrate, and pitch-preservation measurements.
- Added deterministic pure/rich tone examples with matched RMS and a shared ADSR
  envelope so harmonic timbre differences can be heard and measured.
- Added a one-command Week 2 demo with listenable WAVs, CSV tables, and two figures.
- Verified 18/18 automated tests, the Week 1 regression demo, and the Week 2 demo.
- On the current speech asset, measured 1.54/21.76/44.82/68.92 dB reconstruction
  SNR at 4/8/12/16 bits; maximum estimated-pitch deviation was 0.12 Hz.

## Lab 3 Coursework

- Completed both Assignment 3 tasks using Song A, five harmonics, a per-note hit
  envelope, single-sided FFT and a transparent base-MATLAB Hamming-window STFT.
- Added a standalone `lab3/run_lab3.m` entry point with two 6.4 s, 8 kHz, 24-bit
  WAVs, ten figures, note metadata and measured audio/frequency/STFT CSVs.
- Covered complete melody, Do/Sol/La notes, three segment lengths, window length,
  overlap, FFT zero-padding, 2D spectrograms and 3D waterfalls.
- Verified 12/12 Lab 3 checks and 18/18 existing project regression checks.
  The optional `spectrogram` toolbox reference is unavailable; the independent
  explicit-DFT reference passed. Quantized WAV decode/re-encode is exact.
- A fresh MATLAB process in an independent ZIP extraction passed all 12 checks;
  both regenerated WAVs and all four measurement CSVs matched byte for byte.
- Measured maximum note-boundary jump fell from 0.356265 to zero with the envelope;
  RMS fell from 0.280254 to 0.127480. User listening feedback: more natural.
- Completed and visually reviewed the eight-page English report at
  `lab3/output/pdf/Lab3_Report.pdf`; packaged 37 files in
  `lab3/submission/Lab3_Submission.zip` with a SHA-256 manifest.
- Original supplied WAVs were preserved. Generated results and archives are ignored.
- Applied report feedback: page 8 now contains only Reproduction instructions;
  validation prose and the test command were removed from that section, and the
  PDF, Markdown report source and submission ZIP were refreshed.
- Local deliverables are complete. Canvas upload has not been performed; due time
  remains 2026-09-30 at 23:59 as stated in the assignment.

## Checkpoint validation (2026-09-30)

- Re-ran the project suite (18/18) and Lab 3 suite (12/12): all passed.
- Re-ran the Week 1 and Week 2 demos successfully in MATLAB R2026a.
- Excluded Lab 1/2 generated figures, audio outputs and PDF reports from Git,
  alongside the existing Lab 3 outputs, archives and main demo results.
- CRC, channel coding and BER validation remain pending implementation.

## Next

1. Add framing and a self-contained CRC implementation.
2. Test CRC detection with deterministic bit-error injection.
3. Add Hamming channel coding, then QPSK and AWGN BER validation.

## Risks

- Scope growth before the MVP is stable.
- Only base MATLAB is currently available; later communication functions must remain self-contained.
- Treating built-in examples as the project instead of validation references.
- Short-time pitch estimation assumes a voiced, approximately periodic frame; unvoiced
  speech requires an explicit confidence/voicing decision before later automation.

## Blockers

- None.
