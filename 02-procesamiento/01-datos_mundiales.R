# Procesamiento de datos de COVID19 
#
# Juan M Barrios <j.m.barrios@gmail.com>
# Date: 2020/03/29
# 


# Bibliotecas ----

library(tidyverse)
library(lubridate)


# Datos mundiales ----

# Direcciones donde se encuentran los datos
CONFIRMADOS_URL <- 'https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv'
MUERTES_URL <- 'https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv'
# También se puede obtener la serie de casos recuperados pero eso no será de 
# nuestro interés. 

datos_confirmados <- read_csv(CONFIRMADOS_URL)

datos_confirmados %>% 
  View()

# Tidy data (Datos organizados)
# Cada columna debe de ser una variable

# Cambiamos la orientación de las columnas y las asignamos  a la columna 
#`Fecha`. Los valores de las columnas los ponemos en la columna `Conteo`.
# Por último hacemos que las columnas con fechas sean de tipo fecha.
datos_confirmados <- datos_confirmados %>%
  pivot_longer(-(`Province/State`:Long),
               'Fecha',
               values_to = 'Conteo') %>%
  mutate(Fecha = lubridate::mdy(Fecha))

datos_confirmados %>%
  View()

# Ojo, aquí hay un error. Por ejemplo China solo se están reportando los casos
# de la provincia donde se tuvo más casos confirmados.
datos_confirmados %>%
  group_by(`Country/Region`) %>%  
  summarise(total = max(Conteo)) %>%
  top_n(10) %>%
  arrange(desc(total))

# La correcion se hace agregando primero los casos totales por país
datos_confirmados_grp <- datos_confirmados %>%
  group_by(`Country/Region`, Fecha) %>% 
  summarise(Conteos_por_pais = sum(Conteo))


datos_confirmados_grp %>%
  summarise(Casos_totales = max(Conteos_por_pais)) %>%
  top_n(10) %>%
  arrange(desc(Casos_totales))

paises_con_mas_casos <- datos_confirmados_grp %>%
  summarise(Casos_totales = max(Conteos_por_pais)) %>%
  top_n(10) %>%
  pull(`Country/Region`)
  
paises_con_mas_casos

datos_paises_top10 <- datos_confirmados_grp %>%
  filter(`Country/Region` %in% paises_con_mas_casos)

datos_paises_top10 %>% 
  View()

# La gráfica la queremos hacer es en el eje x el tiempo y en el eje y el 
# número de casos esto por país.
ggplot(datos_paises_top10, aes(x = Fecha, 
                               y = Conteos_por_pais, 
                               colour = `Country/Region`)) + 
  geom_line() +
  scale_color_brewer(palette ="Paired") + # Paleta de colores bonita
  theme_bw() 

# Ver en que tiempo cada país rebasó los 100 casos, solo para el caso de los
# del top 10
datos_paises_top10 %>% 
  filter(Conteos_por_pais >= 100) %>%
  summarise(Primer_rebase = min(Fecha)) %>%
  arrange(Primer_rebase)

# Ejercicio: Es cierto que los paises del top 10 fueron los primero en alcanzar 
# los 100 casos o hay paises que llegaron antes a este umbral pero ya no 
# siguieron subiendo sus casos totales a la misma velocidad de los paises con
# más casos.
