# Copyright 2022-2025 Louis, Héraut <louis.heraut@inrae.fr>*1
#
# *1 INRAE, UR RiverLy, Villeurbanne, France
#
# This file is part of CARD R package.
#
# CARD R package is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# CARD R package is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with CARD R package.
# If not, see <https://www.gnu.org/licenses/>.


#  ___                        _            
# | _ \ ___  __  ___  ___ ___(_) ___  _ _  
# |   // -_)/ _|/ -_)(_-<(_-<| |/ _ \| ' \ 
# |_|_\\___|\__|\___|/__//__/|_|\___/|_||_| __________________________
#' @title Detect Inflection Points in a Time Series
#' @description Identifies local minima and maxima in a numeric vector using a sliding window of a given threshold. Used to detect changes in trend in smoothed hydrological data.
#' @param x Numeric vector (e.g., smoothed discharge time series).
#' @param threshold Integer. Number of neighbors on each side to consider for identifying a local extremum.
#' @return A list with two integer vectors: `minima` (indices of local minima) and `maxima` (indices of local maxima).
#' @export
#' @md
inflect = function(x, threshold=1) {
    up = sapply(1:threshold, function (n) c(x[-(seq(n))], rep(NA, n)))
    down =  sapply(-1:-threshold, function (n) c(rep(NA, abs(n)), x[-seq(length(x), length(x) - abs(n) + 1)]))
    a = cbind(x, up, down)
    res = list(minima = which(apply(a, 1, min) == a[, 1]), maxima = which(apply(a, 1, max) == a[, 1]))
    return (res)
}

#' @title Compute Characteristic Recovery Times from Flow Time Series
#' @description Applies smoothing and inflection point detection to estimate recovery durations (Tau) between hydrological peaks and valleys in a discharge time series.
#' @param Q Numeric vector of discharge values.
#' @return A numeric vector of recovery times (Tau) between peak and valley periods, filtered by quantile thresholds.
#' @export
#' @md
compute_dtRec = function (Q) {
    # 'V2114010_HYDRO_QJM.txt'
    # cut gap for data = data[10000:11000,]
    X = 1:length(Q)
    OK = !is.na(Q) & Q > 0

    if (all(!OK)) {
        return (NA)
    }
    
    X = X[OK]
    Q = Q[OK]
    
    ss = smooth.spline(X,
                       Q,
                       df=10,
                       spar=0.5,
                       nknots=length(X)/1.5,
                       w=1/sqrt(Q/max(Q)))

    ssX = as.Date(ss$x, origin=as.Date("1970-01-01"))
    ssY = ss$y

    OK = ssY > 0
    ssX = ssX[OK]
    ssY = ssY[OK]

    res = inflect(ssY, 10)
    peak = res$maxima
    valley = res$minima
    nPeak = length(peak)
    nValley = length(valley)
    nMax = max(nPeak, nValley)
    peak = c(peak, rep(NA, times=nMax-nPeak))
    valley = c(valley, rep(NA, times=nMax-nValley))

    names(valley) = rep("v", length(valley))
    names(peak) = rep("p", length(peak))
    all = sort(c(peak, valley))
    id = cumsum(rle(names(all))$lengths)
    all = all[id]

    peak = all[names(all) == "p"]
    valley = all[names(all) == "v"]

    names(peak) = NULL
    names(valley) = NULL
    
    if (length(valley) == 0 |
        length(peak) == 0) {
        return (NA)
    }

    if (valley[1] < peak[1]) {
        valley = valley[-1]
    }

    if (length(valley) == 0 |
        length(peak) == 0) {
        return (NA)
    }
    
    if (valley[length(valley)] < peak[length(peak)]) {
        peak = peak[-length(peak)]
    }

    pSsY = 0.75
    ssYlim = quantile(ssY, pSsY, na.rm=TRUE)
    OK = !(ssY[peak] < ssYlim & ssY[valley] < ssYlim)
    peak = peak[OK]
    valley = valley[OK]

    cut = function (peak, valley, X) {
        return (X[peak:valley])
    }

    add = function (X, n) {
        return (c(X, rep(NULL, n-length(X))))
    }
    
    if (length(peak) == 0 | length(valley) == 0 | is.null(ssX) | is.null(logb(ssY))) {
        return (NA)
    }
    
    ABS = mapply(cut, peak, valley, list(X=ssX))
    ORD = mapply(cut, peak, valley, list(X=logb(ssY)))

    fit = function (X, Y) {
        res = lm(Y~X)$coefficients
        res = c(alpha=res[[2]], beta=res[[1]])
        return (res)
    }

    Coef = mapply(fit, ABS, ORD, SIMPLIFY=FALSE)
    Alpha = sapply(Coef, '[[', "alpha")
    Beta = sapply(Coef, '[[', "beta")
    Tau = -1/Alpha

    pTau = 0.9
    OK = Tau > 0 & Tau < quantile(Tau, pTau, na.rm=TRUE)
    peak = peak[OK]
    valley = valley[OK]
    ABS = ABS[OK]
    ORD = ORD[OK]
    Alpha = Alpha[OK]
    Beta = Beta[OK]
    Tau = Tau[OK]

    # medianTau = median(Tau, na.rm=TRUE)
    
    return (Tau)
}


#' @title Compute Median Recovery Time
#' @description Calculates the median of recovery times (Tau) estimated by `compute_dtRec`, optionally removing `NA` values.
#' @param Q Numeric vector of discharge values.
#' @param na.rm Logical indicating whether to remove `NA` values before computing the median.
#' @return A single numeric value representing the median recovery time.
#' @export
#' @md
compute_median_dtRec = function (Q, na.rm=TRUE) {
    dtRec = compute_dtRec(Q)
    meddtRec = median(dtRec, na.rm=na.rm)
    return (meddtRec)
}


# compute_dtRec_yday = function (Qyday) {
# }
