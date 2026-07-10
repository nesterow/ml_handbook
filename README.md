# ML Practical Handbook

A practical, Python/Jupyter handbook built from four courses: **Machine Learning**
(Dr. Nicholas Harkiolakis, BSC508), **Fundamentals of Data Science** (Dr. Rashad Aouf, BSC603, CSI505),
**Neural Networks** and **Deep Learning** (both Dr. Jeremy Scerri, BSC503, BSC701). The textbook
*Hands-On Machine Learning with R* (Boehmke & Greenwell) is used as reference
material only — the handbook is Python, not R.

The goal is **not** to reproduce any course's slides. It is a runnable framework you
can apply to real data: plain-language theory, a consistent **Explore → Feature‑
Engineer → Train → Validate** workflow, heavy visualisation, and the validation /
hypothesis‑testing.

> The original course materials (slides, recordings, case‑study PDFs) are not
> included here for copyright reasons. This repo ships as standalone supplementary
> material: the notebooks, this README, and the harness instructions.

## Harness (Claude, Opencode, etc)

By default this project uses AGENTS.md standard.
If you use Calude, Gemini or other harness that doesn't follow the standard,
you can run `scripts/switch-harness.sh` or ask your agent to read AGENTS.md and setup project. 

This repo has three skills:

- **teacher** — answers the owner's questions from the handbook; web-searches for
 verified answers when a question goes beyond the material.
- **roaster** — asks fundamental questions and grades/corrects the owner's answers.
- **researcher** — researches a topic via web search, lays out an implementation
 plan, and links the handbook notebooks to read first.

Invoke via `/teacher`, `/roaster`, `/researcher` or let the descriptions trigger.


## Quick start

Create a virtual environment and install the base
stack:

```bash
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
.venv/bin/jupyter lab
```

Open `00_Theory_Reference.ipynb` first (keep it in a side tab) and read `01` → `13`
in order. Datasets are either bundled in `data/` or fetched at runtime from
OpenML/sklearn — an internet connection is needed the first time you run a notebook
(files are then cached).

For the deep-learning notebooks (16–18), run `bash scripts/bootstrap.sh` once to add
the TensorFlow/Keras stack (see "Phase 2" below).

## Notebook index

| # | Notebook | Course | Topic |
|---|----------|--------|-------|
| 00 | `00_Theory_Reference.ipynb` | shared | The theory & stats glossary. **Start here**, keep open in a side tab. §0 = dictionary collisions table. |
| 01 | `01_Setup_and_Toolchain.ipynb` | — | Environment check, pandas/sklearn 101, CEO dataset intro |
| 02 | `02_Introduction_to_ML.ipynb` | Machine Learning | What ML is, learning types, train/test, first baseline |
| 03 | `03_EDA_and_Feature_Engineering.ipynb` | Machine Learning | Distributions, missingness, scaling, encoding |
| 04½ | `04_1_Probability_and_Bayes.ipynb` | Fundamentals of Data Science | Probability: conditional, **Bayes (disease‑screening paradox)**, independence vs correlation, RVs/distributions, CLT, Naive Bayes. Read before 04 and 05. |
| 04 | `04_Regression.ipynb` | Machine Learning | Linear + logistic regression, **diagnostic plots**, confounder/Simpson's paradox |
| 05 | `05_Validation_Hypothesis_AB_Testing.ipynb` | *added* | CV, hypothesis tests, **ANOVA**, power, full A/B test analysis |
| 06 | `06_kNN.ipynb` | Machine Learning | Distance metrics, choosing k, **scaling failure + curse of dimensionality** |
| 07 | `07_Decision_Trees.ipynb` | Machine Learning | Splitting, pruning, **the unpruned‑tree overfit + the fix** |
| 08 | `08_Random_Forests.ipynb` | Machine Learning | Bagging, OOB, hyperparameter tuning, boosting comparison, **the forest that hides a leak** |
| 09 | `09_Neural_Networks.ipynb` | Machine Learning | Feed‑forward nets, backprop, MLP tuning, **unscaled‑data + capacity failures** |
| 10 | `10_SVM.ipynb` | Machine Learning | Margins, kernel trick, C/gamma, **scaling failure (with the same picture as kNN)** |
| 11 | `11_PCA.ipynb` | Machine Learning | Variance, eigendecomposition, scree plots, **unscaled‑data hijacks PC1** |
| 12 | `12_Clustering.ipynb` | Machine Learning | k‑means, hierarchical, GMM, **k‑means on non‑spherical + clusters‑in‑noise failures** |
| 13 | `13_Model_Comparison_and_Capstone.ipynb` | Machine Learning | Benchmark all algorithms, **when‑to‑use‑what cheatsheet**, full capstone pipeline |
| 14 | `14_Neural_Network_Math.ipynb` | *added* | Gradient descent + backprop, loss‑surface plots, conditioning — the math under notebook 09 |
| 15 | `15_Neural_Network_Components.ipynb` | *added* | Activations (dying ReLU), loss functions, optimisers SGD→Adam, He/Xavier init, regularisation |
| 16 | `16_Convolutional_Neural_Networks.ipynb` | Deep Learning | CNNs in Keras: convolution, pooling, **MLP contrast**, overfitting+cures, feature maps, LeNet→ResNet→transfer learning |
| 17 | `17_Recurrent_Neural_Networks.ipynb` | Deep Learning | RNNs/LSTMs, unrolling, BPTT, **vanishing gradient made visible** (adding task), LSTM gates, IMDB sentiment |
| 18 | `18_Autoencoders.ipynb` | Deep Learning | Undercomplete/denoising/deep autoencoders, **anomaly detection (AUC 0.91)**, **AE‑vs‑PCA contrast**, VAEs/RBMs |

**00 first**, then read 01 → 13 in order (each assumes the previous). **04½**
(Probability & Bayes) slots in between 03 and 04 — read it before regression and
validation, which both lean on it. **14–15** are the neural‑net math deep‑dive;
**16–18 are Phase 2** (Deep Learning) and need the extra DL stack.

### The shared Theory & Statistics Reference (`00_Theory_Reference.ipynb`)

Every notebook uses terms (variance, correlation, significance, bias, confounding)
that have *different* meanings in probability, classical stats, and ML. Rather than
re‑explain them in each notebook, one shared reference defines them precisely, with
formulas, "why it matters", and the disambiguation that prevents confusion. It opens
with §0 — a four‑row table (Bias, Variance, Significance, Independent) where each row
shows the statistical, ML/CS, and business meanings side‑by‑side plus the specific
trap people fall into. Sections §1–§10 then expand each concept. When a notebook says
`§3.2`, that's your cue to jump to that section.

## Phase 2 — Deep Learning (notebooks 16–18)

Notebooks 16–18 cover the Deep Learning course: **CNNs**, **RNNs/LSTMs**, and
**autoencoders**. They use **Keras 3 (TensorFlow backend)** instead of scikit‑learn,
because convolution / recurrence / reconstruction can't be done with
`MLPClassifier`. The datasets (Fashion‑MNIST, IMDB) are deliberately different from
the fundamentals' CEO backbone.

**Setup** (one shot, from the repo root):

```bash
bash scripts/bootstrap.sh
```

This installs `requirements-dl.txt` (tensorflow‑cpu, keras 3, tensorflow‑datasets)
into `.venv`, audits the GPU, and runs a 1‑epoch smoke test. CPU trains Fashion‑MNIST in
~2s/epoch. On an NVIDIA machine, swap `tensorflow-cpu` for `tensorflow` in
`requirements-dl.txt`; on a supported AMD card use AMD's ROCm‑pinned wheel.

## Notebook structure (consistent across all)

1. Learning objectives
2. Plain‑language concept — intuition first, no jargon
3. Theory cross‑references — `§x.x` pointers into the shared reference
4. Standard process — Explore → Feature‑engineer → Train → Diagnose/Validate, with heavy visualisation
5. Worked example A — CEO dataset (the backbone); worked example B — open dataset best‑fit for the topic
6. A failure case — where a plausible approach breaks, so you learn what to watch for
7. Common pitfalls & how to avoid shooting yourself in the foot
8. Practice exercises (with hidden answers)
9. References

Code is deliberately secondary — the reading of plots and the reasoning about
process is primary. Every notebook is executed end‑to‑end before delivery, so cells
ship with real outputs (plots, tables, metrics), not empty placeholders.

## Environment

- Python 3.12. `python3 -m venv .venv && .venv/bin/pip install -r requirements.txt`
- Base stack pinned in `requirements.txt`; DL stack in `requirements-dl.txt` (via `scripts/bootstrap.sh`).
- Shared imports live in `setup.py` — notebooks do `from setup import *` first.

## Sources

Built from four courses (referred to by name only — materials not included for
copyright): **Machine Learning** (Dr. Nicholas Harkiolakis; reference textbook
Boehmke & Greenwell, *Hands‑On ML with R*), **Fundamentals of Data Science**
(Rashad Aouf, CSI505), **Neural Networks** and **Deep Learning** (Dr. Jeremy Scerri).
Datasets: scikit‑learn builtins, [OpenML](https://www.openml.org/), keras.datasets,
and the CEO data from <https://harkiolakis.com/files/Data.csv>.
