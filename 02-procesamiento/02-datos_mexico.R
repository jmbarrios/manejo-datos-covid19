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

# Si se visita el repositorio de los datos 
# https://github.com/guzmart/covid19_mex/tree/master/01_datos
# Nos damos cuenta que el nombre de los archivos es de la forma
# covid_mex_YYYYmmdd.xls
# por eso se hace lo siguiente.
fechas_publicacion <- seq(ymd('2020-03-16'), ymd('2020-03-30'), by='day')
file_names <- paste0('covid_mex_', stamp('20191231')(fechas_publicacion), '.xlsx')
file_names

# Descargar los datos
DATA_DIR <- '01-data'
urls <- paste0(BASE_URL, file_names)
fp <- file.path(DATA_DIR, file_names)
for (i in seq_along(urls)) {
  httr::GET(urls[i], httr::write_disk(fp[i], overwrite = TRUE))
}


# Como los archivos son acumulativos solo usaremos el útlimo
nombre_ultimo_archivo <- fp %>% tail(1)
nombre_ultimo_archivo

data_mexico <- read_xlsx(nombre_ultimo_archivo, 
  col_types = c( # col_types lo usamos para asegurarnos del tipo de dato
    'numeric',
    'text',
    'text',
    'numeric',
    'date',
    'text',
    'text',
    'date',
    'date',
    'logical',
    'date',
    'logical',
    'date'))
data_mexico %>% View()

# Datos para la gráfica que presentan diariamente
datos_conferencia <- data_mexico %>%
  group_by(fecha_corte) %>%
  summarise(casos_nuevos_por_corte = sum(n())) %>%
  mutate(casos_acumulados = cumsum(casos_nuevos_por_corte))

ggplot(datos_conferencia, aes(x = fecha_corte, y = casos_acumulados)) +
  geom_line() +
  geom_point() +
  theme_bw()

# De donde vienen los casos de Mexico por fecha
origen <- data_mexico %>%
  mutate(procedencia = fct_infreq(procedencia)) # Esto ordena los factores en orden por freq

ggplot(origen) +
  geom_bar(aes(x = procedencia)) +
  coord_flip()

# Ver la evolución temporal de la procedencia de los casos
origen <- data_mexico %>%
  group_by(fecha_corte, procedencia) %>%
  summarise(casos_nuevos_x_pais = n()) %>%
  group_by(procedencia) %>%
  mutate(acumulados_x_pais = cumsum(casos_nuevos_x_pais))

ggplot(origen, aes(x = fecha_corte, 
                   y = acumulados_x_pais, 
                   colour = procedencia)) + 
  geom_point() + 
  geom_line() +
  scale_color_brewer(palette ="Paired") +
  theme_bw() 

# Que pasa con este tweet
# https://twitter.com/meithan42/status/1244462990251954179?s=20
# Vamos a recrearla
datos_raros <- data_mexico %>%
  group_by(fecha_inicio) %>%
  summarise(casos_x_inicio = n()) %>%
  mutate(casos_acumulados = cumsum(casos_x_inicio))

ggplot(datos_raros, aes(x = fecha_inicio, y = casos_acumulados)) +
  geom_line() +
  geom_point() +
  theme_bw()

# Wow, ¿qué paso aquí?
data_confirmacion <- data_mexico %>%
  mutate(lag = fecha_corte - fecha_inicio)

ggplot(data_confirmacion) +
  geom_bar(aes(x = lag))

# Ejercicio: Puedes explicar con esta grafica porque se ve el efecto
# de un crecimiento no muy "exponencial".