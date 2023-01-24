module ItuRP453

#=
Recommendation ITU-R P.453 provides methods to estimate the radio refractive index 
 and its behaviour for locations worldwide; describes both surface and vertical profile
 characteristics; and provides global maps for the distribution of refractivity
 parameters and their statistical variation.
=#

using ItuRPropagation

version = ItuRVersion("ITU-R", "P.453", 14, "(08/2019)")

#region initialization

latsize = 241 + 1 # number of latitude points (-90, 90, 0.75) plus one extra row for interpolation
lonsize = 481 + 1 # number of longitude points (-180, 180, 0.75) plus one extra column for interpolation

latvalues = [(-90.0 + (i - 1) * 0.75) for i in 1:latsize]
lonvalues = [(-180.0 + (j - 1) * 0.75) for j in 1:lonsize]

wettermdata_50 = zeros(Float64, (latsize, lonsize))
read!(
    joinpath(@__DIR__, "data/wettermsurfacerefractivityannual_50_$(string(latsize))_x_$(string(lonsize)).bin"),
    wettermdata_50
)

#endregion initialization

#region internal functions

"""
    _saturationvaporpressure(t::Real, P::Real, ::Val{EnumWater})

Compute the saturation water vapor pressure for water-type hydrometer based on Section 1.

# Arguments
- `T::Real`: temperature in (°C)
- `P::Real`: total atmospheric pressure (hPa)
- `::Val{EnumWater}`: water-type hydrometer

# Return
- `eₛ::Real`: saturation water vapor pressure (hPa)
"""
function _saturationwatervaporpressure(T::Real, P::Real, ::Val{EnumWater})
    (T < -40 || T > 50) && throw(ArgumentError("T=$T\nT (temperature in deg C) in ItuRP453.saturationvaporpressure must be between -80 and 0."))
    EF = 1 + 1e-4 * (7.2 + P * (0.0320 + 5.9e-6 * T * T))
    a, b, c, d = 6.1121, 18.678, 257.14, 234.5
    eₛ = EF * a * exp((b - T / d) * T / (T + c))     # equation 9
end


"""
    _saturationvaporpressure(t::Real, P::Real, ::Val{EnumIce})

Compute the saturation water vapor pressure for ice-type hydrometer based on Section 1.

# Arguments
- `T::Real`: temperature (°C)
- `P::Real`: total atmospheric pressure (hPa)
- `::Val{EnumIce}`: ice-type hydrometer

# Return
- `eₛ::Real`: saturation water vapor pressure (hPa)
"""
function _saturationwatervaporpressure(T::Real, P::Real, ::Val{EnumIce})
    (T < -80 || T > 0) && throw(ArgumentError("T=$T\nT (temperature in deg C) in ItuRP453.saturationvaporpressure must be between -80 and 0."))
    EF = 1 + 1e-4 * (2.2 + P * (0.0383 + 6.4e-6 * T * T))
    a, b, c, d = 6.1115, 23.036, 279.82, 333.7
    eₛ = EF * a * exp((b - T / d) * T / (T + c))     # equation 9
end

#endregion internal functions

"""
    radiorefractiveindex(Pd::Real, T::Real, e::Real)

Compute the atmospheric radio refractive index \$\\sqrt[n]{1 + x + x^2 + \\ldots}\$ based on Section 1.

# Arguments
- `T::Real`: absolute temperature (°K)
- `Pd::Real`: dry atmospheric pressure (hPa)
- `eₛ::Real`: saturation water vapor pressure (hPa)

# Return
- `n::Real`: atmospheric radio refractive index
"""
function radiorefractiveindex(
    T::Real, 
    Pd::Real, 
    eₛ::Real
)
    N = 77.6 * (Pd / T) + 72 * (eₛ / T) + 3.75e5 * (eₛ / (T * T))     # equation 2
    n = 1 + N * (1e-6)     # equation 1
end


"""
    drytermradiorefractivity(Pd::Real, T::Real)

Compute the dry term of the radio refractivity based on Section 1.

# Arguments
- `T::Real`: absolute temperature (°K)
- `Pd::Real`: dry atmospheric pressure (hPa)

# Return
- `Ndry::Real`: dry term of the radio refractivity
"""
function drytermradiorefractivity(
    T::Real, 
    Pd::Real
)
    Ndry = 77.6 * (Pd / T)     # equation 3
end


"""
    wettermradiorefractivity(Pd::Real, T::Real)

Compute the wet term of the radio refractivity based on Section 1.

# Arguments
- `T::Real`: absolute temperature (°K)
- `eₛ:Real`: saturation water vapor pressure (hPa)

# Return
- `Nwet::Real`: wet term of the radio refractivity
"""
function wettermradiorefractivity(
    T::Real, 
    eₛ::Real
)
    Nwet = 72 * (eₛ / T) + 3.75e5 * (eₛ / (T * T))     # equation 4
end


"""
    vaporpressure(T::Real, P::Real, H::Real, hydrometer::IturEnum)

Computes the vapor pressure dependent on hydrometer type based on Section 1.

# Arguments
- `T::Real`: temperature in (°C)
- `P::Real`: total atmospheric pressure (hPa)
- `H::Real`: relative humidity (%)
- `hydrometer::IturEnum"`: type of hydrometer, either water or ice

# Return
- `e::Real`: water vapor pressure (hPa)
"""
function vaporpressure(
    T::Real, 
    P::Real, 
    H::Real,
    hydrometer::IturEnum
)
    if hydrometer == EnumIce
        eₛ = _saturationwatervaporpressure(T, P, EnumIce)
    elseif hydrometer == EnumWater
        eₛ = _saturationwatervaporpressure(T, P, EnumWater)
    else
        throw(ArgumentError("Invalid hydrometer value in ItuRP453.vaporpressure."))
    end
    e = H * eₛ / 100.0     # equation 8
end


"""
    wettermsurfacerefractivityannual_50(latlon::LatLon)

Interpolates wet term of the surface refractivity at an exceedance probability of 50% based on Section 2.2.

# Arguments
- `latlon::LatLon`: latitude and longitude (degrees)

# Return
- `Nwet::Real`: wet term of the surface refractivity (ppm)
"""
function wettermsurfacerefractivityannual_50(latlon::LatLon)
    latrange = searchsorted(latvalues, latlon.lat)
    lonrange = searchsorted(lonvalues, latlon.lon)
    R = latrange.stop
    C = lonrange.stop

    δg = 0.75
    r = ((latlon.lat + 90) / δg) + 1
    c = ((latlon.lon + 180) / δg) + 1

    Nwet = (
        wettermdata_50[R, C] * ((R + 1 - r) * (C + 1 - c)) +
        wettermdata_50[R+1, C] * ((r - R) * (C + 1 - c)) +
        wettermdata_50[R, C+1] * ((R + 1 - r) * (c - C)) +
        wettermdata_50[R+1, C+1] * ((r - R) * (c - C))
    )
end

end # module ItuRP453
