module ItuRP838

#=
Recommendation ITU-R P.838-3 recommends the procedure for obtaining the 
 specfic attenuation (gamma sub R in dB/km) from the rain rate R (mm/h).
=#

using ItuRPropagation

version = ItuRVersion("ITU-R", "P.838", 8, "03/2005")

#region coefficients

# Table 1
kₕaⱼ = [-5.33980, -0.35351, -0.23789, -0.94158]
kₕbⱼ = [-0.10008, 1.2697, 0.86036, 0.64552]
kₕcⱼ = [1.13098, 0.454, 0.15354, 0.16817]
kₕm = -0.18961
kₕc = 0.71147

# Table 2
kᵥaⱼ = [-3.80595, -3.44965, -0.39902, 0.50167]
kᵥbⱼ = [0.56934, -0.22911, 0.73042, 1.07319]
kᵥcⱼ = [0.81061, 0.51059, 0.11899, 0.27195]
kᵥm = -0.16398
kᵥc = 0.63297

# Table 3
αₕaⱼ = [-0.14318, 0.29591, 0.32177, -5.37610, 16.1721]
αₕbⱼ = [1.82442, 0.77564, 0.63773, -0.96230, -3.29980]
αₕcⱼ = [-0.55187, 0.19822, 0.13164, 1.47828, 3.43990]
αₕm = 0.67849
αₕc = -1.95537

# Table 4
αᵥaⱼ = [-0.07771, 0.56727, -0.20238, -48.2991, 48.5833]
αᵥbⱼ = [2.3384, 0.95545, 1.1452, 0.791669, 0.791459]
αᵥcⱼ = [-0.76284, 0.54039, 0.26809, 0.116226, 0.116479]
αᵥm = -0.053739
αᵥc = 0.83433

#endregion coefficients

#region internal functions

"""
    _kₕkᵥαₕαᵥ(f::Float64)

Computes rain specific attenuation coefficients based on Section 1.

# Arguments
- `f::Float64`: frequency (GHz)

# Return
- `(kₕ::Real, kᵥ::Real, αₕ::Real, αᵥ::Real)`: rain specific attenuation coefficients
"""
function _kₕkᵥαₕαᵥ(f::Float64)
    logf = log10(f)
    # coefficient k_h based on equation 2
    kₕ = 10^(
        (
            kₕaⱼ[1] * exp(-((logf - kₕbⱼ[1]) / kₕcⱼ[1])^2)
            + kₕaⱼ[2] * exp(-((logf - kₕbⱼ[2]) / kₕcⱼ[2])^2)
            + kₕaⱼ[3] * exp(-((logf - kₕbⱼ[3]) / kₕcⱼ[3])^2)
            + kₕaⱼ[4] * exp(-((logf - kₕbⱼ[4]) / kₕcⱼ[4])^2)
        )
        + kₕm * logf + kₕc
    )

    # coefficient k_h based on equation 2
    kᵥ = 10^(
        (
            kᵥaⱼ[1] * exp(-((logf - kᵥbⱼ[1]) / kᵥcⱼ[1])^2)
            + kᵥaⱼ[2] * exp(-((logf - kᵥbⱼ[2]) / kᵥcⱼ[2])^2)
            + kᵥaⱼ[3] * exp(-((logf - kᵥbⱼ[3]) / kᵥcⱼ[3])^2)
            + kᵥaⱼ[4] * exp(-((logf - kᵥbⱼ[4]) / kᵥcⱼ[4])^2)
        )
        + kᵥm * logf + kᵥc
    )

    # coefficient α_h based on equation 3
    αₕ = (
        (
            αₕaⱼ[1] * exp(-((logf - αₕbⱼ[1]) / αₕcⱼ[1])^2)
            + αₕaⱼ[2] * exp(-((logf - αₕbⱼ[2]) / αₕcⱼ[2])^2)
            + αₕaⱼ[3] * exp(-((logf - αₕbⱼ[3]) / αₕcⱼ[3])^2)
            + αₕaⱼ[4] * exp(-((logf - αₕbⱼ[4]) / αₕcⱼ[4])^2)
            + αₕaⱼ[5] * exp(-((logf - αₕbⱼ[5]) / αₕcⱼ[5])^2)
        )
        + αₕm * logf + αₕc
    )

    # coefficient α_v based on equation 3
    αᵥ = (
        (
            αᵥaⱼ[1] * exp(-((logf - αᵥbⱼ[1]) / αᵥcⱼ[1])^2)
            + αᵥaⱼ[2] * exp(-((logf - αᵥbⱼ[2]) / αᵥcⱼ[2])^2)
            + αᵥaⱼ[3] * exp(-((logf - αᵥbⱼ[3]) / αᵥcⱼ[3])^2)
            + αᵥaⱼ[4] * exp(-((logf - αᵥbⱼ[4]) / αᵥcⱼ[4])^2)
            + αᵥaⱼ[5] * exp(-((logf - αᵥbⱼ[5]) / αᵥcⱼ[5])^2)
        )
        + αᵥm * logf + αᵥc
    )
    return (kₕ, kᵥ, αₕ, αᵥ)
end

#endregion internal functions

"""
    rainspecificattenuation(f::Float64, θ::Float64, R::Float64, polarization::IturEnum)

Computes rain specific attenuation for horizontal polarization based on equation 1 of Section 1.

# Arguments
- `f::Float64`: frequency (GHz)
- `θ:Float64`: path elevation angle (degrees)
- `R::Float64`: rain rate (mm/hr)
- `polarization::IturEnum`: polarization (EnumHorizontalPolarization, EnumVerticalPolarization, or EnumCircularPolarization)

# Return
- specific attenuation at given rain rate (dB)
"""
function rainspecificattenuation(
    f::Real, 
    θ::Real, 
    R::Real, 
    polarization::IturEnum
)
    cosθ = cos(deg2rad(θ))
    if polarization == EnumHorizontalPolarization
        kₕ, kᵥ, αₕ, αᵥ = _kₕkᵥαₕαᵥ(f)
        k = (kₕ + kᵥ + (kₕ - kᵥ) * cosθ^2) / 2
        α = (kₕ * αₕ + kᵥ * αᵥ + (kₕ * αₕ - kᵥ * αᵥ) * cosθ^2) / (2 * k)
        return(k * R^α)
    elseif polarization == EnumVerticalPolarization
        kₕ, kᵥ, αₕ, αᵥ = _kₕkᵥαₕαᵥ(f)
        k = (kₕ + kᵥ - (kₕ - kᵥ) * cosθ^2) / 2
        α = (kₕ * αₕ + kᵥ * αᵥ - (kₕ * αₕ - kᵥ * αᵥ) * cosθ^2) / (2 * k)
        return(k * R^α)
    elseif polarization == EnumCircularPolarization
        kₕ, kᵥ, αₕ, αᵥ = _kₕkᵥαₕαᵥ(f)
        k = (kₕ + kᵥ) / 2
        α = (kₕ * αₕ + kᵥ * αᵥ) / (2 * k)
        return(k * R^α)
    else
        throw(ArgumentError("Invalid polarization value in ItuRP838.rainspecificattenuation."))
    end
end

end # module ItuRP838
