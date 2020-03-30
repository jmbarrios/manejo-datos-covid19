# Procesamiento de datos de COVID19 
#
# Juan M Barrios <j.m.barrios@gmail.com>
# Date: 2020/03/29
# 


# Bibliotecas ----

library(tidyverse)
library(lubridate)


# Datos mundiales ----

CONFIRMADOS_URL <- 'https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv'
MUERTES_URL <- 'https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv'
# También se puede obtener la serie de casos recuperados pero eso no será de 
# nuestro interés. 