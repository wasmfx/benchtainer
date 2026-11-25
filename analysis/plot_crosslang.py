#!/usr/bin/python3

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# -----------------------------
# Configuration
# -----------------------------

INPUT_FILE = "paper-data.csv"
OUTPUT_PDF = "benchmark_comparison.pdf"
OUTPUT_PNG = "benchmark_comparison.png"

# Benchmarks and their visual ordering
BENCHMARK_ORDER = ["itersum", "treesum", "pi"]

# Publication-friendly colors
COLORS = {
    "itersum": "#4477AA",
    "treesum": "#EE6677",
    "pi": "#CCBB44",
}

# -----------------------------
# Load and clean data
# -----------------------------

with open("tmp/ocaml-results.csv") as f:
    ocaml = pd.read_csv(f)

with open("tmp/c-results.csv") as f:
    c = pd.read_csv(f)
    c["benchmark"] = c["parameter_benchmark"]
    c["engine"] = c["parameter_engine"]
    c["style"] = c["parameter_style"]

df = pd.concat([
    c[["median", "min", "max", "mean", "stddev", "language", "benchmark", "engine", "style"]],
    ocaml[["median", "min", "max", "mean", "language", "benchmark", "engine", "style"]]
    ]).reset_index(drop=True)

df.columns = df.columns.str.strip()
df["benchmark"] = df["benchmark"].str.strip().str.lower()
df["language"] = df["language"].str.strip().str.lower()

wasmfx_data = df.query("style == \"wasmfx\"")
baseline_data = df.query("style != \"wasmfx\"")

numeric_columns = [
    "median",
    "min",
    "max",
]

for col in numeric_columns:
    df[col] = pd.to_numeric(df[col], errors="coerce")


# -----------------------------
# Calculate ratios and errors
# -----------------------------

merged = pd.merge(
    baseline_data,
    wasmfx_data,
    on=["language", "engine", "benchmark"],
    suffixes=["_baseline", "_wasmfx"]
).drop(columns=["style_wasmfx", "style_baseline"])


merged["ratio"] = merged["median_baseline"] / merged["median_wasmfx"]
merged["range_baseline"] = merged["max_baseline"] - merged["min_baseline"]
merged["range_wasmfx"] = merged["max_wasmfx"] - merged["min_wasmfx"]

print(merged[["language", "benchmark", "engine", "ratio"]])

# Propagate STANDARD DEVIATION measurement ranges assuming independent uncertainties.
# For R = B / W:
# sigma_R = R * sqrt((sigma_B/B)^2 + (sigma_W/W)^2)

# merged["ratio_error"] = merged["ratio"] * np.sqrt(
#     (merged["stddev_baseline"] / merged["median_baseline"]) ** 2
#     + (merged["stddev_wasmfx"] / merged["median_baseline"]) ** 2
# )

merged["ratio_max"] = merged["max_baseline"] / merged["min_wasmfx"]
merged["ratio_min"] = merged["min_baseline"] / merged["max_wasmfx"]
merged["ratio_range"] = merged["ratio_max"] - merged["ratio_min"]
# print(merged[["language", "benchmark", "engine", "ratio", "ratio_min", "ratio_max"]])

# NOTE: Focus on D8, as the most widely-compatible engine.
if len(merged["engine"].unique()) > 1:
    merged = merged.query("engine == \"d8\"")

# -----------------------------
# Plot configuration
# -----------------------------

languages = merged["language"].unique()
benchmarks = [
    b for b in BENCHMARK_ORDER
    if b in merged["benchmark"].unique()
]

x = np.arange(len(languages))
n_benchmarks = len(benchmarks)

bar_width = 0.8 / n_benchmarks

fig, ax = plt.subplots(figsize=(8, 4.5))

# -----------------------------
# Draw grouped bars
# -----------------------------


for i, benchmark in enumerate(benchmarks):

    subset = (
        merged[merged["benchmark"] == benchmark]
        .set_index("language")
    )

    positions = x + (i - (n_benchmarks - 1) / 2) * bar_width

    ratio_to_min = subset["ratio"] - subset["ratio_min"]
    ratio_to_max = subset["ratio_max"] - subset["ratio"]

    ratios = [
        subset.loc[lang, "ratio"] if lang in subset.index else np.nan
        for lang in languages
    ]

    ratio_mins = [
        subset.loc[lang, "ratio_min"] if lang in subset.index else np.nan
        for lang in languages
    ]
    ratio_maxs = [
        subset.loc[lang, "ratio_max"] if lang in subset.index else np.nan
        for lang in languages
    ]

    ax.bar(
        positions,
        ratios,
        width=bar_width * 0.9,
        label=benchmark,
        color=COLORS[benchmark],
        yerr=[ratio_to_min, ratio_to_max],
        capsize=3,
        edgecolor="black",
        linewidth=0.6,
        error_kw={"elinewidth": 0.8},
    )

# -----------------------------
# Formatting
# -----------------------------

ax.axhline(
    y=1.0,
    color="black",
    linestyle="--",
    linewidth=1,
    alpha=0.7,
    label="Equal performance",
)

ax.set_xticks(x)
ax.set_xticklabels([lang.capitalize() for lang in languages])

ax.set_ylabel("Ratio (Baseline / WasmFX)")

ax.legend(
    # title="Benchmark",
    frameon=False,
    ncol=2,
)

ax.grid(
    axis="y",
    linestyle=":",
    alpha=0.4,
)

ax.set_axisbelow(True)

# Remove unnecessary borders
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)

fig.tight_layout()

# -----------------------------
# Export publication figures
# -----------------------------

fig.savefig(
    OUTPUT_PDF,
    bbox_inches="tight",
)

fig.savefig(
    OUTPUT_PNG,
    dpi=300,
    bbox_inches="tight",
)

plt.show()

print("Calculated ratios:")
print(
    merged[["benchmark", "language", "ratio", "ratio_range"]]
    .to_string(index=False)
)

print(f"\nSaved {OUTPUT_PDF} and {OUTPUT_PNG}")
