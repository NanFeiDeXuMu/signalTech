"""Build the Lab 3 PDF from measured MATLAB CSVs and exported figures.
Python is used only for report layout; all signal processing is MATLAB.
Requires: reportlab, pillow. Run after run_lab3 and run_lab3_tests.
"""
from pathlib import Path
import csv
import json
import math
from xml.sax.saxutils import escape
from PIL import Image as PILImage
from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image, PageBreak

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "output"
PDFDIR = OUT / "pdf"
PDFDIR.mkdir(parents=True, exist_ok=True)
def rows(name):
    with (OUT / name).open(encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))
metrics = rows("audio_metrics.csv")
peaks = rows("harmonic_peaks.csv")
experiments = rows("stft_experiments.csv")
tests = rows("test_results.csv")
listening = json.loads((ROOT/"listening_note.json").read_text(encoding="utf-8"))
assert all(r["Passed"] == "1" and r["Failed"] == "0" for r in tests)
INK = colors.HexColor("#172B42")
BLUE = colors.HexColor("#155E83")
MUTED = colors.HexColor("#506172")
LIGHT = colors.HexColor("#EFF5F8")
styles = {
    "title": ParagraphStyle("title",fontName="Helvetica-Bold",fontSize=25,leading=29,textColor=INK,spaceAfter=12),
    "h1": ParagraphStyle("h1",fontName="Helvetica-Bold",fontSize=18,leading=22,textColor=INK,spaceAfter=10),
    "h2": ParagraphStyle("h2",fontName="Helvetica-Bold",fontSize=11.5,leading=15,textColor=BLUE,spaceBefore=8,spaceAfter=5),
    "body": ParagraphStyle("body",fontName="Helvetica",fontSize=10.3,leading=14.2,textColor=INK,spaceAfter=8),
    "caption": ParagraphStyle("caption",fontName="Helvetica",fontSize=9,leading=12,textColor=MUTED,spaceAfter=9),
    "small": ParagraphStyle("small",fontName="Helvetica",fontSize=9,leading=12,textColor=INK,spaceAfter=6),
    "cell": ParagraphStyle("cell",fontName="Helvetica",fontSize=9,leading=12,textColor=INK),
    "headcell": ParagraphStyle("headcell",fontName="Helvetica-Bold",fontSize=9,leading=12,textColor=colors.white),
    "code": ParagraphStyle("code",fontName="Courier",fontSize=9,leading=12,backColor=LIGHT,borderPadding=7,spaceAfter=12),
}
story=[]
markdown=[]
def para(text,style="body"):
    story.append(Paragraph(text,styles[style]))
    markdown.append(text.replace("<b>","").replace("</b>","").replace("<br/>","\n")+"\n")
def title(text):
    para(text,"h1")
def section(text):
    para(text,"h2")
def page():
    story.append(PageBreak()); markdown.append("\n---\n")
def table(headers,data,widths):
    converted=[[Paragraph(escape(str(c)),styles["headcell"]) for c in headers]]
    converted += [[Paragraph(escape(str(c)),styles["cell"]) for c in row] for row in data]
    tab=Table(converted,colWidths=widths,hAlign="LEFT",repeatRows=1)
    tab.setStyle(TableStyle([
        ("BACKGROUND",(0,0),(-1,0),BLUE),("VALIGN",(0,0),(-1,-1),"TOP"),
        ("ROWBACKGROUNDS",(0,1),(-1,-1),[colors.white,LIGHT]),
        ("LEFTPADDING",(0,0),(-1,-1),7),("RIGHTPADDING",(0,0),(-1,-1),7),
        ("TOPPADDING",(0,0),(-1,-1),6),("BOTTOMPADDING",(0,0),(-1,-1),6),
        ("LINEBELOW",(0,0),(-1,0),.5,BLUE),
    ]))
    story.extend([tab,Spacer(1,8)])
    markdown.append("| "+" | ".join(headers)+" |\n")
    markdown.append("|"+"|".join(["---"]*len(headers))+"|\n")
    for row in data:
        markdown.append("| "+" | ".join(str(c) for c in row)+" |\n")
def fig(name,caption,max_height=370):
    path=OUT/"figures"/name
    with PILImage.open(path) as im: w,h=im.size
    scale=min(499/w,max_height/h)
    story.append(Image(str(path),width=w*scale,height=h*scale))
    para(caption,"caption")
    markdown.append(f"![{caption}](../figures/{name})\n")
def footer(canvas,doc):
    canvas.saveState()
    canvas.setStrokeColor(colors.HexColor("#CFDCE4"))
    canvas.line(48,38,A4[0]-48,38)
    canvas.setFont("Helvetica",8)
    canvas.setFillColor(MUTED)
    canvas.drawString(48,25,"UCUG1903  /  Assignment 3  /  Song A")
    canvas.drawRightString(A4[0]-48,25,f"{doc.page}")
    canvas.restoreState()

para("UCUG1903  |  SIGNALS AND INFORMATION TECHNOLOGY","caption")
para("Harmonics, envelopes &amp;<br/>time-frequency analysis","title")
para("Assignment 3 - Fall 2026-27","h2")
para("Song A from Assignment 2 (<i>Twinkle, Twinkle, Little Star</i>) was synthesized in two versions: five weighted harmonics alone, and the same harmonics multiplied by a separate hit envelope for every note. Both versions preserve the same score and timing.")
para("1 1 5 5 | 6 6 5 - | 4 4 3 3 | 2 2 1 -","code")
table(["Setting","Value"],[
    ["Sampling / export","8000 Hz, mono, 24-bit PCM WAV"],
    ["Score / timing","14 notes, 16 beats; 0.4 s/beat; 51200 samples, 6.4 s"],
    ["Fundamental amplitude","0.35 for both versions; no separate normalization"],
    ["Harmonic weights","1.00, 0.45, 0.25, 0.12, 0.06 (orders 1-5)"],
    ["Envelope","5% linear attack; 95% squared decay; no overlapping note tails"],
    ["Environment","MATLAB R2026a Update 3, base MATLAB; seed 1903"],
],[150,349])
section("Synthesis method")
para("For each note, x[n] = 0.35 sum(k=1..5) a[k] sin(2 pi k f0 n/fs). The scale frequencies are 261.63, 293.66, 329.63, 349.23, 392, 440 and 494 Hz. The highest possible fifth harmonic is 2470 Hz, below the 4000 Hz Nyquist limit.")
para("A one-beat note has 3200 samples: 160 attack samples and 3040 decay samples. The attack is linspace(0,1,160); the decay is linspace(1,0,3040)<super>2</super>. The envelope multiplies each note before concatenation. Two-beat notes use twice these lengths.")
section("Measured audio results")
table(["Version","Peak","RMS","Max boundary jump"],[
    ["Harmonics only",f'{float(metrics[0]["Peak"]):.6f}',f'{float(metrics[0]["RMS"]):.6f}',f'{float(metrics[0]["MaxBoundaryJump"]):.6f}'],
    ["With envelope",f'{float(metrics[1]["Peak"]):.6f}',f'{float(metrics[1]["RMS"]):.6f}',f'{float(metrics[1]["MaxBoundaryJump"]):.6f}']
],[175,85,85,154])
rmsdb=20*math.log10(float(metrics[1]["RMS"])/float(metrics[0]["RMS"]))
para(f"Neither version clips. The envelope lowers RMS level by {abs(rmsdb):.2f} dB while leaving peak level almost unchanged. The maximum jump across adjacent note boundaries falls from {float(metrics[0]['MaxBoundaryJump']):.6f} to zero. WAV readback differs from synthesis by at most {max(float(r['MaxWavError']) for r in metrics):.3g}, within one 24-bit PCM step.","small")
para("Source: Assignment3.pdf, pp. 1-4; the provided MATLAB templates; Song A and scale mapping from Assignment 2. All figures and measurements below were generated by the submitted MATLAB code.","caption")

page()
title("1 / Harmonics and the hit envelope")
fig("task1_waveforms.png","Figure 1. Equal axes compare the full melody, the first 1.2 s, and a 20 ms excerpt. Left: harmonics only. Right: the same harmonics with a per-note envelope.",max_height=365)
fig("task1_envelope.png","Figure 2. The hit envelope for one 0.4 s note. It rises rapidly, then follows a squared decay to zero.",max_height=142)
section("Waveform and listening observations")
para("The unshaped waveform maintains an approximately constant amplitude within each note. The shaped waveform has distinct attacks and decaying tails. In the short excerpt, the cycle pattern is retained while its amplitude changes over time; the harmonic frequencies have not been retuned.")
para(f"<b>Listening observation:</b> {escape(listening['english'])}","body")
para("This observation is consistent with the measured smooth note endings and separate attacks. The lower RMS level also changes perceived loudness, so this listening comparison does not isolate timbre from loudness. The model is a simplified struck-string envelope, not a physical piano simulation.","small")

page()
title("2 / Whole-melody and individual-note FFT")
fig("fft_full.png","Figure 3. Single-sided amplitude spectra of the full 6.4 s WAVs. The bin spacing is 8000/51200 = 0.15625 Hz.",max_height=195)
fig("fft_notes.png","Figure 4. Complete 0.4 s notes: Do (0.0-0.4 s), Sol (0.8-1.2 s), and La (1.6-2.0 s). Each has 3200 samples and a 2.5 Hz FFT grid.",max_height=310)
para("The full-melody spectrum mixes all notes and their harmonics, so its peaks cannot be assigned to one fundamental. Individual-note spectra reveal the harmonic series more clearly. The measured fundamental bins are 262.5, 392.5 and 440.0 Hz, matching the expected 261.63, 392 and 440 Hz within half a bin.")
para("For unshaped La, the five measured peaks are 0.3500, 0.1575, 0.0875, 0.0420 and 0.0210, matching 0.35 times the specified weights. Do and Sol are not exactly bin-centered, so leakage reduces their peak-bin values. The envelope reduces peak amplitudes and changes the spectral skirts while retaining peaks around the same harmonic frequencies.","small")
para("Normalization: |FFT(x)|/N; double positive-frequency bins except DC and, for even N, Nyquist. Odd-length spectra also double their final positive-frequency bin. No extra analysis window is used for these FFT figures.","caption")

page()
title("3 / The effect of FFT segment length")
fig("fft_lengths.png","Figure 5. The first Do note is cropped from the same starting sample to 0.05, 0.20 or 0.40 s. Both signal versions use the same segment lengths.",max_height=370)
table(["Duration","Samples","FFT grid fs/N"],[
    ["0.05 s","400","20 Hz"],["0.20 s","1600","5 Hz"],["0.40 s","3200","2.5 Hz"]
],[160,160,179])
para("Longer segments produce a finer frequency grid and narrower features associated with the finite observation interval. The short 0.05 s segment gives broad, coarsely sampled peaks; 0.40 s makes the five harmonics easier to identify. A finite rectangular segment can leak energy into neighboring bins when it contains a non-integer number of cycles.")
para("The two columns require care: extending the unshaped segment mainly changes observation length and truncation, whereas extending the shaped segment also includes more of the decaying tail. Its average amplitude therefore changes. A smaller peak in the right column is not evidence that the note frequency has changed.")
section("Indexing")
para("The first note begins at MATLAB sample 1. A duration D uses round(D*fs) samples. Other notes are selected from notes.csv using their stored inclusive StartSample and EndSample, preventing accidental mixing across note boundaries.","small")

page()
title("4 / Spectrum over time")
fig("spectrogram_compare.png","Figure 6. Baseline STFT: 2048-sample symmetric Hamming window, zero overlap and 4096 FFT points. Both panels use -80 to 0 dB relative to amplitude 1.",max_height=285)
fig("waterfall_compare.png","Figure 7. The same baseline STFT magnitudes shown as waterfalls. Frequency rows are thinned only for rendering; the computed STFT is unchanged.",max_height=205)
para("Both versions follow the same fundamental and harmonic tracks. The enveloped melody shows changes in brightness within notes as energy decays, while the unshaped version has more sustained energy. The baseline has only 25 time frames, so a 0.4 s note is represented by few columns and rapid attacks are poorly localized.")
para("Because spectrogram was unavailable in this installation, stft_base implements framing, a Hamming window and fft directly. Only complete frames are retained; these experiments discard no tail samples. Frame times are the mean of the first and last sample times. The raw complex spectrum is divided by the window sum and converted to one-sided peak amplitude, then displayed as 20 log10(amplitude). This is an amplitude spectrogram, not power spectral density.","small")

page()
title("5 / Window length: time-frequency trade-off")
fig("sweep_window.png","Figure 8. Enveloped melody; 50% overlap and 4096 FFT points. Only window length changes (256, 1024 and 2048 samples).",max_height=360)
table(["Window","Duration","Hop","Frames"],[
    [r["WindowSamples"],f'{1000*float(r["WindowSeconds"]):.0f} ms',f'{1000*float(r["HopSeconds"]):.0f} ms',r["Frames"]]
    for r in experiments if r["Experiment"]=="Window length"
],[125,125,125,124])
para("The 256-sample window gives sharper timing of attacks and transitions, but each harmonic occupies a wider frequency band. The 2048-sample window makes the bands narrower while averaging over 256 ms, smearing rapid amplitude changes and note transitions. The 1024-sample case gives an intermediate result.")
para("All three cases have the same 1.953125 Hz FFT grid. Their differing frequency discrimination comes from the amount of observed data and the window shape, not the plotted bin spacing alone. Keeping a 50% overlap ratio also changes the hop as window length changes, so both window duration and time sampling should be reported.")

page()
title("6 / Overlap: denser time sampling")
fig("sweep_overlap.png","Figure 9. Enveloped melody; window length 1024 and FFT length 4096. Overlap is 0, 512 or 768 samples.",max_height=370)
table(["Overlap","Hop","Frames","FFT grid"],[
    [r["OverlapSamples"],f'{1000*float(r["HopSeconds"]):.0f} ms',r["Frames"],f'{float(r["BinHz"]):.6f} Hz']
    for r in experiments if r["Experiment"]=="Overlap"
],[125,125,125,124])
para("Increasing overlap samples the evolving spectrum more frequently. The time display becomes less blocky and the rise and decay of each note can be followed more smoothly: the frame count increases from 50 to 99 to 197 over the same 6.4 s melody.")
para("The window duration remains 128 ms in every case. Extra overlap does not shorten that observation interval or intrinsically improve frequency resolution. It adds correlated frames and more FFT computations. A 50% overlap is a useful middle setting for illustrating this melody.")

page()
title("7 / FFT points: interpolation, not extra data")
fig("sweep_nfft.png","Figure 10. Fixed 1024-sample window and 512-sample overlap. Left: STFT. Right: the same first frame around Do, revealing the denser FFT sampling.",max_height=360)
table(["FFT points","FFT grid","Window / hop","Frames"],[
    [r["FFTPoints"],f'{float(r["BinHz"]):.5f} Hz',"128 / 64 ms",r["Frames"]]
    for r in experiments if r["Experiment"]=="FFT points"
],[125,125,145,104])
para("Increasing FFT length from 1024 to 4096 inserts zeros after the same windowed frame. The frequency grid changes from 7.8125 to 1.953125 Hz, and the peak curve is sampled more densely. The underlying peak width and the ability to separate nearby tones are still governed by the fixed window. All cases retain 99 frames.")
section("Reproduction")
para("From the extracted lab3 folder, run:<br/><font face='Courier'>run_lab3</font><br/>Audio, figures and CSVs are written to output/. The report can be rebuilt with build_report.py after installing reportlab and pillow. These Python packages are needed only for document layout.","small")

doc=SimpleDocTemplate(str(PDFDIR/"Lab3_Report.pdf"),pagesize=A4,
    leftMargin=48,rightMargin=48,topMargin=43,bottomMargin=51,
    title="UCUG1903 Assignment 3 - Harmonics, Envelopes and Time-Frequency Analysis",
    author="",
)
doc.build(story,onFirstPage=footer,onLaterPages=footer)
(PDFDIR/"Lab3_Report.md").write_text("\n".join(markdown),encoding="utf-8")
print(PDFDIR/"Lab3_Report.pdf")

