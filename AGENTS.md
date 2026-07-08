# AGENTS.md — ML Practical Handbook

This file instructs AI coding agents working in this repository. It describes the
**handbook** and how to work on it. Read it before editing notebooks or answering
questions about the material.

> **Scope:** This repo is a *handbook* — supplementary learning material built by the
> owner from several courses. The original course materials (slides, recordings,
> case-study PDFs) are **not in this repo and must never be referenced by directory
> path**. Refer to courses by **name** only.

## What this handbook is

A practical, Python/Jupyter machine-learning + deep-learning handbook. The goal is
not to reproduce any course's slides — it is a runnable framework the owner applies
to real data: plain-language theory, a consistent **Explore → Feature-Engineer →
Train → Validate** workflow, heavy visualisation, and the validation / A-B-test /
hypothesis-testing toolkit most courses leave out.

Everything is **Python** (pandas + scikit-learn + statsmodels for the fundamentals;
Keras 3 / TensorFlow for the deep-learning notebooks), even though some source
courses used R or KNIME — Python is the industry default this handbook standardises
on.

## Source courses (referred to by name only)

The handbook synthesises material from four courses. **Never reference their file
locations** — use the names below.

| Course name | Code / context | Instructor | Reference textbook |
|---|---|---|---|
| **Machine Learning** | graduate ML module | **Dr. Nicholas Harkiolakis** | Boehmke & Greenwell, *Hands-On Machine Learning with R* (CRC Press, 2019), free at <https://bradleyboehmke.github.io/HOML/> — used as reference material only; the handbook is Python, not R |
| **Fundamentals of Data Science** | CSI505 | **Rashad Aouf** (PhD in Computing, Engineering, and Mathematics) | — |
| **Neural Networks** | NN foundations | **Dr. Jeremy Scerri** | Heaton, *Introduction to the Math of Neural Networks*; Slavio, *Neural Networks: Tools and Techniques for Beginners* (reference) |
| **Deep Learning** | DL module (CNNs, RNNs, autoencoders) | **Dr. Jeremy Scerri** | — |

## Repository layout

```
. (repo root = handbook/notebooks)
├── AGENTS.md this file
├── README.md the human-facing index + quick start
├── requirements.txt base stack (numpy/pandas/sklearn/...)
├── requirements-dl.txt deep-learning stack (tensorflow-cpu, keras 3, tf-datasets)
├── setup.py shared imports + warning filters; notebooks do `from setup import *`
├── scripts/
│ └── bootstrap.sh one-shot DL env setup + GPU audit + smoke test
├── data/
│ └── ceo_data.csv the common-thread dataset (60 rows)
├── 00_Theory_Reference.ipynb shared theory & stats glossary — read first
├── 01..13_*.ipynb fundamentals (setup → capstone)
├── 04_1_Probability_and_Bayes.ipynb probability, slots between 03 and 04
├── 14,15_*.ipynb NN theory deep-dives (math + components)
├── 16,17,18_*.ipynb deep learning (CNN, RNN/LSTM, autoencoders) — needs the DL stack
└── build/ content modules (_nbNN_*.py) that generate the .ipynb — GITIGNORED
```

`build/` is gitignored: the `.ipynb` files are the committed artefacts; the `_nb*.py`
modules are the sources used to regenerate them.

## Notebook structure (consistent across all 20)

Every notebook follows this pattern — match it when editing or creating:

1. Title with emoji prefix + course mapping / prerequisite / ` §x` theory cross-refs
2. **Learning objectives**
3. **The process** — a Mermaid flowchart
4. Numbered concept sections with `### ` subsections where useful
5. Heavy **visualisation** (plots over numbers — code is secondary)
6. At least one **failure case** (red `#c44e52` = bad, green `#55a868` = good, blue `#4c72b0` = neutral)
7. **Common pitfalls & how to avoid shooting yourself in the foot**
8. **Exercises** with hidden answers in a `<details>` block
9. **References** ( theory section + related notebooks + external)

Cross-references use ` §x.y` to point into `00_Theory_Reference.ipynb` (the shared
glossary), and `notebook NN` / `notebook 04½` for notebook-to-notebook links.

## How notebooks are built and run

- **Build:** each `build/_nbNN_*.py` defines a `CELLS` list + `OUTPUT` filename;
 `python build/_nb_builder.py build/_nbNN_*.py` writes the `.ipynb` via nbformat.
- **Execute (render outputs):** `.venv/bin/jupyter nbconvert --to notebook --execute
 NN_*.ipynb --output NN_*.ipynb`. Always re-execute after rebuilding so cells ship
 with real outputs.
- **Environment:** Python 3.12 in `.venv`. Base stack from `requirements.txt`;
 notebooks 16–18 additionally need `requirements-dl.txt` (run `scripts/bootstrap.sh`).
- **Shared imports:** every notebook starts (first code cell) with `from setup import *`.
 DL notebooks then set `TF_CPP_MIN_LOG_LEVEL=3` + `TF_ENABLE_ONEDNN_OPTS=0` before
 `import tensorflow as tf` (silences the oneDNN log spam).
- **️ After renaming any `build/_nb*.py`, clear `build/__pycache__`** — the builder
 caches modules by name and a rename leaves a stale cache that silently serves old
 content.

## Hard-won conventions (do not violate)

- **Mermaid node labels must be quoted** if they contain `(`, `)`, `,`, `|`, `+`, `=`,
 `->`, `<`, `>`. Write `A["joint P(A,B)"]`, never `A[joint P(A,B)]` — the latter
 throws a parse error in Jupyter's Mermaid renderer. When in doubt, quote every label.
- **No inner Python docstrings (`"""`) inside a cell's triple-quoted source string** —
 they terminate the cell early. Use `#` comments instead.
- **pandas 3.0:** use `select_dtypes(include=["object", "string"])`, not
 `include="object"` (triggers a Pandas4Warning).
- **scikit-learn 1.9:** `root_mean_squared_error(...)` (no `squared=False`);
 `SVC(probability=True)` is deprecated — use `CalibratedClassifierCV`.
- **GPU note:** TensorFlow has no Vulkan backend. Everything runs **CPU-only**, which
 is fine for MNIST/Fashion-MNIST/IMDB scale. Don't propose GPU code paths.
- **Don't propose CIFAR-10 / large downloads** in sandboxed execution — they time out.
 Prefer datasets bundled in sklearn/keras.datasets that are already cached.

## The sample dataset (common thread)

`data/ceo_data.csv` (60 rows) runs through every fundamentals notebook for
continuity. Columns: `Sector`, `CEO_Gender`, `Size`, `Security_Invest`,
`Security_Breach_Att`, `Succ_Sec_Breaches`, `Sec_Rating`, `CEO_Sec_Exp`,
`LOT_in_Business`, `Stock_Market` (binary target). Because 60 rows can't carry every
technique, each topic also uses a best-fit open dataset (iris, digits, Fashion-MNIST,
IMDB, Ames housing, Telco churn).

## Skills available in this repo

Three skills live under `.agents/skills/`:

- **teacher** — answers the owner's questions from the handbook; web-searches for
 verified answers when a question goes beyond the material.
- **roaster** — asks fundamental questions and grades/corrects the owner's answers.
- **researcher** — researches a topic via web search, lays out an implementation
 plan, and links the handbook notebooks to read first.

Invoke via `/teacher`, `/roaster`, `/researcher` or let the descriptions trigger.

## Harness switching

`scripts/switch-harness.sh <harness>` copies this `AGENTS.md` to the filename a given
harness expects (e.g. `CLAUDE.md` for Claude Code, `GEMINI.md` for Gemini). See
`scripts/AGENT_PROMPT.md` for the agent-side instructions.
