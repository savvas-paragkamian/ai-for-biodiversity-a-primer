"""Plain-text helpers shared by the checking scripts.

- chapter_text(): a chapter's prose, with code listings, tables and citation
  commands removed (needs pandoc).
- literature_texts(): the text of every PDF and EPUB in ../literature, cached in
  scripts/.cache/literature/ (needs pdftotext and pandoc).
"""
import glob
import hashlib
import os
import re
import subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, ".."))
CHAPTERS = os.path.join(ROOT, "book", "chapters")
LITERATURE = os.path.normpath(os.path.join(ROOT, "..", "literature"))
CACHE = os.path.join(HERE, ".cache")


def chapter_files():
    return sorted(glob.glob(os.path.join(CHAPTERS, "*.tex")))


def chapter_text(path):
    s = open(path, encoding="utf-8").read()
    s = re.sub(r"\\begin\{lstlisting\}.*?\\end\{lstlisting\}", "", s, flags=re.S)
    s = re.sub(r"\\begin\{table\}.*?\\end\{table\}", "", s, flags=re.S)
    s = re.sub(r"\\(text|paren)?cite\{[^}]*\}", "", s)
    s = re.sub(r"\\[Cc]ref\{[^}]*\}", "X", s)
    s = re.sub(r"\\(term|code)\{([^}]*)\}", r"\2", s)
    r = subprocess.run(["pandoc", "-f", "latex", "-t", "plain", "--wrap=none"],
                       input=s, capture_output=True, text=True)
    return r.stdout


def literature_texts():
    """Yield (source name, text) for every PDF and EPUB in the literature folder."""
    out_dir = os.path.join(CACHE, "literature")
    os.makedirs(out_dir, exist_ok=True)
    for path in sorted(glob.glob(os.path.join(LITERATURE, "*"))):
        ext = os.path.splitext(path)[1].lower()
        if ext not in (".pdf", ".epub"):
            continue
        stat = os.stat(path)
        tag = hashlib.md5(f"{path}{stat.st_size}{stat.st_mtime}".encode()).hexdigest()[:12]
        txt = os.path.join(out_dir, tag + ".txt")
        if not os.path.exists(txt):
            if ext == ".pdf":
                subprocess.run(["pdftotext", path, txt], capture_output=True)
            else:
                subprocess.run(["pandoc", "-t", "plain", "--wrap=none", path, "-o", txt],
                               capture_output=True)
        if os.path.exists(txt):
            yield os.path.basename(path), open(txt, errors="ignore").read()
