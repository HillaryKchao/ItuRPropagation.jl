# ItuRPropagations
A Julia implementation of the ITU-Recommendations for space links covering cloud, gaseous, rain, and scintillation attenuations.

## Installation
Using the Julia REPL and going to the package manager, you can install this implementation using
```
add ItuRPropagation
```
Alternatively, you can add it directly from the GitHub repository link by going to the package manager and using
```
add https://github.com/HillaryKchao/ItuRPropagation.jl
```
You can check if installation was successful by exiting the package manager and using
```
using ItuRPropagation
```

## ITU-R Recommendations
The following ITU-R Recommendations are implemented:
### Cloud Attenuation
*   **ITU-R P.840-8:** Attenuation due to clouds and fog 
### Gaseous Attenuation
*   **ITU-R P.676-13:** Attenuation by atmospheric gases
*   **ITU-R P.453-14:** The radio refractive index: its formula and refractivity data
*   **ITU-R P.835-16:** Reference Standard Atmospheres
*   **ITU-R P.1511-2:** Topography for Earth-to-space propagation modelling
*   **ITU-R P.2145-0:** Digital maps related to the calculation of gaseous attenuation and related effects
### Rain Attenuation
*   **ITU-R P.618-13:** Propagation data and prediction methods required for the design of Earth-space telecommunication systems
*   **ITU-R P.837-7:** Characteristics of precipitation for propagation modelling
*   **ITU-R P.838-8:** Specific attenuation model for rain for use in prediction methods
*   **ITU-R P.839-4:** Rain height model for prediction methods.
*   **ITU-R P.1511-2:** Topography for Earth-to-space propagation modelling
### Scintillation Attenuation
*   **ITU-R P.618-13:** Propagation data and prediction methods required for the design of Earth-space telecommunication systems
*   **ITU-R P.453-14:** The radio refractive index: its formula and refractivity data

### Noise temperature
*   **ITU-R P.372-16:** Radio noise (only for earth stations - for space stations, a different estimate was used)
*   **ITU-R P.2145-0:** Digital maps related to the calculation of gaseous attenuation and related effects

##  Validation
This implementation has been validated using the [ITU Validation examples (rev 7.0.5)](https://www.itu.int/en/ITU-R/study-groups/rsg3/ionotropospheric/CG-3M3J-13-ValEx-Rev7.0.5.xlsx).
