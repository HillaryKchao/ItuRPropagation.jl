module ItuRP1511

#=
This Recommendation provides global topographical data, information on geographic coordinates, and
height data for the prediction of propagation effects for Earth-space paths in ITU-R recommendations.
=#

using ItuRPropagations

version = ItuRVersion("ITU-R", "P.1511", 2, "(08/2019)")

#region initialization

const topolatsize::Int64 = 2164
const topolonsize::Int64 = 4324

topolatvalues = [(-90.125 + (i - 1) * (1 / 12)) for i in 1:topolatsize]
topolonvalues = [(-180.125 + (j - 1) * (1 / 12)) for j in 1:topolonsize]

topoheightdata = zeros(Float64, (topolatsize, topolonsize))
read!(
    joinpath(@__DIR__, "data/topo_$(string(topolatsize))_x_$(string(topolonsize)).bin"),
    topoheightdata
)

#endregion initialization

"""
    topographicheight(latlon::LatLon)

Calculates topographic height based on bicubic interpolation in Section 1 of Annex 1.

# Arguments
- `latlon::LatLon`: latitude and longitude (degrees)

# Return
- `I::Real`: height (km)
"""
function topographicheight(latlon::LatLon)
    latrange = searchsorted(topolatvalues, latlon.lat)
    lonrange = searchsorted(topolonvalues, latlon.lon)
    R = latrange.stop - 1
    C = lonrange.stop - 1

    δg = 1 / 12
    r = ((90.125 + latlon.lat) / δg) + 1
    c = ((180.125 + latlon.lon) / δg) + 1

    # row interpolation
    δ = (c - C)
    K₀ = (-0.5) * δ^3 + 2.5 * δ^2 - 4 * δ + 2
    δ = (c - C - 1)
    K₁ = 1.5 * δ^3 - 2.5 * δ^2 + 1
    δ = (C + 2 - c)
    K₂ = 1.5 * δ^3 - 2.5 * δ^2 + 1
    δ = (C + 3 - c)
    K₃ = (-0.5) * δ^3 + 2.5 * δ^2 - 4 * δ + 2

    RI₀ = topoheightdata[R, C] * K₀ + topoheightdata[R, C+1] * K₁ + topoheightdata[R, C+2] * K₂ + topoheightdata[R, C+3] * K₃
    RI₁ = topoheightdata[R+1, C] * K₀ + topoheightdata[R+1, C+1] * K₁ + topoheightdata[R+1, C+2] * K₂ + topoheightdata[R+1, C+3] * K₃
    RI₂ = topoheightdata[R+2, C] * K₀ + topoheightdata[R+2, C+1] * K₁ + topoheightdata[R+2, C+2] * K₂ + topoheightdata[R+2, C+3] * K₃
    RI₃ = topoheightdata[R+3, C] * K₀ + topoheightdata[R+3, C+1] * K₁ + topoheightdata[R+3, C+2] * K₂ + topoheightdata[R+3, C+3] * K₃

    δ = (r - R)
    K₀ = (-0.5) * δ^3 + 2.5 * δ^2 - 4 * δ + 2
    δ = (r - R - 1)
    K₁ = 1.5 * δ^3 - 2.5 * δ^2 + 1
    δ = (R + 2 - r)
    K₂ = 1.5 * δ^3 - 2.5 * δ^2 + 1
    δ = (R + 3 - r)
    K₃ = (-0.5) * δ^3 + 2.5 * δ^2 - 4 * δ + 2

    I = RI₀ * K₀ + RI₁ * K₁ + RI₂ * K₂ + RI₃ * K₃
    return I <= 0 ? 1e-6 : I
end

end # module ItuRP1511