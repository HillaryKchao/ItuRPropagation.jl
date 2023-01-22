module ItuRP2145

#=
This Recommendation provides methods to predict the surface total (barometric) pressure, surface
temperature, surface water vapour density and integrated water vapour content required for the calculation of
gaseous attenuation and related effects on terrestrial and Earth-space paths.
=#

using ItuRPropagations

version = ItuRVersion("ITU-R", "P.2145", 0, "(08/2022)")

#region initialization

latsize = 721 + 1 # number of latitude points (-90, 90, 0.25) plus one extra row for interpolation
lonsize = 1441 + 1 # number of longitude points (-180, 180, 0.25) plus one extra column for interpolation

# exceedance probability, section 1 of ITU-R P.836-6
psannual = [0.01, 0.02, 0.03, 0.05, 0.1, 0.2, 0.3, 0.5, 1, 2, 3, 5, 10, 20, 30, 50, 60, 70, 80, 90, 95, 99]
npsannual = length(psannual)

# exceedance probability values for reading files
filespsannual = ["001", "002", "003", "005", "01", "02", "03", "05", "1", "2", "3", "5", "10", "20", "30", "50", "60", "70", "80", "90", "95", "99"]

latvalues = [(-90.0 + (i - 1) * 0.25) for i in 1:latsize]
lonvalues = [(-180.0 + (j - 1) * 0.25) for j in 1:lonsize]

surfacetemperatureannualdata = zeros(Float64, (npsannual, latsize, lonsize))
surfacerhodata = zeros(Float64, (npsannual, latsize, lonsize))
for nps in range(1, npsannual)
    tempdata = zeros(Float64, (latsize, lonsize))
    rhodata = zeros(Float64, (latsize, lonsize))
    read!(
        joinpath(@__DIR__, "data/surfacetemperatureannual_$(string(latsize))_x_$(string(lonsize))_x_$(filespsannual[nps]).bin"),
        tempdata
    )
    read!(
        joinpath(@__DIR__, "data/surfacewatervapordensityannual_$(string(latsize))_x_$(string(lonsize))_x_$(filespsannual[nps]).bin"),
        rhodata
    )
    for lat in 1:latsize
        for lon in 1:lonsize
            surfacetemperatureannualdata[nps, lat, lon] = tempdata[lat, lon]
            surfacerhodata[nps, lat, lon] = rhodata[lat, lon]
        end
    end
    tempdata = 0
    rhodata = 0
end

scaleheightrhodata = zeros(Float64, (latsize, lonsize))
read!(
    joinpath(@__DIR__, "data/scaleheightwatervapordensityannual_$(string(latsize))_x_$(string(lonsize)).bin"),
    scaleheightrhodata
)

surfaceheightdata = zeros(Float64, (latsize, lonsize))
read!(
    joinpath(@__DIR__, "data/surfaceheightannual_$(string(latsize))_x_$(string(lonsize)).bin"),
    surfaceheightdata
)

#endregion initialization

"""
    surfacetemperatureannual(latlon::LatLon, p::Real, hs::Union{Missing, Real} = missing)

Computes annual surface temperature for a given exceedance probability and altitude based on Section 2.1.

# Arguments
- `latlon::LatLon`: latitude and longitude (degrees)
- `p::Real`: exceedance probability (%)
- `hs::Union{Missing, Real}`: altitude (m), defaults to missing

# Return
- `T::Real`: annual surface temperature (°K)
"""
function surfacetemperatureannual(
    latlon::LatLon,
    p::Real,
)
    prange = searchsorted(psannual, p)
    pindexbelow = prange.stop
    pindexabove = prange.start
    pexact = pindexbelow == pindexabove ? true : false

    latrange = searchsorted(latvalues, latlon.lat)
    lonrange = searchsorted(lonvalues, latlon.lon)
    R = latrange.stop
    C = lonrange.stop

    δg = 0.25
    r = ((90.0 + latlon.lat) / δg) + 1
    c = ((180.0 + latlon.lon) / δg) + 1

    T00a = surfacetemperatureannualdata[pindexabove, R, C]
    T01a = surfacetemperatureannualdata[pindexabove, R, C+1]
    T10a = surfacetemperatureannualdata[pindexabove, R+1, C]
    T11a = surfacetemperatureannualdata[pindexabove, R+1, C+1]

    T00b = surfacetemperatureannualdata[pindexbelow, R, C]
    T01b = surfacetemperatureannualdata[pindexbelow, R, C+1]
    T10b = surfacetemperatureannualdata[pindexbelow, R+1, C]
    T11b = surfacetemperatureannualdata[pindexbelow, R+1, C+1]

    Tabove = (
        T00a * ((R + 1 - r) * (C + 1 - c)) +
        T10a * ((r - R) * (C + 1 - c)) +
        T01a * ((R + 1 - r) * (c - C)) +
        T11a * ((r - R) * (c - C))
    )

    if pexact == true
        return Tabove
    else
        Tbelow = (
            T00b * ((R + 1 - r) * (C + 1 - c)) +
            T10b * ((r - R) * (C + 1 - c)) +
            T01b * ((R + 1 - r) * (c - C)) +
            T11b * ((r - R) * (c - C))
        )
        pslogabove = log(psannual[pindexabove])
        pslogbelow = log(psannual[pindexbelow])
        T = (Tabove - Tbelow) / (pslogabove - pslogbelow) * (log(p) - pslogbelow) + Tbelow
        return T
    end
end


"""
    surfacewatervapordensityannual(latlon::LatLon, p::Real, hs::Union{Missing, Real} = missing)

Computes annual surface water vapor density for a given exceedance probability and altitude based on Section 2.1.

# Arguments
- `latlon::LatLon`: latitude and longitude (degrees)
- `p::Real`: exceedance probability (%)
- `hs::Union{Missing, Real}`: altitude (m), defaults to missing

# Return
- `ρ::Real`: annual surface water vapor density (g/m^3)
"""
function surfacewatervapordensityannual(
    latlon::LatLon,
    p::Real,
    hs::Union{Missing,Real}=missing
)
    prange = searchsorted(psannual, p)
    pindexbelow = prange.stop
    pindexabove = prange.start
    pexact = pindexbelow == pindexabove ? true : false

    latrange = searchsorted(latvalues, latlon.lat)
    lonrange = searchsorted(lonvalues, latlon.lon)
    R = latrange.stop
    C = lonrange.stop

    δg = 0.25
    r = ((90.0 + latlon.lat) / δg) + 1
    c = ((180.0 + latlon.lon) / δg) + 1

    if hs === missing
        hs = ItuRP1511.topographicheight(latlon)
    end

    h00 = surfaceheightdata[R, C]
    h01 = surfaceheightdata[R, C + 1]
    h10 = surfaceheightdata[R + 1, C]
    h11 = surfaceheightdata[R + 1, C + 1]

    ρ′00a = surfacerhodata[pindexabove, R, C]
    ρ′01a = surfacerhodata[pindexabove, R, C+1]
    ρ′10a = surfacerhodata[pindexabove, R+1, C]
    ρ′11a = surfacerhodata[pindexabove, R+1, C+1]

    ρ′00b = surfacerhodata[pindexbelow, R, C]
    ρ′01b = surfacerhodata[pindexbelow, R, C+1]
    ρ′10b = surfacerhodata[pindexbelow, R+1, C]
    ρ′11b = surfacerhodata[pindexbelow, R+1, C+1]

    ρ00a = ρ′00a * exp((h00 - hs) / scaleheightrhodata[R, C])
    ρ01a = ρ′01a * exp((h01 - hs) / scaleheightrhodata[R, C+1])
    ρ10a = ρ′10a * exp((h10 - hs) / scaleheightrhodata[R+1, C])
    ρ11a = ρ′11a * exp((h11 - hs) / scaleheightrhodata[R+1, C+1])

    ρ00b = ρ′00b * exp((h00 - hs) / scaleheightrhodata[R, C])
    ρ01b = ρ′01b * exp((h01 - hs) / scaleheightrhodata[R, C+1])
    ρ10b = ρ′10b * exp((h10 - hs) / scaleheightrhodata[R+1, C])
    ρ11b = ρ′11b * exp((h11 - hs) / scaleheightrhodata[R+1, C+1])

    ρabove = (
        ρ00a * ((R + 1 - r) * (C + 1 - c)) +
        ρ10a * ((r - R) * (C + 1 - c)) +
        ρ01a * ((R + 1 - r) * (c - C)) +
        ρ11a * ((r - R) * (c - C))
    )

    if pexact == true
        return ρabove
    else
        ρbelow = (
            ρ00b * ((R + 1 - r) * (C + 1 - c)) +
            ρ10b * ((r - R) * (C + 1 - c)) +
            ρ01b * ((R + 1 - r) * (c - C)) +
            ρ11b * ((r - R) * (c - C))
        )
        pslogabove = log(psannual[pindexabove])
        pslogbelow = log(psannual[pindexbelow])
        ρ = (ρabove - ρbelow) / (pslogabove - pslogbelow) * (log(p) - pslogbelow) + ρbelow
        return ρ
    end
end

end # module ItuRP2145