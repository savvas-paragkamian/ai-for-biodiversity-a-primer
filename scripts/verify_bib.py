#!/usr/bin/env python3
"""Verify every DOI and arXiv identifier in the bibliography.

Each DOI is looked up in Crossref (or DataCite when Crossref has no record)
and each arXiv ID in the arXiv API. The title returned is compared with the title in the .bib entry; so are the first
author's surname and the year, when the entry has them. Entries with neither
identifier are listed for checking by hand.

Usage:
    python3 scripts/verify_bib.py [book/references.bib]

Exit status is 1 if any identifier fails to resolve, returns a different
title, first author or year, or cannot be reached.

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
import unicodedata
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET

HERE = os.path.dirname(os.path.abspath(__file__))
DEFAULT_BIB = os.path.join(HERE, "..", "book", "references.bib")
UA = {"User-Agent": "primer-bib-verify/1.1"}
ATOM = {"a": "http://www.w3.org/2005/Atom"}
MIN_SIMILARITY = 0.85


def parse_fields(body):
    """Return {name: value} for `name = {value}` fields, braces balanced,
    values possibly spanning lines."""
    fields, i = {}, 0
    for m in re.finditer(r"(\w+)\s*=\s*\{", body):
        if m.start() < i:
            continue
        depth, j = 1, m.end()
        while j < len(body) and depth:
            depth += {"{": 1, "}": -1}.get(body[j], 0)
            j += 1
        fields[m.group(1).lower()] = " ".join(body[m.end():j - 1].split())
        i = j
    return fields


def entries(text):
    """Yield (key, fields) for each entry."""
    for m in re.finditer(r"@(\w+)\{([^,]+),(.*?)\n\}", text, re.S):
        yield m.group(2).strip(), parse_fields(m.group(3))


def norm(s):
    s = re.sub(r"\\[a-zA-Z]+|[{}\\'\"`^~]", "", s)
    s = unicodedata.normalize("NFKD", s).encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]+", " ", s.lower()).strip()


def bib_surname(author_field):
    """Surname of the first author in a BibTeX author field, normalised."""
    first = re.split(r"\s+and\s+", author_field.strip(), maxsplit=1)[0]
    if "," in first:
        sur = first.split(",", 1)[0]
    else:
        sur = first.split()[-1] if first.split() else ""
    return norm(sur)


def surname_matches(bib_sur, got_name):
    got = norm(got_name)
    return bool(bib_sur) and bool(got) and (bib_sur == got or bib_sur in got
                                            or got in bib_sur)


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


def datacite_record(doi):
    """DataCite fallback for DOIs Crossref does not hold (GBIF, Zenodo)."""
    raw = fetch("https://api.datacite.org/dois/" + urllib.parse.quote(doi))
    if raw is None:
        return None
    a = json.loads(raw)["data"]["attributes"]
    title = (a.get("titles") or [{}])[0].get("title", "")
    creators = a.get("creators") or []
    family = None
    if creators:
        family = creators[0].get("familyName") or creators[0].get("name")
    years = {int(a["publicationYear"])} if a.get("publicationYear") else set()
    return title, family, years


def crossref_record(doi):
    """(title, first author's family name or None, set of years)."""
    raw = fetch("https://api.crossref.org/works/" + urllib.parse.quote(doi))
    if raw is None:
        return datacite_record(doi)
    m = json.loads(raw)["message"]
    # Grant DOIs (e.g. CORDIS, 10.3030/...) keep their title under "project".
    titles = m.get("title") or [t["title"] for p in m.get("project", [])
                                for t in p.get("project-title", [])]
    authors = m.get("author") or []
    first = next((a for a in authors if a.get("sequence") == "first"),
                 authors[0] if authors else None)
    family = None
    if first:
        family = first.get("family") or first.get("name")
    years = set()
    for k in ("issued", "published-print", "published-online", "published",
              "created", "approved"):
        parts = (m.get(k) or {}).get("date-parts") or []
        for p in parts:
            if p and p[0]:
                years.add(int(p[0]))
    return (titles or [""])[0], family, years


def arxiv_records(ids):
    """All arXiv IDs in one request. Many single requests get throttled.
    Returns {id: (title, first author name, set of years)}."""
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
    recs = {}
    for e in ET.fromstring(r.stdout).findall("a:entry", ATOM):
        aid = re.sub(r"v\d+$", "", e.find("a:id", ATOM).text.rsplit("/abs/", 1)[-1])
        t = e.find("a:title", ATOM)
        if t is None or not t.text:
            continue
        au = e.find("a:author/a:name", ATOM)
        years = set()
        for k in ("published", "updated"):
            d = e.find(f"a:{k}", ATOM)
            if d is not None and d.text:
                years.add(int(d.text[:4]))
        if years:  # any year between the first and the latest version
            years = set(range(min(years), max(years) + 1))
        recs[aid] = (" ".join(t.text.split()),
                     au.text if au is not None else None, years)
    return recs


def verify(path):
    ents = list(entries(open(path, encoding="utf-8").read()))
    is_arxiv = lambda f: ("doi" not in f and "eprint" in f
                          and f.get("archiveprefix", "").lower() == "arxiv")
    ax = arxiv_records([f["eprint"] for _, f in ents if is_arxiv(f)]) \
        if any(is_arxiv(f) for _, f in ents) else {}

    fails, n_doi, n_ax, by_hand = [], 0, 0, []
    for key, f in ents:
        if "doi" in f:
            kind, ident = "DOI", f["doi"]
            n_doi += 1
            try:
                got = crossref_record(ident)
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
        got_title, got_author, got_years = got
        sim = difflib.SequenceMatcher(None, norm(f.get("title", "")),
                                      norm(got_title)).ratio()
        problems = []
        if sim < MIN_SIMILARITY:
            problems.append(f"title mismatch ({sim:.2f})\n"
                            f"   bib: {f.get('title', '')}\n   got: {got_title}")
            print(f"TITLE MISMATCH {kind:5} {key}")
        if f.get("author") and got_author:
            sur = bib_surname(f["author"])
            if not surname_matches(sur, got_author):
                problems.append(f"first author mismatch\n"
                                f"   bib: {sur}\n   got: {got_author}")
                print(f"AUTHOR MISMATCH {kind:4} {key}")
        if f.get("year") and got_years:
            ym = re.search(r"\d{4}", f["year"])
            if ym and int(ym.group()) not in got_years:
                problems.append(f"year mismatch\n   bib: {ym.group()}\n"
                                f"   got: {sorted(got_years)}")
                print(f"YEAR MISMATCH  {kind:5} {key}")
        if problems:
            fails.extend(f"{key}: {p}" for p in problems)
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

@article{good_author_year,
  author = {Brixi, Garyk and Durrant, Matthew G. and Ku, Jerome},
  title  = {Genome modelling and design across all domains of life with {Evo 2}},
  year   = {2026},
  doi    = {10.1038/s41586-026-10176-5},
}

@article{fake_doi,
  title = {Nothing},
  doi   = {10.1038/s41586-099-99999-9},
}

@article{wrong_title,
  title = {Genome modelling of penguins on Mars},
  doi   = {10.1038/s41586-026-10176-5},
}

@article{wrong_author,
  author = {Penguin, Pingu and Durrant, Matthew G.},
  title  = {Genome modelling and design across all domains of life with {Evo 2}},
  doi    = {10.1038/s41586-026-10176-5},
}

@article{wrong_year,
  title  = {Genome modelling and design across all domains of life with {Evo 2}},
  year   = {1999},
  doi    = {10.1038/s41586-026-10176-5},
}

@misc{good_grant,
  title = {Agentic {GenAI} Open Research Assistant},
  doi   = {10.3030/101292566},
}

@techreport{good_datacite,
  author = {Chapman, Arthur D.},
  title  = {Current best practices for generalizing sensitive species occurrence data},
  year   = {2020},
  doi    = {10.15468/doc-5jp4-5g10},
}

@article{good_arxiv,
  author        = {Coppola, Greg},
  title         = {Transformers are {B}ayesian Networks},
  year          = {2026},
  eprint        = {2603.17063},
  archivePrefix = {arXiv},
}

@article{wrong_arxiv_author,
  author        = {Penguin, Pingu},
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
    """Six planted errors must be reported and five good entries must pass."""
    with tempfile.NamedTemporaryFile("w", suffix=".bib", delete=False) as t:
        t.write(SELF_TEST_BIB)
    import contextlib, io
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        status = verify(t.name)
    os.unlink(t.name)
    out = buf.getvalue()
    expected_fail = ["fake_doi", "wrong_title", "wrong_author", "wrong_year",
                     "wrong_arxiv_author", "fake_arxiv"]
    expected_ok = ["good_doi", "good_author_year", "good_grant", "good_datacite", "good_arxiv"]
    ok = (status == 1
          and all(f"FAIL {k}" in out for k in expected_fail)
          and all(re.search(rf"^ok .* {k}\b", out, re.M) for k in expected_ok)
          and not any(re.search(rf"^ok .* {k}\b", out, re.M) for k in expected_fail))
    print(out)
    print("SELF-TEST", "PASSED" if ok else "FAILED")
    return 0 if ok else 1


if __name__ == "__main__":
    if sys.argv[1:] == ["--self-test"]:
        sys.exit(self_test())
    sys.exit(verify(sys.argv[1] if len(sys.argv) > 1 else DEFAULT_BIB))
