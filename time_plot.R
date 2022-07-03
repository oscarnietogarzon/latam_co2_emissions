

time_plot_co2 <- function (argument) {
  
library(tidyverse)
library(plotly)

df <- read.csv('https://raw.githubusercontent.com/owid/co2-data/master/owid-co2-data.csv')
lac_countries <- c("Belize", "Costa Rica", "El Salvador", "Guatemala", "Honduras", "Mexico", "Nicaragua", "Panama", "Argentina", "Bolivia", "Brazil", "Chile", "Colombia", "Ecuador",
                   "Guyana", "Paraguay", "Peru", "Suriname", "Uruguay", "Venezuela", "Cuba", "Dominican Republic",
                   "Haiti", "Puerto Rico")

df %>% filter(year > 1990, country %in% lac_countries) %>%
  select(c("iso_code", "country", "year", "co2", "co2_per_capita")) -> df_lac30

df_lac30 %>% group_by(country) %>% summarize(tot_co2 = sum(co2)) %>%
  arrange(desc(tot_co2)) %>% dplyr::pull(country) -> country

top <-  country[1:5]

df_lac30 %>% filter(country %in% top) %>%
  ggplot( aes(x=year, y=co2, color=country)) +
  geom_line(size = 0.7) + 
  scale_color_brewer(palette = "Set2") +
  labs(x="", y="Millon Tonnes", title= bquote('Annual'~CO[2]~'Emissions' ) ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust=0.5, size=20, face="bold")) -> p

plotly::ggplotly(p) 

}


time_plot_co2()
