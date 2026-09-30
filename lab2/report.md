# UCUG1903 Assignment 2

## Melody synthesis

I selected **Song A**:

`1 1 5 5 | 6 6 5 - | 4 4 3 3 | 2 2 1 -`

The melody was synthesized at a sampling rate of 8000 Hz with a peak amplitude of 0.4. One beat lasts 0.4 s, and each dash extends the preceding note by one additional beat. Each tone uses a 10 ms attack and a 0.4 s release tail. The tails overlap subsequent notes, preserving the 6.4 s score timing while allowing the final note to decay naturally. The resulting audio contains 54400 samples and lasts 6.8 s.

![Short waveform excerpt of Song A](output/task1_melody_excerpt.png)

The output is recognizable as *Twinkle, Twinkle, Little Star*. The pitch sequence is clear, while the pure sinusoids give the melody a simple electronic tone. The attack and overlapping decay envelopes reduce clicks at note boundaries and create a smoother, more connected sound. The held notes near the middle and end last twice as long as the other notes, as specified by the score.
