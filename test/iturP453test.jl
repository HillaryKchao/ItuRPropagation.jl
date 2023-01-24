using DelimitedFiles
using Test
using ItuRPropagation

struct TestData
    testinput
    answer
end

function testItuRP453wettermsurfacerefractivityannual()
    allowableerror = 1.0e-7
    itudata = [
        TestData((LatLon(3.133, 101.7)), 128.14080027),
        TestData((LatLon(22.9, -43.23)), 104.35847467),
        TestData((LatLon(23.0, 30.0)), 36.47166667),
        TestData((LatLon(25.78, -80.22)), 113.27386720),
        TestData((LatLon(28.717, 77.3)), 75.66013547),
        TestData((LatLon(33.94, 18.43)), 80.14015964),
        TestData((LatLon(41.9, 12.49)), 61.21890044),
        TestData((LatLon(51.5, -0.14)), 50.38926222),
    ]
    println(" ")
    errors = []
    @testset "iturP453 (Itu-R P.453-14) wet term surface refractivity annual: ITU data" begin
        for testdata in itudata
            value = ItuRP453.wettermsurfacerefractivityannual_50(testdata.testinput)
            error = abs(value - testdata.answer)
            @test error < allowableerror
            push!(errors, error)
        end
    end
    println("Wet term ITU data MAX ERROR: $(maximum(errors)) g/m^3 \n")
end


println("\n<===== " * "ITUR 453.14 "^5 * " =====")
testItuRP453wettermsurfacerefractivityannual()
println("===== " * "ITUR 453.14 "^5 * "=====>\n")
