# Procesamiento de datos de COVID19 
#
# Juan M Barrios <j.m.barrios@gmail.com>
# Date: 2020/03/29
# 


# Bibliotecas ----

library(tidyverse)
library(httr)
library(lubridate)
library(readxl)

BASE_URL <- 'https://github.com/guzmart/covid19_mex/raw/master/01_datos/'
fechas_publicacion <- seq(ymd('2020-03-16'), ymd('2020-03-29'), by='day')
file_names <- paste0('covid_mex_', stamp('20191231')(fechas_publicacion), '.xlsx')
file_names
