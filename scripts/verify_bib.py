#!/usr/bin/env python3
"""Verify every DOI and arXiv identifier in the bibliography.

Each DOI is looked up in Crossref and each arXiv ID in the arXiv API, and the
title returned is compared with the title in the .bib entry. Entries with
neither identifier are listed for checking by hand.

Usage:
    python3 scripts/verify_bib.py [book/references.bib]

Exit status is 1 if any identifier fails to resolve, returns a different title,
or cannot be reached.

Self-test (checks that the check can fail):
    python3 scripts/verify_bib.py --self-test
"""
import difflib
import json
import os
import re
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET

HERE = os.path.dirname(os.path.abspath(__file__))
DEFAULT_BIB = os.path.join(HERE, "..", "book", "references.bib")
UA = {"User-Agent": "primer-bib-verify/1.0"}
ATOM = {"a": "http://www.w3.org/2005/Atom"}
MIN_SIMILARITY = 0.85


def entries(text):
    """Yield (key, fields) for each entry. Fields are single-line `k = {v},`."""
    for m in re.finditer(r"@(\w+)\{([^,]+),(.*?)\n\}", text, re.S):
        fields = {k.lower(): v for k, v in
                  re.findall(r"(\w+)\s*=\s*\{(.*?)\},?\s*$", m.group(3), re.M)}
        yield m.group(2).strip(), fields


def norm(s):
    s = re.sub(r"\\[a-zA-Z]+|[{}\\'\"`^~]", "", s)
    return re.sub(r"[^a-z0-9]+", " ", s.lower()).strip()


def fetch(url, tries=6):
    """Return the body, or None for 400/404. Retries other failures."""
    for i in range(tries):
        try:
            req = urllib.request.Request(url, headers=UA)
            with urllib.request.urlopen(req, timeout=30) as r:
                return r.read()
        except urllib.error.HTTPError as e:
            if e.code in (400, 404):
                return None
            print(f"  retry {i + 1}: HTTP {e.code}", file=sys.stderr)
        except Exception as e:  # network errors
            print(f"  retry {i + 1}: {e}", file=sys.stderr)
        time.sleep(10 * (i + 1))
    raise RuntimeError(f"network failure: {url}")


def crossref_title(doi):
    raw = fetch("https://api.crossref.org/works/" + urllib.parse.quote(doi))
    if raw is None:
        return None
    m = json.loads(raw)["message"]
    # Grant DOIs (e.g. CORDIS, 10.3030/...) keep their title under "project".
    titles = m.get("title") or [t["title"] for p in m.get("project", [])
                                for t in p.get("project-title", [])]
    return (titles or [""])[0]


def arxiv_titles(ids):
    """All arXiv IDs in one request. Many single requests get throttled."""
    url = ("https://export.arxiv.org/api/query?max_results=500&id_list="
           + ",".join(ids))
    for i in range(6):
        r = subprocess.run(["curl", "-sf", url], capture_output=True)
        if r.returncode == 0:
            break
        print(f"  arXiv retry {i + 1}", file=sys.stderr)
        time.sleep(20 * (i + 1))
    else:
        raise RuntimeError("arXiv API unreachable")
    titles = {}
    for e in ET.fromstring(r.stdout).findall("a:entry", ATOM):
        aid = re.sub(r"v\d+$", "", e.find("a:id", ATOM).text.rsplit("/abs/", 1)[-1])
        t = e.find("a:title", ATOM)
        if t is not None and t.text:
            titles[aid] = " ".join(t.text.split())
    return titles


def verify(path):
    ents = list(entries(open(path, encoding="utf-8").read()))
    is_arxiv = lambda f: ("doi" not in f and "eprint" in f
                          and f.get("archiveprefix", "").lower() == "arxiv")
    ax = arxiv_titles([f["eprint"] for _, f in ents if is_arxiv(f)]) \
        if any(is_arxiv(f) for _, f in ents) else {}

    fails, n_doi, n_ax, by_hand = [], 0, 0, []
    for key, f in ents:
        if "doi" in f:
            kind, ident = "DOI", f["doi"]
            n_doi += 1
            try:
                got = crossref_title(ident)
            except RuntimeError as e:
                fails.append(f"{key}: {e}")
                print(f"NETWORK FAIL   {key}")
                continue
            time.sleep(0.3)
        elif is_arxiv(f):
            kind, ident = "arXiv", f["eprint"]
            n_ax += 1
            got = ax.get(ident)
        else:
            by_hand.append(key)
            continue
        if got is None:
            fails.append(f"{key}: {kind} {ident} does not resolve")
            print(f"UNRESOLVED     {kind:5} {key}")
            continue
        sim = difflib.SequenceMatcher(None, norm(f.get("title", "")), norm(got)).ratio()
        if sim < MIN_SIMILARITY:
            fails.append(f"{key}: title mismatch ({sim:.2f})\n"
                         f"   bib: {f.get('title', '')}\n   got: {got}")
            print(f"TITLE MISMATCH {kind:5} {key}")
        else:
            print(f"ok             {kind:5} {key}  (similarity {sim:.2f})")

    print(f"\n{n_doi} DOIs and {n_ax} arXiv IDs checked; {len(fails)} failures.")
    print(f"{len(by_hand)} entries have neither and must be checked by hand:")
    print("  " + ", ".join(by_hand))
    for x in fails:
        print("FAIL", x)
    return 0 if not fails else 1


SELF_TEST_BIB = r"""
@article{good_doi,
  title = {Synthesizing scientific literature with retrieval-augmented language models},
  doi   = {10.1038/s41586-025-10072-4},
}

@article{fake_doi,
  title = {Nothing},
  doi   = {10.1038/s41586-099-99999-9},
}

@article{wrong_title,
  title = {Genome modelling of penguins on Mars},
  doi   = {10.1038/s41586-026-10176-5},
}

@misc{good_grant,
  title = {Agentic {GenAI} Open Research Assistant},
  doi   = {10.3030/101292566},
}

@article{good_arxiv,
  title         = {Transformers are {B}ayesian Networks},
  eprint        = {2603.17063},
  archivePrefix = {arXiv},
}

@article{fake_arxiv,
  title         = {Nothing},
  eprint        = {2699.99999},
  archivePrefix = {arXiv},
}
"""


def self_test():
    """Three planted errors must be reported and three good entries must pass."""
    with tempfile.NamedTemporaryFile("w", suffix=".bib", delete=False) as t:
        t.write(SELF_TEST_BIB)
    import contextlib, io
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        status = verify(t.name)
    os.unlink(t.name)
    out = buf.getvalue()
    expected_fail = ["fake_doi", "wrong_title", "fake_arxiv"]
    expected_ok = ["good_doi", "good_grant", "good_arxiv"]
    ok = (status == 1
          and all(f"FAIL {k}" in out for k in expected_fail)
          and all(re.search(rf"^ok .* {k}\b", out, re.M) for k in expected_ok))
    print(out)
    print("SELF-TEST", "PASSED" if ok else "FAILED")
    return 0 if ok else 1


if __name__ == "__main__":
    if sys.argv[1:] == ["--self-test"]:
        sys.exit(self_test())
    sys.exit(verify(sys.argv[1] if len(sys.argv) > 1 else DEFAULT_BIB))
