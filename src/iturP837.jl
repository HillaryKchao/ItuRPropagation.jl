module ItuRP837

#=
Rainfall rate statistics with a 1-min integration time are required for the prediction of rain attenuation
 in terrestrial links (e.g. Recommendation ITU-R P.530) and Earth-space links (e.g. Recommendation ITU-R P.618).

When reliable long-term local rainfall rate data is not available, Annex 1 of this Recommendation provides
 a rainfall rate prediction method for the prediction of rainfall rate statistics with a 1-min integration time
 This prediction method is based on: a) total monthly rainfall data generated from the GPCC Climatology (V 2015) database
 over land and from the European Centre for Medium-Range Weather Forecast (ECMWF) ERA Interim re-analysis database
 over water, and b) monthly mean surface temperature data in Recommendation ITU-R P.1510.

When reliable long-term local rainfall rate data is available with integration times greater than 1-min,
 Annex 2 of this Recommendation provides a method for converting rainfall rate statistics with integration
 times that exceed 1-min to rainfall rate statistics with a 1-min integration time.
=#

using ItuRPropagations

version = ItuRVersion("ITU-R", "P.837", 7, "(06/2017)")

#region initialization

annuallatsize = 1441 + 1 # number of latitude points (-90, 90, 0.125) plus one extra row for interpolation
annuallonsize = 2881 + 1 # number of longitude points (-180, 180, 0.125) plus one extra column for interpolation

latvaluesannual = [(-90.0 + (i - 1) * 0.125) for i in 1:annuallatsize]
lonvaluesannual = [(-180.0 + (j - 1) * 0.125) for j in 1:annuallonsize]

r001data = zeros(Float64, annuallatsize, annuallonsize)
read!(
    joinpath(@__DIR__, "data/rainfallrate001annual_$(string(annuallatsize))_x_$(string(annuallonsize)).bin"),
    r001data
)

#endregion initialization

"""
    rainfallrate001(lat::Float64, lon::Float64)

Computes rainfall rate exceeded 0.01% via bi-linear interpolation as described in Annex 1.

# Arguments
- `latlon::LatLon`: latitude and longitude (degrees)

# Return
- `R::Float64`: annual rainfall rate exceeded 0.01%
"""
function rainfallrate001(latlon::LatLon)
    latrange = searchsorted(latvaluesannual, latlon.lat)
    lonrange = searchsorted(lonvaluesannual, latlon.lon)
    R = latrange.stop
    C = lonrange.stop

    δg = 0.125
    r = ((latlon.lat + 90) / δg) + 1
    c = ((latlon.lon + 180) / δg) + 1

    R = (
        r001data[R, C] * ((R + 1 - r) * (C + 1 - c)) +
        r001data[R+1, C] * ((r - R) * (C + 1 - c)) +
        r001data[R, C+1] * ((R + 1 - r) * (c - C)) +
        r001data[R+1, C+1] * ((r - R) * (c - C))
    )
end

end # module ItuRP837