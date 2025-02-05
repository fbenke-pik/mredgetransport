#' Convert GCAM road transportation data to iso country.
#'
#' @param subtype One of the possible subtypes, see default argument.
#' @return magclass object
#'
#' @examples
#' \dontrun{
#' a <- readSource("GCAM", subtype="esDemand")
#' }
#' @author Alois Dirnaichner
#' @seealso \code{\link{readSource}}
#' @importFrom madrat toolCountryFill getIsoList toolCountry2isocode
convertGCAM <- function(x, subtype) {
  GCAM2iso <- fread(system.file("extdata", "iso_GCAM.csv", package = "edgeTransport"))
  gdp <- calcOutput("GDP", aggregate = FALSE)[, getYears(x),  "gdp_SSP2"]
  getItems(x, dim = 1) <- gsub("_", " ", getItems(x, dim = 1), fixed = TRUE)
  if (subtype == "histEsDemand") {
    #extensive variables need a weight for disaggregation
    x <- toolAggregate(x, rel = GCAM2iso, weight = gdp)
    getSets(x)["d1.1"] <- "iso"
  } else if (subtype %in% c("feVkmIntensity", "loadFactor", "speedMotorized")) {
    #intensive variables do not need a weight for disaggregation
    browser()
    x <- toolAggregate(x, rel = GCAM2iso)
    getSets(x)["d1.1"] <- "iso"
  } else if (subtype == "speedNonMotorized") {
    browser()
    # data is not region specific and is applied here to all iso countries similarly
    IsoCountries <- as.data.table(getISOlist(type = "all"))
    IsoCountries[, country := "iso"]
    x <- as.data.table(x)
    x[, country := "iso"]
    x <- merge(x, IsoCountries, allow.cartesian = TRUE)
    x[, country := NULL]
    setnames(x, "IsoCountries", "iso")
    x <- as.magpie(x)
  }
  return(x)
}
