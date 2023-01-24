module ItuRP839

#=
This Recommendation provides a method to predict the rain height for propagation prediction.
=#

using ItuRPropagation

version = ItuRVersion("ITU-R", "P.839", 4, "(09/2013)")

#region initialization

latsize = 121 + 1 # number of latitude points (-90, 90, 0.75) plus one extra row for interpolation
lonsize = 241 + 1 # number of longitude points (-180, 180, 0.75) plus one extra column for interpolation

latvalues = [(-90.0 + (i - 1) * 1.5) for i in 1:latsize]
lonvalues = [(-180.0 + (j - 1) * 1.5) for j in 1:lonsize]

isothermheightdata = zeros(Float64, latsize, lonsize)
read!(
    joinpath(@__DIR__, "data/isothermheighth0annual_$(string(latsize))_x_$(string(lonsize)).bin"),
    isothermheightdata
)

#endregion initialization

"""
    rainheightannual(latlon::LatLon)

Computes rain height based on the equation in Section 2.
h0 will be interpolated for the given latitude and longitude.

# Arguments
- `latlon::LatLon`: latitude and longitude (degrees)

# Return
- `hR::Real`: mean annual rain height above mean sea level
"""
function rainheightannual(latlon::LatLon)
    latrange = searchsorted(latvalues, latlon.lat)
    lonrange = searchsorted(lonvalues, latlon.lon)
    R = latrange.stop
    C = lonrange.stop

    r = ((latlon.lat + 90) / 1.5) + 1
    c = ((latlon.lon + 180) / 1.5) + 1

    h0 = (
        isothermheightdata[R, C] * ((R + 1 - r) * (C + 1 - c)) +
        isothermheightdata[R+1, C] * ((r - R) * (C + 1 - c)) +
        isothermheightdata[R, C+1] * ((R + 1 - r) * (c - C)) +
        isothermheightdata[R+1, C+1] * ((r - R) * (c - C))
    )

    hR = h0 + 0.36  # equation in section 2
end


"""
    isothermheight(latlon::LatLon)

Calculates isothermic height based on bilinear interpolation.
h0 will be interpolated for the given latitude and longitude.

# Arguments
- `latlon::LatLon`: latitude and longitude (degrees)

# Return
- `h0::Real`: mean annual 0°C isotherm height above mean sea level
"""
function isothermheight(latlon::LatLon)
    latrange = searchsorted(latvalues, latlon.lat)
    lonrange = searchsorted(lonvalues, latlon.lon)
    R = latrange.stop
    C = lonrange.stop

    r = ((latlon.lat + 90) / 1.5) + 1
    c = ((latlon.lon + 180) / 1.5) + 1

    h0 = (
        isothermheightdata[R, C] * ((R + 1 - r) * (C + 1 - c)) +
        isothermheightdata[R+1, C] * ((r - R) * (C + 1 - c)) +
        isothermheightdata[R, C+1] * ((R + 1 - r) * (c - C)) +
        isothermheightdata[R+1, C+1] * ((r - R) * (c - C))
    )
end

end # module ItuRP839
