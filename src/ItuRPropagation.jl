module ItuRPropagation

export attenuations
export downlinkparameters
export uplinkparameters
export linkparameters

#region package export

export ItuRP840

export ItuRP453
export ItuRP1511
export ItuRP2145
export ItuRP835
export ItuRP838
export ItuRP839
export ItuRP837
export ItuRP676
export ItuRP372

export ItuRP618

#endregion package export

#region include

include("iturcommon.jl")

include("iturP840.jl")

include("iturP453.jl")
include("iturP1511.jl")
include("iturP2145.jl")
include("iturP835.jl")
include("iturP838.jl")
include("iturP839.jl")
include("iturP837.jl")
include("iturP676.jl")
include("iturP372.jl")

include("iturP618.jl")

#endregion include

"""
    attenuations(latlon::LatLon, f::Real, p::Real, θ::Real, D::Real; η::Real=60.0, hs::Union{Real,Missing}=missing, polarization::IturEnum=EnumCircularPolarization)

Computes scintillation attenuation based on Section 2.4.1 of ITU-R P618-13.
    
# Arguments
- `latlon::LatLon`: latitude and longitude (degrees)
- `f::Real`: frequency (GHz)
- `p::Real`: exceedance probability (%)
- `θ::Real`: elevation angle (degrees)
- `D::Real`: antenna diameter (m)
- `η::Real=60`: antenna efficiency (% from 0 to 100, typically 60)
- `hs::Union{Real,Missing}=missing`: altitude of ground station (km)
- `polarization::IturEnum=EnumCircularPolarization`: polarization (EnumHorizontalPolarization, EnumVerticalPolarization, or EnumCircularPolarization)

# Return
- `(Ac=Ac, Ag=Ag, Ar=Ar, As=As, At=At)`: cloud, gas, rain, scintillation, total attenuations (dB)
"""
function attenuations(
    latlon::LatLon,
    f::Real,
    p::Real,
    θ::Real,
    D::Real;
    η::Real=60,
    hs::Union{Real,Missing}=missing,
    polarization::IturEnum=EnumCircularPolarization
)
    Ac = ItuRP840.cloudattenuation(latlon, f, max(1, p), θ)
    Ag = ItuRP676.gaseousattenuation(latlon, f, max(1, p), θ, hs)
    Ar = ItuRP618.rainattenuation(latlon, f, p, θ, polarization)
    As = ItuRP618.scintillationattenuation(latlon, f, p, θ, D, η)

    At = Ag + sqrt((Ar + Ac)^2 + As * As)
    return (Ac=Ac, Ag=Ag, Ar=Ar, As=As, At=At)
end

"""
    downlinkparameters(latlon::LatLon, f::Real, p::Real, θ::Real, D::Real; η::Real=60.0, hs::Union{Real,Missing}=missing, polarization::IturEnum=EnumCircularPolarization)

Downlink parameters for link budget. Includes cloud, gaseous, rain, scintillation, and total attenuations; earth station noise temperature, 
    and cross-polarization discrimination.
    
# Arguments
- `latlon::LatLon`: latitude and longitude (degrees)
- `f::Real`: frequency (GHz)
- `p::Real`: exceedance probability (%)
- `θ::Real`: elevation angle (degrees)
- `D::Real`: antenna diameter (m)
- `η::Real=60`: antenna efficiency (% from 0 to 100, typically 60)
- `hs::Union{Real,Missing}=missing`: altitude of ground station (km)
- `polarization::IturEnum=EnumCircularPolarization`: polarization (EnumHorizontalPolarization, EnumVerticalPolarization, or EnumCircularPolarization)

# Return
- `(Ac=Ac, Ag=Ag, Ar=Ar, As=As, At=At)`: cloud, gas, rain, scintillation, total attenuations (dB)
"""
function downlinkparameters(
    latlon::LatLon,
    f::Real,
    p::Real,
    θ::Real,
    D::Real;
    η::Real=60,
    hs::Union{Real,Missing}=missing,
    polarization::IturEnum=EnumCircularPolarization
)
    Ac = ItuRP840.cloudattenuation(latlon, f, max(1, p), θ)
    Ag = ItuRP676.gaseousattenuation(latlon, f, max(1, p), θ, hs)
    Ar = ItuRP618.rainattenuation(latlon, f, p, θ, polarization)
    As = ItuRP618.scintillationattenuation(latlon, f, p, θ, D, η)

    At = Ag + sqrt((Ar + Ac)^2 + As * As)
    Tsky = ItuRP372.earthstationnoisetemperature(latlon, p, Ag + Ar + Ac)
    XPD = ItuRP618.crosspolarizationdiscrimination(f, p, θ, Ar, polarization)
    return (Ac=Ac, Ag=Ag, Ar=Ar, As=As, At=At, Tsky=Tsky, XPD=XPD)
end

"""
    uplinkparameters(latlon::LatLon, f::Real, p::Real, θ::Real, D::Real; η::Real=60.0, hs::Union{Real,Missing}=missing, polarization::IturEnum=EnumCircularPolarization)

Uplink parameters for link budget. Includes cloud, gaseous, rain, scintillation, and total attenuations; space station noise temperature,
    and cross-polarization discrimination.
    
# Arguments
- `latlon::LatLon`: latitude and longitude (degrees)
- `f::Real`: frequency (GHz)
- `p::Real`: exceedance probability (%)
- `θ::Real`: elevation angle (degrees)
- `D::Real`: antenna diameter (m)
- `η::Real=60`: antenna efficiency (% from 0 to 100, typically 60)
- `hs::Union{Real,Missing}=missing`: altitude of ground station (km)
- `polarization::IturEnum=EnumCircularPolarization`: polarization (EnumHorizontalPolarization, EnumVerticalPolarization, or EnumCircularPolarization)

# Return
- `(Ac=Ac, Ag=Ag, Ar=Ar, As=As, At=At)`: cloud, gas, rain, scintillation, total attenuations (dB)
"""
function uplinkparameters(
    latlon::LatLon,
    f::Real,
    p::Real,
    θ::Real,
    D::Real;
    η::Real=60,
    hs::Union{Real,Missing}=missing,
    polarization::IturEnum=EnumCircularPolarization
)
    Ac = ItuRP840.cloudattenuation(latlon, f, max(1, p), θ)
    Ag = ItuRP676.gaseousattenuation(latlon, f, max(1, p), θ, hs)
    Ar = ItuRP618.rainattenuation(latlon, f, p, θ, polarization)
    As = ItuRP618.scintillationattenuation(latlon, f, p, θ, D, η)

    At = Ag + sqrt((Ar + Ac)^2 + As * As)
    Tearth = ItuRP372.spacestationnoisetemperature(Ag + Ar + Ac)
    XPD = ItuRP618.crosspolarizationdiscrimination(f, p, θ, Ar, polarization)
    return (Ac=Ac, Ag=Ag, Ar=Ar, As=As, At=At, Tearth=Tearth, XPD=XPD)
end


"""
    linkparameters(latlon::LatLon, f::Real, p::Real, θ::Real, D::Real; η::Real=60.0, hs::Union{Real,Missing}=missing, polarization::IturEnum=EnumCircularPolarization)

Link parameters for link budget. Includes cloud, gaseous, rain, scintillation, and total attenuations; space station noise temperature,
    earth station noise temperature, and cross-polarization discrimination.
    
# Arguments
- `latlon::LatLon`: latitude and longitude (degrees)
- `f::Real`: frequency (GHz)
- `p::Real`: exceedance probability (%)
- `θ::Real`: elevation angle (degrees)
- `D::Real`: antenna diameter (m)
- `η::Real=60`: antenna efficiency (% from 0 to 100, typically 60)
- `hs::Union{Real,Missing}=missing`: altitude of ground station (km)
- `polarization::IturEnum=EnumCircularPolarization`: polarization (EnumHorizontalPolarization, EnumVerticalPolarization, or EnumCircularPolarization)

# Return
- `(Ac=Ac, Ag=Ag, Ar=Ar, As=As, At=At)`: cloud, gas, rain, scintillation, total attenuations (dB)
"""
function linkparameters(
    latlon::LatLon,
    f::Real,
    p::Real,
    θ::Real,
    Duplink::Real,
    Ddownlink::Real;
    η::Real=60,
    hs::Union{Real,Missing}=missing,
    polarization::IturEnum=EnumCircularPolarization
)
    Ac = ItuRP840.cloudattenuation(latlon, f, max(1, p), θ)
    Ag = ItuRP676.gaseousattenuation(latlon, f, max(1, p), θ, hs)
    Ar = ItuRP618.rainattenuation(latlon, f, p, θ, polarization)
    Asuplink = ItuRP618.scintillationattenuation(latlon, f, p, θ, Duplink, η)
    Asdownlink = ItuRP618.scintillationattenuation(latlon, f, p, θ, Ddownlink, η)

    Atuplink = Ag + sqrt((Ar + Ac)^2 + Asuplink * Asuplink)
    Atdownlink = Ag + sqrt((Ar + Ac)^2 + Asdownlink * Asdownlink)
    Tearth = ItuRP372.spacestationnoisetemperature(Ag + Ar + Ac)
    Tsky = ItuRP372.earthstationnoisetemperature(latlon, p, Ag + Ar + Ac)
    XPD = ItuRP618.crosspolarizationdiscrimination(f, p, θ, Ar, polarization)
    return (Ac=Ac, Ag=Ag, Ar=Ar, Asuplink=Asuplink, Asdownlink=Asdownlink, Atuplink=Atuplink, Atdownlink=Atdownlink, Tearth=Tearth, Tsky=Tsky, XPD=XPD)
end

end # module ItuRPropagation
