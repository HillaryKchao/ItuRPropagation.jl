using DelimitedFiles
using Test
using ItuRPropagation

struct TestData
    testinput
    answer
end


function testIturP837InterpolatedRandom()
    allowableerror = 1.0e-7
    randomdata = [
        TestData(LatLon(-24.031250, 125.843750), 32.639062500),
        TestData(LatLon(-48.656250, 119.843750), 25.529187500),
        TestData(LatLon(-78.031250, -108.406250), 2.355062500),
        TestData(LatLon(84.968750, 164.093750), 6.351500000),
        TestData(LatLon(78.968750, -130.156250), 6.345687500),
        TestData(LatLon(-23.031250, -37.656250), 68.605500000),
        TestData(LatLon(31.718750, 179.593750), 52.349875000),
        TestData(LatLon(29.843750, -156.531250), 48.476125000),
        TestData(LatLon(89.468750, 29.593750), 6.066000000),
        TestData(LatLon(-80.281250, 156.593750), 0.212437500),
        TestData(LatLon(-4.531250, -131.281250), 63.658375000),
        TestData(LatLon(-86.531250, -0.781250), 0.000000000),
        TestData(LatLon(-2.531250, -52.406250), 90.853500000),
        TestData(LatLon(47.843750, -149.406250), 30.150250000),
        TestData(LatLon(-39.781250, -165.281250), 37.479125000),
        TestData(LatLon(34.468750, 100.218750), 16.715000000),
        TestData(LatLon(-69.156250, 7.468750), 5.873937500),
        TestData(LatLon(35.593750, 27.468750), 33.499375000),
        TestData(LatLon(-40.781250, -83.781250), 30.523937500),
        TestData(LatLon(70.593750, -169.656250), 9.167250000),
        TestData(LatLon(68.218750, 40.468750), 15.100062500),
        TestData(LatLon(67.218750, -21.281250), 16.939375000),
        TestData(LatLon(-28.406250, 110.468750), 25.379062500),
        TestData(LatLon(-19.781250, 98.343750), 33.889750000),
        TestData(LatLon(26.343750, 145.218750), 68.686500000),
        TestData(LatLon(-81.406250, -134.406250), 1.271687500),
        TestData(LatLon(33.718750, 76.093750), 14.926500000),
        TestData(LatLon(-36.781250, 62.843750), 37.593625000),
        TestData(LatLon(85.468750, 125.093750), 6.556312500),
        TestData(LatLon(-51.531250, -72.531250), 14.977625000),]
    errors = []
    println(" ")
    @testset "iturP837 (Itu-R P.837-7) annual rainfall rate exceeded 0.01%: random test" begin
        for testdata in randomdata
            error = abs(ItuRP837.rainfallrate001(testdata.testinput) - (testdata.answer))
            push!(errors, error)
            @test error < allowableerror
        end
    end
    println("MAX ERROR: $(maximum(errors)) mm/hr\n")
end

function testIturP837ituR001data()
    allowableerror = 1.0e-3
    errors = []
    ituannualdata = [
        TestData(LatLon(3.1330, 101.7000), 99.1481136),
        TestData(LatLon(22.9000, -43.2300), 50.639304),
        TestData(LatLon(23.0000, 30.0000), 0.0000000000),
        TestData(LatLon(25.7800, -80.2200), 78.2982928),
        TestData(LatLon(28.7170, 77.3000), 63.5972463999999),
        TestData(LatLon(33.9400, 18.4300), 27.1349664),
        TestData(LatLon(41.9000, 12.4900), 33.936232),
        TestData(LatLon(51.5000, -0.1400), 26.48052),]
    @testset "iturP837 (Itu-R P.837-7) annual rainfall rate exceeded 0.01%: ITU data test" begin
        for testdata in ituannualdata
            predictedvalue = ItuRP837.rainfallrate001(testdata.testinput)
            error = abs(predictedvalue - testdata.answer)
            push!(errors, error)
            @test error < allowableerror
        end
    end
    println("MAX ERROR: $(maximum(errors)) mm/hr\n")
end

function testIturP837itufullmethoddata()
    allowableerror = 1.0e-1
    errors = []
    ituannualdata = [
        TestData(LatLon(3.1330, 101.7000), 99.1511718600),
        TestData(LatLon(22.9000, -43.2300), 50.6393040000),
        TestData(LatLon(23.0000, 30.0000), 0.0000000000),
        TestData(LatLon(25.7800, -80.2200), 78.2994993000),
        TestData(LatLon(28.7170, 77.3000), 63.6188880800),
        TestData(LatLon(33.9400, 18.4300), 27.1358683200),
        TestData(LatLon(41.9000, 12.4900), 33.9362320000),
        TestData(LatLon(51.5000, -0.1400), 26.4805200000),]
    @testset "iturP837 (Itu-R P.837-7) annual rainfall rate exceeded 0.01%: ITU data test" begin
        for testdata in ituannualdata
            predictedvalue = ItuRP837.rainfallrate001(testdata.testinput)
            error = abs(predictedvalue - testdata.answer)
            push!(errors, error)
            @test error < allowableerror
        end
    end
    println("MAX ERROR: $(maximum(errors)) mm/hr\n")
end




println("\n<===== " * "ITUR P837.7 "^5 * " =====")
testIturP837InterpolatedRandom()
testIturP837ituR001data()
testIturP837itufullmethoddata()
println("===== " * "ITUR P837.7 "^5 * "=====> \n")
