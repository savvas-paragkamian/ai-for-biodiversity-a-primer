# Setting up for the workshop

What to install before the hands-on sessions, how to check it, the ten Git
commands the sessions use, and the controls of each harness. The commands
were taken from the tools' own documentation and from the installed tools on
2 November 2026; they will date, so check each tool's `--help`. The slides
of deck 0 in `../presentations/00-setup/` cover the same ground.

## What you need

| Layer | For | Tested with (2 November 2026) |
|---|---|---|
| A terminal: macOS, Linux, or WSL on Windows | everything | macOS; nothing was tested on Windows |
| R, with `ellmer` for the testing exercise | Chapters 10, 11, 14 | R 4.5.1, ellmer 0.5.0 |
| Git | the checkpoint before every agent session | 2.54 (Apple); 2.56.0 is current at git-scm.com |
| Ollama and one model | the local track | Ollama 0.40.13; `gemma4:12b` (session), `qwen3:8b` (extraction) |
| A harness: OpenCode, Claude Code or Codex | Chapter 10 | OpenCode 1.17.11, Claude Code 2.1.316, Codex 0.162.1 |

The book's advice for Windows (Chapter 8) is a Linux environment inside
Windows (WSL); the harnesses also run natively, with the differences noted
below.

## Git

```bash
# macOS: Apple's command line tools, or Homebrew
xcode-select --install
brew install git
# Debian and Ubuntu
sudo apt-get install git
# Fedora
sudo dnf install git
# Windows: the Git for Windows installer from https://git-scm.com/install/windows, or
winget install --id Git.Git -e --source winget
# then, in any terminal
git --version
git config --global user.name  "Your Name"
git config --global user.email "you@example.org"
```

Source: <https://git-scm.com/install/>. Git for Windows also gives the
harnesses a Bash shell to run commands in.

## Ollama

```bash
# macOS and Linux (or the .dmg from https://ollama.com/download)
curl -fsSL https://ollama.com/install.sh | sh
# Windows, in PowerShell (or OllamaSetup.exe from https://ollama.com/download)
irm https://ollama.com/install.ps1 | iex
ollama --version
ollama pull gemma4:12b      # the model session/opencode.json names
ollama list                 # what is on disk
ollama ps                   # what is loaded, and with which CONTEXT
ollama run gemma4:12b       # a chat; /bye leaves it
```

A 12B model at four bits needs about 8 GB of memory and the context adds
more (Chapter 13); 16 GB runs it, 32 GB runs it comfortably. The test runs
used `gemma4:12b-mlx-32k` on Apple silicon and `qwen3:8b`; see `README.md`.

**The context.** Ollama's default context depends on the graphics memory
(4K below 24 GiB). An agent re-sends the whole session every turn and needs
tens of thousands of tokens; at 4K it forgets the task. Set the context once
for the server, or per model:

```bash
OLLAMA_CONTEXT_LENGTH=32768 ollama serve    # or the slider in the Ollama app's settings
# per model, saved under a new name
ollama run gemma4:12b
  /set parameter num_ctx 32768
  /save gemma4-32k
ollama ps                                   # CONTEXT must show the new value
```

A larger context needs more memory. The vendor advises 64K for agents.
Source: <https://docs.ollama.com/context-length>; Chapter 8 and Appendix D.

## OpenCode

```bash
curl -fsSL https://opencode.ai/install | bash     # macOS, Linux, WSL
npm install -g opencode-ai                         # any system with Node
brew install anomalyco/tap/opencode                # Homebrew, version 1 (brew install opencode gives version 2)
scoop install opencode                             # Windows (or: choco install opencode)
opencode --version
opencode upgrade                                   # later
```

Hosted providers: type `/connect` in the interface and paste a key; it is
stored under `~/.local/share/opencode/`. Local models: a `provider` block in
the project's `opencode.json` points at Ollama; `session/opencode.json` is a
complete example, with the permission rules of Chapter 10. The two settings
that cause most local-agent failures are the model's `"tool_call": true` and
the `limit.context` (Chapter 8).

Source: <https://opencode.ai/docs/> (install, providers, cli, keybinds).

## Claude Code

```bash
curl -fsSL https://claude.ai/install.sh | bash     # macOS, Linux, WSL
brew install --cask claude-code                    # Homebrew
irm https://claude.ai/install.ps1 | iex            # Windows PowerShell
winget install Anthropic.ClaudeCode                # Windows
claude --version
claude doctor                   # checks the installation and settings
claude                          # first run opens the browser to log in
claude update                   # native installs update themselves; this forces it
```

Needs a Pro, Max, Team or Enterprise plan, or API access; the free plan does
not include it. Prompts and files go to Anthropic: this is the hosted track.
On Windows, the sandbox works only inside WSL 2.

Source: <https://code.claude.com/docs/en/setup>.

## Codex

```bash
npm install -g @openai/codex                       # any system with Node
brew install --cask codex                          # Homebrew
curl -fsSL https://chatgpt.com/codex/install.sh | sh    # macOS, Linux
codex --version
codex doctor
codex                           # first run: "Sign in with ChatGPT"
codex --oss --local-provider ollama    # a local model through Ollama
```

Sign in with a ChatGPT plan or an API key (`codex login --with-api-key`).
Settings live in `~/.codex/config.toml`. Codex was not used in the book's
test runs; its commands here come from `codex --help` and its documentation.

Source: <https://github.com/openai/codex>, <https://developers.openai.com/codex>.

## Git in ten commands

Commit before an agent starts, read the diff after, keep a way back
(Chapters 6 and 10). Deny `git reset --hard`, `git clean` and `git push`
in the harness configuration, as `session/opencode.json` and
`session/.claude/settings.json` do.

```bash
git init                          # start tracking this folder
git status                        # what changed, what is untracked
git add -A                        # stage everything
git commit -m "Before the agent session"   # the checkpoint
git diff                          # what the agent changed, line by line
git log --oneline                 # the history
git restore scripts/01_check.R    # undo one file to the last commit
git restore .                     # undo every tracked file
git stash                         # park uncommitted changes; git stash pop brings them back
git remote add origin <url> && git push -u origin main   # a copy elsewhere
```

After a session:

```bash
git status --short                # only scripts/, data/processed/, logs/ should be new
git status --short data/raw       # must print nothing
git diff --stat
git diff data/
```

A `.gitignore` lists what Git should not track: large data, build products,
secrets. Never commit a key or a token. The free book *Pro Git*
(<https://git-scm.com/book>) covers the rest.

## Driving a harness

Every harness has the same controls. Type `/` in any of them for the list.

| | Claude Code | OpenCode | Codex |
|---|---|---|---|
| Model | `/model` | `/models` | `/model` |
| Reasoning effort | `/effort low`…`xhigh`, `max`, `auto`; arrows in `/model`; `/fast` | `Ctrl+T` cycles the variant; `opencode run --variant high` | in `/model` |
| Context and usage | `/context`; `/usage` (alias `/cost`) | `Ctrl+X` then `S` (status view); `opencode stats` | `/status` |
| Permissions | `/permissions`; `Shift+Tab` cycles modes; `/sandbox`; `--permission-mode plan` | `opencode.json`; `Tab` switches Plan and Build | `/permissions`; `-s read-only|workspace-write|danger-full-access`; `-a on-request|never` |
| Compact, interrupt | `/compact`, `/clear`; `Esc`; `/rewind` | `/compact`; `/undo`, `/redo`; `Esc` | `/compact` |
| Sessions | `/resume`; `claude -c` | `opencode run --continue` | `codex resume`; `codex exec resume --last` |
| One prompt, no conversation | `claude -p "prompt"` | `opencode run "prompt"` (`-m ollama/gemma4:12b`) | `codex exec "prompt"` (`-o file`) |
| Rules file | `CLAUDE.md`, or `AGENTS.md` when there is no `CLAUDE.md` | `AGENTS.md` (`/init` writes one) | `AGENTS.md` (`/init` writes one) |

Sources: <https://code.claude.com/docs/en/commands>,
<https://opencode.ai/docs/keybinds/>, <https://developers.openai.com/codex>,
and each tool's `--help`, read 2 November 2026.

**Tokens and context.** A token is about four characters (Chapter 7). An
agent re-sends the whole session every step, so prompts reach tens of
thousands of tokens (Chapter 13). When the window fills, old context is cut
and the agent forgets: watch the context display and compact, or start a new
session, at a natural break. Local models have no usage meter; their cost is
the wait before the first token.

**Unattended runs.** The permission rules still apply. Never use a "skip
permissions" flag outside a container with no network (Chapter 15). Save the
output under `logs/` with the date, the model and the prompt (Chapter 9).

## Two-minute check before the session

```bash
git --version && ollama --version && opencode --version   # or claude, codex
ollama list                              # the workshop's model is there
ollama ps                                # loaded, CONTEXT 32768 or more
cp -R workshop/session ~/survey && cd ~/survey
git init && git add -A && git commit -m "Before the agent session"
chmod -R a-w data/raw                    # Windows: attrib +R, or Properties
opencode                                 # reads AGENTS.md and opencode.json
```

- The harness cannot see the model: check that `opencode.json` names the tag
  `ollama list` shows, with `"tool_call": true`.
- The agent forgets the task: the context is too small on one side or the other.
- A command is refused: the configuration is working. Read the rule before
  widening it.
