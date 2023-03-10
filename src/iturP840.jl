module ItuRP840

#=
This Recommendation provides methods to predict the attenuation due to clouds and fog on Earth-space paths.
=#

using ItuRPropagation

version = ItuRVersion("ITU-R", "P.840", 8, "(08/2019)")

#region initialization

latsize = 161 + 1 # number of latitude points (-90, 90, 1.125) plus one extra row for interpolation
lonsize = 321 + 1 # number of longitude points (-180, 180, 1.125) plus one extra column for interpolation

# exceedance probability, section 1 of Annex 1 of ITU-R P.840-8
psannual = [0.1, 0.2, 0.3, 0.5, 1, 2, 3, 5, 10, 20, 30, 50, 60, 70, 80, 90, 95, 99]
npsannual = length(psannual)

# exceedance probability values for reading files
filespsannual = ["01", "02", "03", "05", "1", "2", "3", "5", "10", "20", "30", "50", "60", "70", "80", "90", "95", "99"]

latvalues = [(-90.0 + (i - 1) * 1.125) for i in 1:latsize]
lonvalues = [(-180.0 + (j - 1) * 1.125) for j in 1:lonsize]

columnarcontentdata = zeros(Float64, (npsannual, latsize, lonsize))
for nps in range(1, npsannual)
    columndata = zeros(Float64, (latsize, lonsize))
    read!(
        joinpath(@__DIR__, "data/reducedcloudliquidwaterannual_$(string(latsize))_x_$(string(lonsize))_x_$(filespsannual[nps]).bin"),
        columndata
    )
    for lat in 1:latsize
        for lon in 1:lonsize
            columnarcontentdata[nps, lat, lon] = columndata[lat, lon]
        end
    end
    columndata = 0
end

#endregion initialization

#region internal functions

"""
    _columnarcontent(latlon::LatLon, p::Real)

Computes annual total columnar content of cloud liquid water reduced to 273.15K in Section 3.1.
    
# Arguments
- `latlon::LatLon`: latitude and longitude (degrees)
- `p::Real`: exceedance probability (%)

# Return
- `Lred::Real`: annual total columnar content of cloud liquid water (kg/m^2)
"""
function _columnarcontent(
    latlon::LatLon,
    p::Real,
)
    # Section 3.1 step a
    prange = searchsorted(psannual, p)
    pindexbelow = prange.stop
    pindexabove = prange.start
    pexact = pindexbelow == pindexabove ? true : false

    latrange = searchsorted(latvalues, latlon.lat)
    lonrange = searchsorted(lonvalues, latlon.lon)
    R = latrange.stop
    C = lonrange.stop

    ??g = 1.125
    r = ((90.0 + latlon.lat) / ??g) + 1
    c = ((180.0 + latlon.lon) / ??g) + 1

    Lred00a = columnarcontentdata[pindexabove, R, C]
    Lred01a = columnarcontentdata[pindexabove, R, C+1]
    Lred10a = columnarcontentdata[pindexabove, R+1, C]
    Lred11a = columnarcontentdata[pindexabove, R+1, C+1]

    Lred00b = columnarcontentdata[pindexbelow, R, C]
    Lred01b = columnarcontentdata[pindexbelow, R, C+1]
    Lred10b = columnarcontentdata[pindexbelow, R+1, C]
    Lred11b = columnarcontentdata[pindexbelow, R+1, C+1]

    Lredabove = (
        Lred00a * ((R + 1 - r) * (C + 1 - c)) +
        Lred10a * ((r - R) * (C + 1 - c)) +
        Lred01a * ((R + 1 - r) * (c - C)) +
        Lred11a * ((r - R) * (c - C))
    )

    if pexact == true
        return Lredabove
    else
        Lredbelow = (
            Lred00b * ((R + 1 - r) * (C + 1 - c)) +
            Lred10b * ((r - R) * (C + 1 - c)) +
            Lred01b * ((R + 1 - r) * (c - C)) +
            Lred11b * ((r - R) * (c - C))
        )
        pslogabove = log(psannual[pindexabove])
        pslogbelow = log(psannual[pindexbelow])
        Lred = (Lredabove - Lredbelow) / (pslogabove - pslogbelow) * (log(p) - pslogbelow) + Lredbelow
        return Lred
    end
end


"""
    _K???(f::Real, T::Real)

Computes cloud specific attenuation coefficient based on Section 2. 
    
# Arguments
- `f::Real`: frequency (GHz)
- `T::Real`: temperature (??C)

# Return
- `K::Real`: attenuation coefficient ((dB/km)/(g/m^3))
"""
function _K???( 
    f::Real,
    T::Real=0.0,
)
    ?? = 300 / (T + 273.15)     # equation 9
    ????? = 77.66 + 103.3 * (?? - 1)     # equation 6
    ????? = 0.0671 * ?????     # equation 7
    ????? = 3.52     # equation 8
    f??? = 20.20 - 146 * (?? - 1) + 316 * (?? - 1) * (?? - 1)     # equation 10
    f??? = 39.8 * f???     # equation 11

    # equation 4
    ???????? = (
        ((f * (????? - ?????)) / (f??? * (1 + (f / f???) * (f / f???))))
        +
        ((f * (????? - ?????)) / (f??? * (1 + (f / f???) * (f / f???))))
    )

    # equation 5
    ????? = (
        (????? - ?????) / (1 + (f / f???) * (f / f???))
        +
        (????? - ?????) / (1 + (f / f???) * (f / f???))
        + ?????
    )


    ?? = (2 + ?????) / ????????     # equation 3
    K = 0.819 * f / (???????? * (1 + ?? * ??))     # equation 2
end

#endregion internal functions


"""
    cloudattenuation(latlon::LatLon,  f::Real, elevation::Real, p::Real)

Computes annual cloud attenuation along a slant path based on Section 3. 
    
# Arguments
- `latlon::LatLon`: latitude and longitude (degrees)
- `f::Real`: frequency (GHz)
- `p::Real`: exceedance probability (%)
- `??::Real`: elevation angle (degrees)

# Return
- `Acloud::Real`: slant path cloud attenuation (dB)
"""
function cloudattenuation(
    latlon::LatLon,
    f::Real,
    p::Real,
    ??::Real,
)
    # Section 3.2, equation 13
    (?? < 5.0 || ?? > 90.0) && @warn("ItuR840.cloudattenuation only supports elevation angles between 5 and 90 degrees.\nThe given elevation angle $?? degrees is outside this range.")

    Lred = _columnarcontent(latlon, p)

    K = _K???(f)

    # equation 12
    Acloud = Lred * K / sin(deg2rad(??))
end

end # module ItuRP840
