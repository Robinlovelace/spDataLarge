#' Datasets providing a snapshot of Bristol's transport system
#'
#' Data used in the transport chapter in Geocomputation with R.
#' See \url{http://geocompr.robinlovelace.net/transport.html} for details.
#'
#' @format sf data frame objects
#'
#' @source \url{http://wicid.ukdataservice.ac.uk/} and other open access sources
#' @aliases bristol_od bristol_region bristol_cents bristol_ttwa bristol_zones bristol_stations desire_carshort route_carshort route_rail
#' @examples \dontrun{
#' devtools::install_github("ropensci/osmdata")
#' devtools::install_github("robinlovelace/ukboundaries")
#' library(osmdata)
#' library(sf)
#' library(tidyverse)
#' library(ukboundaries)
#' bristol_region = getbb("Bristol", format_out = "sf_polygon") %>%
#'         st_set_crs(4326) %>%
#'         st_sf(data.frame(Name = "Bristol (OSM)"), geometry = region$geometry)
#' mapview::mapview(bristol_region)
#' devtools::use_data(bristol_region)
#' bristol_ttwa = ttwa_simple %>%
#'         filter(ttwa11nm == "Bristol") %>%
#'         select(Name = ttwa11nm)
#' bristol_ttwa$Name = "Bristol (TTWA)"
#' mapview::mapview(bristol_ttwa)
#' devtools::use_data(bristol_ttwa)
#' bristol_cents = st_centroid(msoa2011_vsimple)[bristol_ttwa, ]
#' plot(bristol_cents$geometry)
#' bristol_zones = msoa2011_vsimple[msoa2011_vsimple$msoa11cd %in% bristol_cents$msoa11cd, ] %>%
#'         select(geo_code = msoa11cd, name = msoa11nm) %>%
#'         mutate_at(1:2, as.character)
#' plot(bristol_zones$geometry, add = TRUE)
#' # Add travel data to the zones
#' # using wicid open data - see http://wicid.ukdataservice.ac.uk/
#' unzip("~/Downloads/wu03ew_v2.zip")
#' od_all = read_csv("wu03ew_v2.csv")
#' file.remove("wu03ew_v2.csv", "julyukrelease_tcm77-369384.xls")
#' bristol_od = od_all %>%
#'        select(o = `Area of residence`, d = `Area of workplace`,
#'               all = `All categories: Method of travel to work`,
#'               bicycle = Bicycle, foot = `On foot`,
#'               car_driver = `Driving a car or van`, train = Train) %>%
#'        filter(o %in% bristol_zones$geo_code & d %in% bristol_zones$geo_code, all > 19)
#' summary(bristol_zones$geo_code %in% bristol_od$d)
#' summary(bristol_zones$geo_code %in% bristol_od$o)
#' devtools::use_data(bristol_zones)
#' devtools::use_data(bristol_od)
#' od_intra = filter(bristol_od, o == d)
#' od_inter = filter(bristol_od, o != d)
#' desire_lines = od2line(od_inter, zones)
#' desire_lines$distance = as.numeric(st_length(desire_lines))
#' desire_carshort = dplyr::filter(desire_lines, car_driver > 300 & distance < 5000)
#' route_carshort = stplanr::line2route(desire_carshort, route_fun = route_osrm)
#' bb = st_bbox(bristol_ttwa)
#' ways_road = opq(bbox = bb) %>%
#'         add_osm_feature(key = "highway",
#'                         value = "motorway|cycle|primary|secondary",
#'                         value_exact = FALSE) %>%
#'         osmdata_sf()
#' ways_rail = opq(bbox = bb) %>%
#'         add_osm_feature(key = "railway", value = "rail") %>%
#'         osmdata_sf()
#' res = c(ways_road, ways_rail)
#' summary(res)
#' bristol_stations = res$osm_points %>%
#'         filter(railway == "station" | name == "Bristol Temple Meads")
#' # most important vars:
#' map_int(bristol_stations, ~ sum(is.na(.))) %>%
#'         sort() %>%
#'         head()
#' bristol_stations = bristol_stations %>% select(name)
#' devtools::use_data(bristol_stations)
#' ways = st_intersection(res$osm_lines, bristol_ttwa)
#' ways$highway = as.character(ways$highway)
#' ways$highway[ways$railway == "rail"] = "rail"
#' ways$highway = gsub("_link", "", x = ways$highway) %>%
#'         gsub("motorway|primary|secondary", "road", x = .) %>%
#'         as.factor()
#' ways = ways %>%
#'         select(highway, maxspeed, ref)
#' summary(st_geometry_type(ways))
#' # convert to linestring
#' bristol_ways = st_cast(ways, "LINESTRING")
#' summary(st_geometry(bristol_ways))
#' devtools::use_data(bristol_ways)
#' }
"bristol_ways"


