#   ___                _ 
#  / __| __ _  _ _  __| |
# | (__ / _` || '_|/ _` |
#  \___|\__,_||_|  \__,_|
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


## INFO ______________________________________________________________
### English __________________________________________________________
CARD$P.variable_en = "CR"
CARD$P.unit_en = "without unit"
CARD$P.name_en = "Correction coefficient for precipitation"
CARD$P.description_en = ""
CARD$P.method_en = ""
CARD$P.sampling_period_en = "09-01, 08-31"
CARD$P.topic_en = "Precipitations, Moderate, Parameterization"

### French ___________________________________________________________
CARD$P.variable_fr = "CR"
CARD$P.unit_fr = "sans unité"
CARD$P.name_fr = "Coefficient correctif des précipitations"
CARD$P.description_fr = ""
CARD$P.method_fr = ""
CARD$P.sampling_period_fr = "01-09, 31-08"
CARD$P.topic_fr = "Précipitations, Modérée, Paramétrisation"

### Global ___________________________________________________________
CARD$P.input_vars = "R_obs, R_sim"
CARD$P.is_date = FALSE
CARD$P.to_normalise = FALSE
CARD$P.palette = "#452C1A #7F4A23 #B3762A #D4B86A #EFE0B0 #BCE6DB #7ACEB9 #449C93 #2A6863 #193830"


## PROCESS ___________________________________________________________
### P1 _______________________________________________________________
CARD$P1.funct = list(RA_obs=sumNA, RA_sim=sumNA)
CARD$P1.funct_args = list(list("R_obs", na.rm=TRUE), list("R_sim", na.rm=TRUE))
CARD$P1.time_step = "year"
CARD$P1.sampling_period = "09-01"
CARD$P1.NApct_lim = 3
CARD$P1.NAyear_lim = 10

### P2 _______________________________________________________________
CARD$P2.funct = list(meanRA_obs=mean, meanRA_sim=mean)
CARD$P2.funct_args = list(list("RA_obs", na.rm=TRUE), list("RA_sim", na.rm=TRUE))
CARD$P2.time_step = "none"

### P3 _______________________________________________________________
CARD$P3.funct = list(CR=divided)
CARD$P3.funct_args = list("meanRA_sim", "meanRA_obs")
CARD$P3.time_step = "none"

