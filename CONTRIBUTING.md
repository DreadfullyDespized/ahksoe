# Contributing to ahksoe

Agents: read [AGENTS.md](AGENTS.md) first (repo scope, landmines, local proof commands). Players and setup: [README.md](README.md) (scripts, requirements, how to run).

**Repo label: TEST** — verified work merges to `master`; Dread tests `master`. Source of truth: fleet skill "Repo registry (PROD vs TEST)".
**Owner seat:** Rig (Stream Tools). **Merge:** TEST → owner merges after grader PASS and CI or local proof; agents do not merge their own PRs.
**Tracking:** GitHub issues.

## Setup and run

1. Windows with [AutoHotkey 1.1+](https://www.autohotkey.com/) (or a compiled build of the script).
2. Clone this repo; keep `AHKSOE.ahk`, `SOE-Config.ini`, and related files together.
3. Run `AHKSOE.ahk` (administrator elevation is expected). Open the GUI with **Ctrl+1**; rebind hotkeys and chat prefixes in the tabs and in `SOE-Config.ini`.
4. Connect FiveM to the SoE server before relying on chat triggers. `AHKGTAV.ahk` is reference-only for NDG.

Do not commit personal machine paths as defaults; use the GUI and `-Config.ini` beside the script. Details: [README.md](README.md).

## Tests and checks

CI runs on every pull request:

| Workflow | What it runs |
|---|---|
| `.github/workflows/no-new-comments.yml` | Checker unit tests, `no_secrets.py`, `agents_md_headings.py`, `no_new_comments.py` on the PR diff |
| `.github/workflows/blast-radius.yml` | `blast_radius_check.py` on the PR body (pinned `markdown-it-py`) |

**Local proof** (from repo root; same commands as [AGENTS.md](AGENTS.md) "Prove a change"):

```bash
python3 tools/checks/no_new_comments.py --base origin/master --head HEAD
python3 tools/checks/agents_md_headings.py
python3 -m unittest discover -s tools/checks/tests -p "test_no_new_comments.py" -v
python3 -m unittest discover -s tools/checks/tests -p "test_agents_md_headings.py" -v
python -m pip install --require-hashes --only-binary=:all: --no-deps -r tools/ci/blast_radius_requirements.txt
python tools/ci/blast_radius_check.py --body-file pr.md
```

Put the PR body in `pr.md` for the blast-radius check. Script or hotkey changes: run the affected paths on Windows and record what you did in the PR (screenshot in a password-protected archive if needed).

**Horde QA + local proof:** GitHub Actions is the default gate (Horde). When hosted minutes are exhausted, run every command above locally and paste the full terminal output in the PR. Do not merge on red CI without owner approval and a written reason.

## PR flow

1. Open a GitHub issue: problem, evidence, acceptance criteria.
2. Branch `cursor/<issue#>-<slug>` from `master`. Never push directly to `master`.
3. **One scoped change per PR** (one issue, one logical item). No drive-by refactors.
4. PR body (`.github/pull_request_template.md` is only a `## Blast radius` stub; the list below is authoritative):
   - `## For Dread` first among narrative sections — **Ask**, **What changes for you**, **Proof** (only `https://` links to blob SHAs or Actions runs), **NOT done**.
   - A standalone `Level: 1` or `Level: 2` line (blast radius of the change for Dread).
   - **Owner** — one line naming the owner seat and merge tier, e.g. `Owner: Rig (TEST — owner merge after grader PASS).`
   - `## Blast radius` — concrete areas outside the diff this can break, or why nothing else depends on it, plus what you searched or ran (`rg`, manual test, etc.). Template placeholders and TBD fail CI.
   - `Closes #<issue>`, what/why, test plan + results, risk/rollback.
5. CI green **or** local proof (above). Never skip hooks, `--no-verify`, or "admin merge"; never disable workflows to land a change.
6. **Grader ≠ author:** a separate reviewer posts a PR comment whose first line is `**Horde QA independent grade: PASS|FAIL @ <sha7>**`. Grader starts at FAIL.
7. Owner merges when the issue is satisfied, threads are resolved, and proof is accepted. After merge: confirm the issue closed and checks passed.

Images in git must live inside a password-protected archive.

## Team rules

| Rule | Enforced by |
|---|---|
| No passwords or secrets in git | `tools/checks/no_secrets.py` in `no-new-comments.yml` |
| No new code comments on added lines (AHK, ini, Python checks, shell, etc.) | `tools/checks/no_new_comments.py` |
| No `safe_fs` helper in this repo — keep scripts and configs in the checkout folder; game automation reads/writes only beside the `.ahk` and `SOE-Config.ini` / `GTAV-Config.ini` (no seat-specific path defaults) | Reviewers (+ `no_secrets` / `no_new_comments` for automation under `tools/`) |
| Filled `## Blast radius` in the PR body | `tools/ci/blast_radius_check.py` in `blast-radius.yml` |
| `Level: 1` or `Level: 2` line in the PR body | Reviewers / Horde QA (not enforced by `blast_radius_check.py`; the checker strips `Level:` lines when scoring blast-radius text) |
| Required [AGENTS.md](AGENTS.md) headings stay present | `tools/checks/agents_md_headings.py` |
| No bypassing checks, graders, or gates; a wrong check is raised to Chief of Staff | Process; automatic hard FAIL for intentional bypass |

Landmines and the exact prove block: [AGENTS.md](AGENTS.md). Script behavior and requirements: [README.md](README.md).
