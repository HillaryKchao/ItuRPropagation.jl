module ItuRP618

#=
This Recommendation predicts the various propagation parameters needed in planning Earth-space
systems operating in either the Earth-to-space or space-to-Earth direction.
=#

using ItuRPropagation

version = ItuRVersion("ITU-R", "P.618", 13, "(12/2017)")

Rₑ = 8500 # effective radius of the Earth (km)

"""
    scintillationattenuation(latlon::LatLon, f::Real, p::Real, θ::Real, D::Real, η::Real=60.0, hL::Real=1000.0)

Computes scintillation attenuation based on Section 2.4.1.
    
# Arguments
- `latlon::LatLon`: latitude and longitude (degrees)
- `f::Real`: frequency (GHz)
- `p::Real`: exceedance probability (%)
- `θ::Real`: elevation angle (degrees)
- `D::Real`: antenna diameter (m)
- `η::Real=60`: antenna efficiency (% from 0 to 100, typically 60)
- `hL::Real=1000.0`: height of turbulent layer (m) - equation 41

# Return
- `Ascintillation::Real`: scintillation attenuation (dB)
"""
function scintillationattenuation(
    latlon::LatLon,
    f::Real,
    p::Real,
    θ::Real,
    D::Real,
    η::Real=60.0,
    hL::Real=1000.0
)
    # step 8 of Section 2.4.1
    (p < 0.01 || p > 50) && @warn("ItuR618.scintillationattenuation only supports exceedance probabilities between 0.01% and 50%.\nThe given exceedance probability $p% is outside this range.")
    # list of parameters in Section 2.4.1
    (θ < 5 || θ > 90) && @warn("ItuR618.scintillationattenuation only supports elevation angles between 5 and 90 degrees.\nThe given elevation angle $θ degrees is outside this range.")
    
    # step 2
    Nwet = ItuRP453.wettermsurfacerefractivityannual_50(latlon)

    # step 3
    σref = 3.6e-3 + 1.0e-4 * Nwet     # equation 40

    # step 4
    sinθ = sin(deg2rad(θ))
    L = 2 * hL / (sqrt(sinθ * sinθ + 2.35e-4) + sinθ)     # equation 41

    # step 5
    DeffSquared = (η / 100) * D * D     # based on equation 42

    # step 6
    x = 1.22 * DeffSquared * (f / L)     # equation 43a
    if x >= 7.0
        # from last paragraph of step 6
        # If the argument of the square root is negative (i.e. when x >= 7.0),
        # the predicted scintillation fade depth for any time percentage is zero
        # and the following steps are not required
        # That is: we return 0.0 for the predicted scintillation fade depth
        return 0.0
    end
    # for x < 7.0
    g = sqrt(3.86 * (x * x + 1)^(11 / 12) * sin(11 / 6 * atan(1, x)) - 7.08 * x^(5 / 6))     # equation 43

    # step 7
    σ = σref * f^(7 / 12) * (g / (sinθ)^(1.2))     # equation 44

    # step 8
    logp = log10(p)
    aₚ = -0.061 * logp^3 + 0.072 * logp^2 - 1.71 * logp + 3     # equation 45

    # step 9
    Ascintillation = aₚ * σ     # equation 46
end


"""
    rainattenuation(latlon::LatLon, f::Real, p::Real, θ::Real, polarization::IturEnum=EnumCircularPolarization)

Computes rain attenuation based on Section 2.2.1.1.
    
# Arguments
- `latlon::LatLon`: (lat, lon) struct in degrees
- `f::Real`: frequency (GHz),
- `p::Real`: exceedance probability (%)
- `θ::Real`: elevation angle (degrees)
- `polarization::IturEnum=EnumCircularPolarization`: polarization (EnumHorizontalPolarization, EnumVerticalPolarization, or EnumCircularPolarization) 

# Return
- `Aₚ::Real`: rain attenuation (dB)
"""
function rainattenuation(
    latlon::LatLon,
    f::Real,
    p::Real,
    θ::Real,
    polarization::IturEnum=EnumCircularPolarization
)
    # first paragraph of 2.2.1.1
    (f > 55 || f < 1) && @warn("ItuR618.rainattenuation only supports frequencies between 1 and 55 GHz.\nThe given frequency $f GHz is outside this range.")
    
    # per step 10
    (p < 0.001 || p > 5) && @warn("ItuR618.rainattenuation only supports exceedance probabilities between 0.001% and 5%.\nThe given exceedance probability $p% is outside this range.")

    # step 1
    hᵣ = ItuRP839.rainheightannual(latlon)

    # step 2
    hₛ = ItuRP1511.topographicheight(latlon)

    sinθ = sin(deg2rad(θ))
    if (hᵣ - hₛ) <= 0
        return 0.0
    end
    
    Lₛ = θ >= 5 ? (hᵣ - hₛ) / sinθ : 2 * (hᵣ - hₛ) / (sqrt(sinθ * sinθ + (2 * (hᵣ - hₛ)) / Rₑ) + sinθ)

    # step 3
    cosθ = cos(deg2rad(θ))
    Lg = Lₛ * cosθ

    # step 4
    R001 = ItuRP837.rainfallrate001(latlon)

    # step 5
    γᵣ = ItuRP838.rainspecificattenuation(f, θ, R001, polarization)

    # step 6
    r001 = 1 / (1 + 0.78 * sqrt((Lg * γᵣ) / f) - 0.38 * (1 - exp(-2 * Lg)))

    # step 7
    abslat = abs(latlon.lat)
    ζ = rad2deg(atan((hᵣ - hₛ) / (Lg * r001)))
    Lᵣ = ζ > θ ? (Lg * r001) / cosθ : (hᵣ - hₛ) / sinθ
    χ = abslat < 36 ? 36 - abslat : 0.0

    v001 = 1 / (1 + sqrt(sinθ) * (31 * (1 - exp(-θ / (1 + χ))) * (sqrt(Lᵣ * γᵣ) / (f * f)) - 0.45))

    # step 8
    Lₑ = Lᵣ * v001

    # step 9
    A001 = γᵣ * Lₑ

    # step 10
    if p >= 1.0 || abslat >= 36
        β = 0.0
    elseif p < 1.0 && abslat < 36 && θ >= 25
        β = -0.005 * (abslat - 36)
    else
        β = -0.005 * (abslat - 36) + 1.8 - 4.25 * sinθ
    end

    Aₚ = A001 * (p / 0.01)^(-(0.655 + 0.033 * log(p) - 0.045 * log(A001) - β * (1 - p) * sinθ))

    return Aₚ
end


"""
    raindiversitygain(f::Real, θ::Real, d::Real, A::Real, Ψ::Real)

Computes rain diversity gain based on Section 2.2.4.2.
    
# Arguments
- `f::Real`: frequency (GHz)
- `θ::Real`: path elevation angle (degrees)
- `d::Real`: separation between the two sites (km)
- `A::Real`: path rain attenuation for a single site (dB)
- `Ψ::Real`: angle made by azimuth of propagation path with respect to the baseline between sites,
             chosen such that Ψ <= 90 (degrees)

             # Return
- G::Real`: net diversity gain (dB)
"""
function raindiversitygain(
   f::Real,
   θ::Real,
   d::Real,
   A::Real,
   Ψ::Real
)
    # first paragraph of 2.2.4.2
    (d < 0 || d > 20) && @warn("ItuR618.raindiversitygain only supports site separations between 1 and 20 km.\nThe given site separation $d km is outside this range.")
    
    # step 1
    a = 0.78*A - 1.94*(1-exp(-0.11*A))
    b = 0.59*(1-exp(-0.1*A))
    Gd = a*(1 - exp(-b*d))     # equation 35

    # step 2
    Gf = exp(-0.025*f)     # equation 36

    # step 3
    Gθ = 1 + 0.006 * θ     # equation 37

    # step 4
    GΨ = 1 + 0.002 * Ψ     # equation 38

    # step 5
    G = Gd * Gf * Gθ * GΨ     # equation 39
end

"""
    crosspolarizationdiscrimination(f::Real, p::Real, θ::Real, Aᵣ::Real, polarization::IturEnum=EnumCircularPolarization)

Computes cross-polarization discrimination based on Section 4.1.
    
# Arguments
- `f::Real`: frequency (GHz)
- `p::Real`: exceedance probability (%)
- `θ::Real`: path elevation angle (degrees)
- `Aᵣ::Real`: rain attenuation (dB)
- `polarization::IturEnum=EnumCircularPolarization`: polarization (EnumHorizontalPolarization, EnumVerticalPolarization, or EnumCircularPolarization)

# Return
- `XPD::Real`: cross polarization discrimination from rain attenuation statistics (dB)
"""
function crosspolarizationdiscrimination(
    f::Real,
    p::Real,
    θ::Real,
    Aᵣ::Real,
    polarization::IturEnum=EnumCircularPolarization
)
    # first paragraph of 4.1
    (f < 4 || f > 55) && @warn("ItuR618.crosspolarizationdiscrimination only supports frequencies between 4 and 55 GHz.\nThe given frequency $f GHz is outside this range.")
    (θ < 0 || θ > 60) && @warn("ItuR618.crosspolarizationdiscrimination only supports elevation angles between 0 and 60 degrees.\nThe given elevation angle $θ degrees is outside this range.")

    if f > 55
        return 100  # large discrimination
    end

    shouldscale = false
    if 4 <= f < 6
        forig = f
        f = 6.0
        shouldscale = true
    end

    # step 1, equation 65
    logf = log10(f)
    if 6 <= f < 9
        Cf = 60 * logf - 28.3
    elseif 9 <= f < 36
        Cf = 26*logf + 4.1
    elseif 36 <= f <= 55
        Cf = 35.9*logf - 11.3
    end

    # step 2
    if 6 <= f < 9
        Vf = 30.8 * f^(-0.21)        
    elseif 9 <= f < 20
        Vf = 12.8 * f^0.19
    elseif 20 <= f < 40
        Vf = 22.6
    elseif 40 <= f <= 55
        Vf = 13.0 
    end

    Cₐ = Vf * log10(Aᵣ)     # equation 66

    # step 3, equation 67
    if polarization == EnumCircularPolarization
        Cτ = 0
    else
        Cτ = 14.948500216800937  # -10 * log10(1 - 0.484 * (1 + cos(4 * τ))), τ = 0 or 90
    end

    # step 4
    Cθ = -40 * log10(cos(deg2rad(θ)))     # equation 68

    # step 5
    if p <= 0.001
        σ = 15
    elseif p <= 0.01
        σ = 10
    elseif p <= 0.1
        σ = 5
    else
        σ = 0
    end

    Cσ = 0.0053 * σ * σ     # equation 69

    # step 6
    XPDrain = Cf - Cₐ + Cτ + Cθ + Cσ     # equation 70

    # step 7
    Cice = XPDrain * (0.3 + 0.1*log10(p))/2     # equation 71

    # step 8
    XPDp = XPDrain - Cice     # equation 72

    if shouldscale
        XPDp = XPDp - 20*log10(forig/f)
    end
    
    return XPDp
end

end # module ItuRP618
