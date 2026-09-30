"""Package only standalone Lab 3 source, measured outputs and report."""
from pathlib import Path
import hashlib
import json
import zipfile

ROOT=Path(__file__).resolve().parent
OUT=ROOT/"output"
destination=ROOT/"submission"/"Lab3_Submission.zip"
destination.parent.mkdir(parents=True,exist_ok=True)
members={}
for pattern in ["*.m","common/*.m","task1/*.m","task2/*.m","tests/*.m"]:
    for p in ROOT.glob(pattern):
        members[p.relative_to(ROOT).as_posix()]=p
for name in ["README.md","build_report.py","package_lab3.py","listening_note.json"]:
    members[name]=ROOT/name
for pattern in ["*.wav","*.csv","figures/*.png"]:
    for p in OUT.glob(pattern):
        members["output/"+p.relative_to(OUT).as_posix()]=p
if (OUT/"verification.json").exists():
    members["output/verification.json"]=OUT/"verification.json"
members["Lab3_Report.pdf"]=OUT/"pdf"/"Lab3_Report.pdf"
members["output/pdf/Lab3_Report.md"]=OUT/"pdf"/"Lab3_Report.md"
required=["run_lab3.m","run_lab3_tests.m","Lab3_Report.pdf",
          "output/task2_harmonic_melody.wav","output/task2_timbre_melody.wav"]
assert all(name in members and members[name].is_file() for name in required)
assert len([k for k in members if k.endswith(".wav")])==2
assert len([k for k in members if k.endswith(".png")])==10
manifest={name:hashlib.sha256(path.read_bytes()).hexdigest() for name,path in sorted(members.items())}
with zipfile.ZipFile(destination,"w",compression=zipfile.ZIP_DEFLATED) as z:
    for name,path in sorted(members.items()):
        z.write(path,"Lab3_Submission/"+name)
    z.writestr("Lab3_Submission/manifest_sha256.json",json.dumps(manifest,indent=2))
with zipfile.ZipFile(destination) as z:
    assert z.testzip() is None
print(f"{destination} ({destination.stat().st_size} bytes; {len(members)+1} files)")

