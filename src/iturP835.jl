module ItuRP835

#=
Recommendation ITU-R P.835 provides expressions and data for reference standard atmospheres required for
the calculation of gaseous attenuation on Earth-space paths.
=#

using ItuRPropagations

version = ItuRVersion("ITU-R", "P.835", 16, "(12/2017)")

"""
    standardtemperature(h::Float64)

Standard temperature for geometric heights <= 100 km, based on equations 2a-2g and 4a-4b of Section 1.1

# Arguments
- `h::Float64`: geometric height (km)

# Return
- temperature (°K)
"""
function standardtemperature(h::Float64)
    (h < 0.0 || h > 100.0) && throw(ArgumentError("h=$h\n (geometric height) in IturP835.standardtemperature must be between 0 and 100"))

    hp = (h * 6356.766) / (h + 6356.766)
    if 0 <= hp <= 11
        return (288.15 - 6.5 * hp)
    elseif 11 < hp <= 20
        return 216.65
    elseif 20 < hp <= 32
        return (216.65 + (hp - 20))
    elseif 32 < hp <= 47
        return (228.65 + 2.8(hp - 32))
    elseif 47 < hp <= 51
        return 270.65
    elseif 51 < hp <= 71
        return (270.65 - 2.8 * (hp - 51))
    elseif 71 < hp <= 84.852
        return (214.65 - 2(hp - 71))
    elseif 86 <= h <= 91
        return 186.8673
    elseif 91 < h <= 100
        return (263.1905 - 76.3232 * sqrt(1 - ((h - 91) / 19.9429)^2))
    end
end


"""
    standardpressure(h::Float64)

Standard pressure for geometric heights <= 100 km, based on equations 3a-3g and 5 of Section 1.1.

# Arguments
- `h::Float64`: geometric height (km)

# Return
- dry pressure (hPa)
"""
function standardpressure(h::Float64)
    (h < 0.0 || h > 100.0) && throw(ArgumentError("h=$h\n (geometric height) in IturP835.standardpressure must be between 0 and 100"))
    hp = (h * 6356.766) / (h + 6356.766)
    if 0 <= hp <= 11
        return (1013.25 * (288.15 / (288.15 - 6.5 * hp))^(-34.1632 / 6.5))
    elseif 11 < hp <= 20
        return (226.3226 * exp(-34.1632 * (hp - 11) / 216.65))
    elseif 20 < hp <= 32
        return (54.74980 * (216.65 / (216.65 + (hp - 20)))^34.1632)
    elseif 32 < hp <= 47
        return (8.680422 * (228.65 / (228.65 + 2.8 * (hp - 32)))^(34.1632 / 2.8))
    elseif 47 < hp <= 51
        return (1.109106 * exp(-34.1632 * (hp - 47) / 270.65))
    elseif 51 < hp <= 71
        return (0.6694167 * (270.65 / (270.65 - 2.8 * (hp - 51)))^(-34.1632 / 2.8))
    elseif 71 < hp <= 84.852
        return (0.03956649 * (214.65 / (214.65 - 2.0 * (hp - 71)))^(-34.1632 / 2.0))
    elseif 86 <= h <= 100
        return exp(95.571899
                   -
                   4.011801 * hp
                   +
                   6.424731e-2 * hp^2
                   -
                   4.789660e-4 * hp^3
                   +
                   1.340543e-6 * hp^4)
    end
end


"""
    standardwatervapordensity(h::Array{Float64}, T::Array{Float64}, P::Array{Float64}, ρ₀::Float64=7.5)

Standard pressure for geometric heights <= 100 km based on Section 1.2.

# Arguments
- `h::Array{Float64}`: array of geometric heights (km)
- `T::Array{Float64}`: array of temperatures (°K)
- `P::Array{Float64}`: array of pressures (hPa)
- `ρ₀::Float64=7.5`: standard ground level water vapor density (g/m^3)

# Return
- standard water vapor density (g/m^3)
"""
function standardwatervapordensity(
    h::Array{Float64}, 
    T::Array{Float64}, 
    P::Array{Float64}, 
    ρ₀::Float64=7.5
)
    N = length(h)
    ρvalues = zeros(Float64, N)
    for i in 1:N
        # equation 6 where h₀ = 2; equation 7 where ρ₀=7.5
        ρ = ρ₀ * exp(-h[i] / 2.0)

        # see paragraph below equation 8 regarding mixing ratio
        e = ρ * T[i] / 216.7
        mixingratio = e / P[i]
        if mixingratio < 2e-6
            # see paragraph below equation 8 regarding mixing ratio
            # and recalculate ρ
            enew = P[i] * 2e-6
            ρ = enew * 216.7 / T[i]
        end
        ρvalues[i] = ρ
    end
    return ρvalues
end

end # module ItuRP835