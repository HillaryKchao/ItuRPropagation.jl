export LatLon
export IturEnum
export EnumWater, EnumIce
export EnumHeightAndIndex, EnumIndexOnly
export EnumHorizontalPolarization, EnumVerticalPolarization, EnumCircularPolarization
export ItuRVersion

export ItuRPropagation

struct LatLon
    lat::Real
    lon::Real
    function LatLon(lat, lon)
        if lat < -90.0 || lat > 90.0
            throw(ErrorException("lat=$lat\nlat (latitude) should be between -90 and 90"))
        end
        if lon > 180
            lon -= 360
        end
        if lon < -180 || lon > 180
            throw(ErrorException("lon=$lat\nlon (longitude) should be between -180 and 180"))
        end
        new(lat, lon)
    end
end

Base.show(io::IO, p::LatLon) = print(io, "(", p.lat, ", ", p.lon, ")")

@enum IturEnum begin
    # for ITU-R P.453-14
    EnumWater
    EnumIce

    # for ITU-R P.1511-11 (custom by Kchao)
    EnumHeightAndIndex
    EnumIndexOnly

    # for ITU-R P.838-3
    EnumHorizontalPolarization
    EnumVerticalPolarization
    EnumCircularPolarization
end

struct ItuRVersion
    doctype::String
    recommendation::String
    dashednumber::Int8
    datestring::String
end
