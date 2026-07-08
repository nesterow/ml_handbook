"""Shared setup for the ML Practical Handbook notebooks.

Each notebook starts its first code cell with:

    from setup import *

That single line pulls in the full data-science stack (numpy, pandas, sklearn,
matplotlib, seaborn, ...), applies sensible plotting defaults, and tames the
noisy warnings/library logs so output cells stay clean — while keeping genuine
errors visible.

Re-enable everything for debugging with:   export WARNINGS=1
"""
import os
import warnings
import logging

# ── Warning & log suppression (set WARNINGS=1 to disable) ───────────────────
if not os.environ.get("WARNINGS"):
    warnings.filterwarnings("ignore", category=FutureWarning)
    warnings.filterwarnings("ignore", category=DeprecationWarning)
    warnings.filterwarnings("ignore", category=UserWarning)
    try:
        from sklearn.exceptions import ConvergenceWarning
        warnings.filterwarnings("ignore", category=ConvergenceWarning)
    except Exception:
        pass
    for _lib in ("lightgbm", "xgboost", "absl", "tensorflow"):
        logging.getLogger(_lib).setLevel(logging.ERROR)

# ── Core stack ──────────────────────────────────────────────────────────────
import numpy as np
import pandas as pd
import scipy
import sklearn

# Plotting
import matplotlib.pyplot as plt
import seaborn as sns

# sklearn — the most-used pieces, imported once
from sklearn.model_selection import (
    train_test_split, cross_val_score, cross_validate,
    KFold, StratifiedKFold, RepeatedStratifiedKFold,
    GridSearchCV, validation_curve,
)
from sklearn.preprocessing import (
    StandardScaler, OneHotEncoder, OrdinalEncoder, TargetEncoder,
    PolynomialFeatures,
)
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline, make_pipeline
from sklearn.impute import SimpleImputer
from sklearn.linear_model import (
    LinearRegression, Ridge, Lasso, ElasticNet, LogisticRegression,
)
from sklearn.tree import DecisionTreeClassifier, DecisionTreeRegressor, plot_tree
from sklearn.ensemble import (
    RandomForestClassifier, RandomForestRegressor, BaggingClassifier,
    GradientBoostingClassifier,
)
from sklearn.neighbors import KNeighborsClassifier, KNeighborsRegressor
from sklearn.svm import SVC, SVR
from sklearn.neural_network import MLPClassifier, MLPRegressor
from sklearn.cluster import KMeans, AgglomerativeClustering, DBSCAN
from sklearn.decomposition import PCA
from sklearn.metrics import (
    accuracy_score, confusion_matrix, classification_report,
    mean_squared_error, mean_absolute_error, r2_score, root_mean_squared_error,
    roc_auc_score, roc_curve, precision_recall_curve,
)
from sklearn.datasets import (
    load_iris, load_digits, load_breast_cancer, load_wine,
    fetch_california_housing, fetch_openml,
)
from sklearn.inspection import permutation_importance

# Sensible plotting defaults applied for every notebook.
sns.set_theme(style="whitegrid", context="notebook")
plt.rcParams["figure.figsize"] = (8, 4)
plt.rcParams["figure.dpi"] = 110

__all__ = [
    # stdlib
    "os", "warnings", "logging", "np", "pd", "scipy", "sklearn",
    # plotting
    "plt", "sns",
    # sklearn.model_selection
    "train_test_split", "cross_val_score", "cross_validate",
    "KFold", "StratifiedKFold", "RepeatedStratifiedKFold",
    "GridSearchCV", "validation_curve",
    # sklearn.preprocessing
    "StandardScaler", "OneHotEncoder", "OrdinalEncoder", "TargetEncoder",
    "PolynomialFeatures",
    # sklearn.compose / pipeline / impute
    "ColumnTransformer", "Pipeline", "make_pipeline", "SimpleImputer",
    # sklearn.linear_model
    "LinearRegression", "Ridge", "Lasso", "ElasticNet", "LogisticRegression",
    # sklearn.tree / ensemble / neighbors / svm / neural_network
    "DecisionTreeClassifier", "DecisionTreeRegressor", "plot_tree",
    "RandomForestClassifier", "RandomForestRegressor", "BaggingClassifier",
    "GradientBoostingClassifier",
    "KNeighborsClassifier", "KNeighborsRegressor",
    "SVC", "SVR",
    "MLPClassifier", "MLPRegressor",
    # sklearn.cluster / decomposition
    "KMeans", "AgglomerativeClustering", "DBSCAN", "PCA",
    # sklearn.metrics
    "accuracy_score", "confusion_matrix", "classification_report",
    "mean_squared_error", "mean_absolute_error", "r2_score",
    "root_mean_squared_error",
    "roc_auc_score", "roc_curve", "precision_recall_curve",
    # sklearn.datasets
    "load_iris", "load_digits", "load_breast_cancer", "load_wine",
    "fetch_california_housing", "fetch_openml",
    # sklearn.inspection
    "permutation_importance",
]
