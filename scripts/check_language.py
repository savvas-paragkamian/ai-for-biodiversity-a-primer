#!/usr/bin/env python3
"""Check the book's prose against the house style in AGENTS.md.

Per chapter it reports:
  - words hunspell does not know, using a British English dictionary
    (downloaded once into scripts/.cache/dict/); American spellings show up here
  - banned jargon and hedging words from AGENTS.md
  - sentences over 35 words
  - average sentence length and a Flesch reading-ease score
    (60+ is plain English; below 40 is hard going)

Usage:
    python3 scripts/check_language.py
    python3 scripts/check_language.py --self-test

Names and technical terms will appear in the unknown-word list; read it for
real misspellings. Long-sentence detection is approximate: headings and list
items can run together in the plain text.
"""
import collections
import os
import re
import subprocess
import sys
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import booktext  # noqa: E402

DICT_DIR = os.path.join(booktext.CACHE, "dict")
DICT_URL = "https://raw.githubusercontent.com/LibreOffice/dictionaries/master/en/en_GB."
BANNED = [r"binding constraint", r"load-bearing", r"compositional", r"posture",
          r"leverag\w*", r"second-order effects?", r"substrate", r"defensible",
          r"it'?s worth noting", r"worth noting", r"cutting-edge", r"revolutionary"]
HEDGES = [r"very", r"really", r"just", r"quite", r"arguably", r"basically",
          r"simply", r"actually", r"clearly", r"obviously", r"of course"]
LONG = 35


def dictionary():
    os.makedirs(DICT_DIR, exist_ok=True)
    for ext in ("aff", "dic"):
        path = os.path.join(DICT_DIR, "en_GB." + ext)
        if not os.path.exists(path):
            urllib.request.urlretrieve(DICT_URL + ext, path)
    return os.path.join(DICT_DIR, "en_GB")


def unknown_words(text, dic):
    r = subprocess.run(["hunspell", "-d", dic, "-l"], input=text,
                       capture_output=True, text=True)
    return collections.Counter(r.stdout.split())


def syllables(w):
    n = len(re.findall(r"[aeiouy]+", w.lower()))
    if w.lower().endswith("e") and n > 1:
        n -= 1
    return max(1, n)


def analyse(text):
    flat = re.sub(r"\s+", " ", text)
    sents = [s for s in re.split(r"(?<=[.!?])\s+(?=[A-Z“\"(])", flat)
             if len(s.split()) > 3]
    ws = re.findall(r"[A-Za-z’']+", flat)
    if not sents or not ws:
        return None
    wps = len(ws) / len(sents)
    spw = sum(syllables(w) for w in ws) / len(ws)
    return {
        "words": len(ws),
        "wps": wps,
        "flesch": 206.835 - 1.015 * wps - 84.6 * spw,
        "long": [s for s in sents if len(s.split()) > LONG],
        "banned": re.findall(r"\b(" + "|".join(BANNED) + r")\b", flat, re.I),
        "hedges": re.findall(r"\b(" + "|".join(HEDGES) + r")\b", flat, re.I),
    }


def run():
    dic = dictionary()
    all_unknown = collections.Counter()
    print(f"{'chapter':30} {'words':>6} {'w/sent':>6} {'Flesch':>6} {'long':>4} banned / hedges")
    for path in booktext.chapter_files():
        text = booktext.chapter_text(path)
        all_unknown += unknown_words(text, dic)
        a = analyse(text)
        if a is None:
            continue
        name = os.path.basename(path)
        print(f"{name:30} {a['words']:6d} {a['wps']:6.1f} {a['flesch']:6.1f} "
              f"{len(a['long']):4d} {sorted(set(a['banned']))} / "
              f"{sorted(set(h.lower() for h in a['hedges']))}")
        for s in a["long"]:
            print(f"    long: {s[:150]}")
    print("\nWords not in the British English dictionary (most frequent first):")
    print("  " + " ".join(w for w, _ in all_unknown.most_common()))


def self_test():
    """American spelling, a banned word and a long sentence must all be caught."""
    dic = dictionary()
    text = ("We must leverage the color of the organization. " +
            " ".join(["word"] * 40) + ".")
    unknown = unknown_words(text, dic)
    a = analyse(text)
    ok = ("color" in unknown and "organization" in unknown
          and a["banned"] and a["long"])
    print("unknown:", dict(unknown), "banned:", a["banned"], "long:", len(a["long"]))
    print("SELF-TEST", "PASSED" if ok else "FAILED")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(self_test() if sys.argv[1:] == ["--self-test"] else run())
