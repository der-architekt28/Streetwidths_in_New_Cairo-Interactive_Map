library(utils)
library(sf)
library(ggplot2)
library(ggtext)
library(ggiraph)
library(dplyr)
library(patchwork)
library(grid)

# Loading in the spatial dataset featuring the buildings
c_unst <- st_read("$WORKING_DIRECTORY/new_cairo_unstructured.gpkg")

# Loading in the spatial dataset featuring the distances 
d_unst <- st_read("$WORKING_DIRECTORY/voronoi_polygons_intersected.gpkg")

# Rearranging columns to delete unnecessary information and prevent misunderstanding
d_unst <- d_unst[,!names(d_unst) %in% c("distance", "deviation", "distance_2", "length_2", "area", "perimeter", "dist_cat_value")]
names(d_unst)[names(d_unst) == "length"] <- "distance"

# Grouping the voronoi polygons of the distance layer into categories based on 
# the respective distance values
d_unst <- d_unst %>% mutate(dist_category = case_when(
  distance >= 8 ~ '8-10',
  distance >= 6 ~ '6-8',
  distance >= 4 ~ '4-6',
  distance >= 2 ~ '2-4',
  TRUE ~ '0-2'
))

d_unst <- d_unst %>% mutate(dist_cat_2 = case_when(
  dist_category == '8-10' ~ '< 10 m',
  dist_category == '6-8' ~ '< 8 m',
  dist_category == '4-6' ~ '< 6 m',
  dist_category == '2-4' ~ '< 4 m',
  TRUE ~ '< 2 m'
))

# Rounding the distances for the scatterplot
d_unst <- d_unst %>% mutate(dist_rounded = round(d_unst$distance, digits = 1))

# Getting the frequency of each rounded value
d_unst <- transform(d_unst, dist_frequency=ave(seq(nrow(d_unst)), dist_rounded, FUN=length))

# Creating the scatterplot --> x: observed distances as shortes lines between two buildings, y: frequency within the whole area
scatter_plot <- ggplot(d_unst, aes(
  dist_rounded,
  dist_frequency,
  tooltip = dist_cat_2,
  data_id = dist_category,
  color = dist_category
)) +
  geom_point_interactive(data = d_unst, size=2, pch=15) +
  geom_smooth(color="white", linewidth = 0.3) +
  scale_x_continuous(breaks = seq(0, 10, by = 1)) +
  xlab("Distance [m]") +
  ylab("Frequency") +
  labs(tag="B") +
  labs(fill = expression(paste("Distance [m]"))) +
  scale_color_manual_interactive(labels = c("0-2", "2-4", "4-6", "6-8", "8-10"), 
                                 values=c('magenta2', 'slateblue', 'skyblue1', 'limegreen', 'yellow')) +
  theme_minimal() +
  theme(
    axis.title.x = element_text(color="white", size=8),
    axis.title.y = element_text(color="white", size=8),
    legend.position = "none",
    plot.margin = margin(t = 0, 
                         r = 0,  
                         b = 0,  
                         l = 0),
    plot.background = element_rect(fill = "black"),
    panel.background = element_rect(fill = "black",
                                    colour = "black",
                                    linewidth = 0.5, linetype = "solid"),
    panel.grid.major = element_line(linewidth = 0.5, linetype = 'solid',
                                    colour = "grey30"), 
    panel.grid.minor = element_line(linewidth = 0.25, linetype = 'solid',
                                    colour = "grey30")
  )

# Creating the interactive plot depicting the buildings along with the 
# distances between them
distance_plot <- ggplot() +
  geom_sf(data = c_unst, fill = "grey20", color = "white",linetype = 0) +
  geom_sf_interactive(data = d_unst, aes(fill = d_unst$dist_category, 
                                         tooltip = d_unst$dist_cat_2, 
                                         data_id = d_unst$dist_category), color = "white", linetype = 0) +
  labs(fill = expression(paste("Distance [m]"))) +
  scale_fill_manual_interactive(labels = c("0-2", "2-4", "4-6", "6-8", "8-10"), 
                                values=c('magenta2', 'cornflowerblue', 'mediumaquamarine', 'limegreen', 'yellow')) +
  ggtitle("Minimum width of street sections \n in New Cairo") +
  theme(plot.title = element_text(size = 16, color = "white", hjust = 0.5),
        legend.position = c(.02, .02),
        legend.justification = c("left", "bottom"),
        legend.box.just = "left",
        legend.margin = margin(6, 6, 6, 6),
        legend.background = element_rect(fill="black", color="grey20", linewidth=0.5),
        legend.text = element_text(size = 10, colour = "white"),
        legend.title = element_text(colour = "white", face = "bold"),
        plot.background = element_rect(fill = "black"),
        panel.background = element_rect(fill = "black",
                                        colour = "grey30",
                                        linewidth = 0.5, linetype = "solid"),
        panel.grid.major = element_line(linewidth = 0.5, linetype = 'solid',
                                        colour = "grey30"), 
        panel.grid.minor = element_line(linewidth = 0.25, linetype = 'solid',
                                        colour = "grey30"))

# Combining the two plots
combined_plot <- distance_plot + 
  inset_element(
    scatter_plot,
    left = 0.00,
    right = 0.57,
    top = 0.35,
    bottom = 0.00
  )
labelled_plot <- combined_plot +
  plot_annotation(title = "Minimum width of street sections in New Cairo",
                  theme=theme(
                    plot.title = element_textbox_simple(color = "white", size=16),
                    plot.background = element_rect(fill = "black")
                  ))

# Customizing the animations provided by ggiraph
# Editing the textboxes
tooltip_css <- "
  border-radius: 12px;
  color: #333;
  background-color: white;
  padding: 10px;
  font-size: 14px;
"
# Editing the behaviour of the interactive layer when hovered over it
hover_css <- "
  fill:red;
  cursor: pointer;
  transition: all 0.5s ease-out;
"

# Creating the interactive plot as gg-object, adding tooltip and hover options
final_plot <- girafe(ggobj = labelled_plot)
final_plot <- girafe_options(
  final_plot,
  opts_hover(css = hover_css),
  opts_tooltip(css = tooltip_css)
)

# Exporting the plot as HTML-file
htmltools::save_html(final_plot, "$WORKING_DIRECTORY/streetwidth_new_cairo_interactive_updated.html")
