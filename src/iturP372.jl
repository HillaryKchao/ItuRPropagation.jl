module ItuRP372

#=
Recommendation ITU-R P.372 provides information on the background levels of radio noise in the frequency
range from 0.1 Hz to 100 GHz. It takes account of noise emitted by lightning, atmospheric gases, clouds, rain,
the Earth’s surface, the galaxy, and man-made sources. Noise figures or temperatures are given to provide a
basis for the estimation of system performance.
=#

using ItuRPropagation

version = ItuRVersion("ITU-R", "P.372", 16, "(08/2022)")

"""
    spacestationnoisetemperature(A::Real)

Computes space station noise tempearture based on atmospheric attenuation excluding scintillation fading.
    
# Arguments
- `A::Real`: total atmospheric attenuation excluding scintillation fading (dB)

# Return
- `Tearth::Real`: earth noise temperature at a space station antenna (°K)
"""
function spacestationnoisetemperature(A::Real)
    A10 = 10^(-A / 10)
    Tearth = 240 * A10 + 276 * (1 - A10)
end

"""
    earthstationnoisetemperature(latlon::LatLon, p::Real, A::Real)

Computes estimate of brightness temperature in direction of the propagation path from
the receiver to the spacecraft transmitter.
    
# Arguments
- `latlon::LatLon`: latitude and longitude (degrees)
- `p::Real`: exceedance probability (%)
- `A::Real`: total atmospheric attenuation excluding scintillation fading (dB)

# Return
- `Tsky::Real`: sky noise temperature at a ground station antenna (°K)
"""
function earthstationnoisetemperature(
    latlon::LatLon,
    p::Real,
    A::Real
)
    Tₛ = ItuRP2145.surfacetemperatureannual(latlon, p)
    Tmr = 37.34 + 0.81 * Tₛ # equation 11

    A10 = 10^(-A / 10)
    Tsky = Tmr * (1 - A10) + 2.7 * A10 # equation 10
end

end # module ItuRP372
