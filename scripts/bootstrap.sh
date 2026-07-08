#!/usr/bin/env bash
# ML Practical Handbook — Phase 2 (Deep Learning) environment bootstrap.
#
# One-shot setup for notebooks 16 (CNN), 17 (RNN/LSTM), 18 (Autoencoder).
# Run from the repo root (the directory containing this script's parent, i.e.
# handbook/notebooks/):
#
#     bash scripts/bootstrap.sh
#
# What it does:
#   1. Creates (or reuses) a .venv with the base requirements.txt stack.
#   2. Installs the deep-learning stack from requirements-dl.txt.
#   3. Audits the GPU situation and prints a plain-English verdict.
#   4. Runs a 1-epoch MNIST smoke test to prove TF/Keras actually train.
#
# The script is idempotent — safe to re-run.
set -euo pipefail

# Resolve repo root = parent dir of scripts/.  Works regardless of cwd.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT"

PYTHON="${PYTHON:-python3}"
VENV="$ROOT/.venv"

# ---------- pretty printing --------------------------------------------------
BOLD=$'\033[1m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'
BLUE=$'\033[34m'; DIM=$'\033[2m'; RESET=$'\033[0m'
say()  { printf '%s\n' "${BOLD}▶ $*${RESET}"; }
ok()   { printf '  %s✓%s %s\n' "$GREEN" "$RESET" "$*"; }
warn() { printf '  %s⚠%s  %s\n' "$YELLOW" "$RESET" "$*"; }
note() { printf '  %s·%s  %s\n' "$DIM" "$RESET" "$*"; }

# ---------- 1. venv + base stack ---------------------------------------------
say "Creating virtual environment at ${BLUE}$VENV${RESET}"
if [[ -x "$VENV/bin/python" ]]; then
    note "venv already exists — reusing."
else
    "$PYTHON" -m venv "$VENV"
fi
PIP=("$VENV/bin/pip" install --upgrade pip)
"${PIP[@]}" >/dev/null 2>&1 || true

say "Installing base stack (requirements.txt)"
"$VENV/bin/pip" install -q -r "$ROOT/requirements.txt"
ok "base stack ready"

# ---------- 2. DL stack ------------------------------------------------------
say "Installing deep-learning stack (requirements-dl.txt)"
"$VENV/bin/pip" install -q -r "$ROOT/requirements-dl.txt"
ok "deep-learning stack ready"

# ---------- 3. GPU audit -----------------------------------------------------
say "Auditing GPU / accelerator support"
tf_gpu_supported=false
gpu_report=""

have() { command -v "$1" >/dev/null 2>&1; }

# NVIDIA
if have nvidia-smi; then
    if nvidia-smi --query-gpu=name,driver_version --format=csv,noheader >/dev/null 2>&1; then
        gpu_report+="NVIDIA GPU detected: $(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)\n"
        tf_gpu_supported=true
    fi
fi

# AMD ROCm
if have rocminfo; then
    gfx=$(rocminfo 2>/dev/null | awk '/^  Name:/ && /gfx/ {print $3; exit}')
    gpu_report+="AMD GPU detected via ROCm (gfx arch: ${gfx:-unknown})\n"
    # ROCm officially supports gfx900/906/908/90a/940/941/942 and RDNA3 datacentre
    # + RX 7900 XT/XTX. iGPUs like the 780M (gfx1103) are NOT supported.
    case "${gfx:-}" in
        gfx900|gfx906|gfx908|gfx90a|gfx940|gfx941|gfx942|gfx1100|gfx1101|gfx1102)
            tf_gpu_supported=true ;;
        *) gpu_report+="  -> ${gfx:-this arch} is NOT on ROCm's official support list\n" ;;
    esac
fi

# Detect AMD iGPU / dGPU via sysfs even without ROCm installed.
for drv in /sys/class/drm/card*/device/driver; do
    case "$(readlink -f "$drv" 2>/dev/null || true)" in
        *amdgpu)
            cpu=$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | sed 's/.*: //')
            if echo "$cpu" | grep -qiE 'Ryzen.*with Radeon|Athlon.*with Radeon'; then
                gpu_report+="AMD Radeon iGPU detected: $cpu\n"
                gpu_report+="  -> integrated Radeon (e.g. 780M / gfx1103) is NOT on ROCm's support list\n"
            elif [[ -z "$gpu_report" ]]; then
                gpu_report+="AMD GPU detected (amdgpu driver, ROCm not installed)\n"
            fi
            ;;
        *nouveau) gpu_report+="NVIDIA GPU detected (nouveau driver — no CUDA; install proprietary driver)\n" ;;
        *i915)    gpu_report+="Intel iGPU detected (i915) — stock PyTorch is the forward path; TF needs ITEX\n" ;;
    esac
done

echo
if $tf_gpu_supported; then
    printf "  %s✓ GPU acceleration available for TensorFlow%s\n" "$GREEN" "$RESET"
else
    printf "  %s· No usable GPU for TensorFlow%s -> running CPU-only.\n" "$DIM" "$RESET"
fi
printf '%b' "${gpu_report:-  (no GPU detected at all)\n}"

# Why Vulkan isn't an option — short, factual note printed every run so the
# reasoning isn't lost.
if ! $tf_gpu_supported; then
    note "TensorFlow has no Vulkan backend (experimental years ago, never finished,"
    note "no tensorflow-vulkan wheel). On AMD, ROCm is the only TF GPU path and it"
    note "targets RX 7900+ / data-centre GPUs. CPU is the right choice here — all"
    note "the dd/ course datasets (MNIST, Fashion-MNIST, CIFAR-10, IMDB) train in"
    note "well under a minute per epoch on a modern CPU."
fi

# ---------- 4. smoke test ----------------------------------------------------
say "Smoke test: import TF/Keras, train 1 epoch on MNIST"
"$VENV/bin/python" - <<'PY'
import os, sys
# These MUST be set before `import tensorflow`. The first kills TF's own C++ log
# levels; the second disables oneDNN's verbose "custom operations are on" line.
os.environ.setdefault("TF_CPP_MIN_LOG_LEVEL", "3")
os.environ.setdefault("TF_ENABLE_ONEDNN_OPTS", "0")
import numpy as np
import tensorflow as tf
from tensorflow import keras
print(f"  TensorFlow {tf.__version__}  |  Keras {keras.__version__}")
print(f"  TF built with CUDA: {tf.test.is_built_with_cuda()}  |  GPUs visible: {len(tf.config.list_physical_devices('GPU'))}")
print(f"  numpy {np.__version__}, python {sys.version.split()[0]}")

(xtr, ytr), _ = keras.datasets.mnist.load_data()
xtr = xtr.astype("float32") / 255.0
m = keras.Sequential([
    keras.layers.Input(shape=(28, 28)),
    keras.layers.Flatten(),
    keras.layers.Dense(64, activation="relu"),
    keras.layers.Dense(10, activation="softmax"),
])
m.compile(optimizer="adam", loss="sparse_categorical_crossentropy", metrics=["accuracy"])
h = m.fit(xtr[:3000], ytr[:3000], epochs=1, batch_size=64, verbose=0)
print(f"  1-epoch smoke test OK — loss {h.history['loss'][0]:.3f}, acc {h.history['accuracy'][0]:.3f}")
PY

echo
say "${GREEN}Done.${RESET}"
note "Next: open 16_CNN.ipynb (once built). Start the server with:  $VENV/bin/jupyter lab"
