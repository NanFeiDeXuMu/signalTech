# Decision Log

| ID | Date | Decision | Reason |
|---|---|---|---|
| D001 | 2026-08-28 | Use MATLAB as the primary stack. | Aligns with the course and supports signal/communication validation. |
| D002 | 2026-08-28 | Use speech as the end-to-end payload. | Results are audible, visual, and measurable. |
| D003 | 2026-08-28 | Complete the QPSK/AWGN MVP before OFDM or multi-user work. | Controls delivery risk. |
| D004 | 2026-08-28 | Treat OFDM, multipath, pilots, and equalization as the portfolio release. | Adds technical depth without blocking the MVP. |
| D005 | 2026-08-28 | Describe the system as 5G-inspired, not standards-compliant. | Prevents unsupported claims. |
| D006 | 2026-08-28 | Keep SDR and multi-user scheduling optional; choose at most one. | Preserves focus and hardware independence. |
| D007 | 2026-08-28 | Keep the core implementation compatible with base MATLAB. | No additional MATLAB toolboxes are currently detected. |
| D008 | 2026-08-28 | Represent mono signals as `samples`, `sampleRate`, `time`, and `name`. | Gives every pipeline stage a stable explicit interface. |
| D009 | 2026-08-28 | Convert supported assets to same-name 24-bit WAV without deleting or overwriting sources. | Provides deterministic processing while preserving original recordings. |
| D010 | 2026-09-07 | Integrate Lecture 2 through pitch, harmonic/Fourier, and ADSR modules before channel coding. | Makes course theory measurable on the speech payload while advancing the PRD audio front end. |
| D011 | 2026-09-07 | Use a transparent base-MATLAB windowed-sinc FIR plus linear interpolation for sample-rate conversion. | Reduces downsampling aliasing without adding a Signal Processing Toolbox dependency. |
| D012 | 2026-09-07 | Serialize PCM as MSB-first unsigned-offset codes and test decode/re-encode bit identity. | Keeps quantization and bitstream behavior explicit, deterministic, and toolbox-independent. |
| D013 | 2026-09-07 | Treat finite harmonic projection as an analysis/reconstruction experiment, not as the final source codec. | It demonstrates Fourier-series learning without prematurely changing the PRD compression scope. |
| D014 | 2026-09-29 | Keep Assignment 3 self-contained under `lab3`, with five-harmonic Song A synthesis, per-note envelopes and a single entry point. | Delivers the course tasks without changing the AirWaveLab communication MVP or depending on other lab folders. |
| D015 | 2026-09-29 | Implement STFT with explicit symmetric Hamming windows and FFT; report one-sided peak amplitude, not PSD. | `spectrogram` is not installed despite a positive license probe. An explicit DFT provides an independent numerical reference; toolbox comparison remains optional. |

Add a new row for material decisions; do not rewrite past entries.
