# AirWaveLab PRD

## Goal

Build a reproducible MATLAB demo that transmits speech through a simplified digital wireless link and exposes the trade-offs among quality, bitrate, reliability, and latency.

## Core Flow

`audio -> sampling/quantization -> source coding -> framing/CRC -> channel coding -> QPSK/QAM -> OFDM -> channel -> synchronization/equalization -> decoding -> recovered audio`

## Scope

### MVP

- Audio import, playback, waveform, and spectrum.
- PCM quantization with configurable sample rate and bit depth.
- Framing, CRC, Hamming coding, and QPSK.
- AWGN channel with configurable SNR.
- Receiver reconstruction, BER curve, constellation, and audio comparison.

### v1 Portfolio Release

- Huffman or differential-Huffman compression.
- 16-QAM and OFDM with cyclic prefix and pilots.
- Multipath channel, channel estimation, and equalization.
- One-command demo and compact App Designer UI.

### Stretch: Choose One

- Multi-user OFDMA with Round Robin, Max-SNR, and Proportional Fair scheduling.
- Adaptive modulation and coding.
- Lab-authorized PlutoSDR transmission.

## Non-Goals

- Full or standards-compliant 5G NR implementation.
- Full TCP/IP stack or production audio codec.
- Hardware dependency for the core demo.

## Success Metrics

- Exact bit/audio round trip when channel impairments are disabled.
- Reproducible BER-versus-Eb/N0 results with fixed random seeds.
- Measured BER, compression ratio, throughput, latency, and reconstruction SNR/MSE.
- Demo clearly shows at least one engineering trade-off.

## Deliverables

- MATLAB source and tests.
- Interactive or one-command demo.
- Architecture diagram, README, result plots, and 90-second demo video.
- Course presentation and report derived from measured results.

