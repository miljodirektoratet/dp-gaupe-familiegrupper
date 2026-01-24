# Example plots for Norway
# Inspired by: https://danielroelfs.com/posts/the-easier-way-to-create-a-map-of-norway-using-csmaps/ # nolint: line_length_linter.

# --- Suppress R CMD check warnings ---
# Declare global variables to avoid R CMD check warnings
if (getRversion() >= "2.15.1") {
  utils::globalVariables(c(
    "Item", "Title", "location_code", "location_name",
    "long", "lat", "group", "legend_category",
    "no_county_geodata_2024", "no_county_names_2024"
  ))
}

# Load mapproj to avoid R CMD check note (mapproj is used by ggplot2::coord_map())
.check_mapproj <- function() {
  mapproj::mapproject
}

# --- Functions ---

#' Function | generate_county_colors
#' @description Generate color palette for Norway counties
#' @param names_df Data frame with county names
#' @param palette_name Name of the scico palette (default: "batlow")
#' @return Named vector of colors for each county
generate_county_colors <- function(names_df, palette_name = "batlow") {
  county_colors <- stats::setNames(
    scico::scico(
      n = nrow(names_df),
      palette = palette_name
    ),
    nm = names_df$location_name
  )
  return(county_colors)
}

#' Function | plot_norway_counties
#' @description Create Norway county map with customizable styling
#' @param map_df Data frame with map data (default: no_county_geodata_2024)
#' @param names_df Data frame with county names (default: no_county_names_202
#' @param palette_name Name of the scico palette (default: "batlow")
#' @param legend_position Position of the legend (default: c(0.9, 0.2))
#' @return ggplot object of the Norway county map
plot_norway_counties <- function(
    map_df = no_county_geodata_2024,
    names_df = no_county_names_2024,
    palette_name = "batlow",
    legend_position = c(0.9, 0.2)) {
  # Prepare palette
  county_colors <- generate_county_colors(names_df, palette_name)

  # Create the map
  map_plot <- map_df |>
    dplyr::left_join(names_df, by = "location_code") |>
    ggplot2::ggplot(ggplot2::aes(
      x = long, y = lat,
      fill = location_name, group = group
    )) +
    ggplot2::geom_polygon(key_glyph = "point") +
    ggplot2::labs(
      x = NULL,
      y = NULL,
      fill = NULL
    ) +
    ggplot2::scale_x_continuous(
      labels = scales::label_number(suffix = "\u00b0W")
    ) +
    ggplot2::scale_y_continuous(
      labels = scales::label_number(suffix = "\u00b0N")
    ) +
    ggplot2::scale_fill_manual(
      values = county_colors,
      guide = ggplot2::guide_legend(override.aes = list(shape = 21, size = 4))
    ) +
    ggplot2::coord_map(projection = "conic", lat0 = 40) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      legend.position.inside = legend_position,
      legend.text = ggplot2::element_text(size = 5),
      legend.key.height = grid::unit(10, "pt"),
      legend.background = ggplot2::element_rect(
        fill = "white",
        color = "transparent"
      )
    )
  return(map_plot)
}

#' Function | plot_trondelag
#' @description Create Norway county map highlighting Trondelag
#' @param geodata_df Data frame with map data (default: no_county_geodata_2024)
#' @param names_df Data frame with county names (default: no_county_names_2024)
#' @param trondelag_color Color for Trondelag (default: Sjogronn "#005E5D")
#' @param other_color Color for other counties (default: Beige Lys "#FCFAF6")
#' @param legend_position Position of the legend (default: c(0.9, 0.2))
#' @return ggplot object of the Norway county map with Trondelag highlighted
#' @export
plot_trondelag <- function(
    geodata_df = no_county_geodata_2024,
    names_df = no_county_names_2024,
    trondelag_color = "#005E5D",
    other_color = "#FCFAF6",
    legend_position = c(0.7, 0.1)) {
  # Prepare data
  map_df <- geodata_df |>
    dplyr::left_join(
      names_df,
      by = "location_code"
    ) |>
    dplyr::mutate(
      legend_category = factor(
        ifelse(grepl(
          "Tr\u00f8ndelag",
          location_name,
          ignore.case = TRUE
        ) & !is.na(location_name),
        "Tr\u00f8ndelag", "Other"
        ),
        levels = c("Tr\u00f8ndelag", "Other")
      )
    )

  # Create plot
  map_df |>
    ggplot2::ggplot(ggplot2::aes(
      x = long, y = lat, fill = legend_category,
      color = legend_category, group = group
    )) +
    ggplot2::geom_polygon(key_glyph = "point", linewidth = 0.2) +
    ggplot2::labs(x = NULL, y = NULL, fill = NULL) +
    ggplot2::scale_x_continuous(
      labels = scales::label_number(suffix = "\u00b0E")
    ) +
    ggplot2::scale_y_continuous(
      labels = scales::label_number(suffix = "\u00b0N")
    ) +
    ggplot2::scale_fill_manual(
      values = c("Tr\u00f8ndelag" = trondelag_color, "Other" = other_color),
      breaks = "Tr\u00f8ndelag", na.value = other_color,
      guide = ggplot2::guide_legend(override.aes = list(shape = 21, size = 4))
    ) +
    ggplot2::scale_color_manual(
      values = c("Tr\u00f8ndelag" = trondelag_color, "Other" = "#D6D2C4"),
      guide = "none"
    ) +
    ggplot2::coord_map(projection = "conic", lat0 = 60) +
    ggplot2::theme_minimal(base_family = "Open Sans") +
    ggplot2::theme(
      legend.position.inside = legend_position,
      legend.text = ggplot2::element_text(
        size = 7,
        family = "Open Sans",
        color = "white"
      ),
      legend.key.height = grid::unit(12, "pt"),
      legend.background = ggplot2::element_rect(
        fill = "transparent",
        color = "transparent"
      ),
      axis.text = ggplot2::element_text(
        family = "Open Sans",
        color = "white",
        size = 6
      ),
      text = ggplot2::element_text(family = "Open Sans", color = "white"),
      plot.background = ggplot2::element_rect(fill = "transparent", color = NA),
      panel.background = ggplot2::element_rect(fill = "transparent", color = NA)
    )
}

# -----------------
