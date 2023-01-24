using DelimitedFiles
using Test
using ItuRPropagation

struct TestData
    testinput
    answer
end

function testItuRP839()
    allowableerror = 1.0e-10

    randomdata = [
        TestData((LatLon(-11.625000, -0.375000)), 4.578375000),
        TestData((LatLon(-11.625000, -121.875000)), 4.822250000),
        TestData((LatLon(31.875000, 53.625000)), 4.080875000),
        TestData((LatLon(-56.625000, -108.375000)), 0.478062500),
        TestData((LatLon(-61.125000, -156.375000)), 0.599687500),
        TestData((LatLon(6.375000, 175.125000)), 4.794750000),
        TestData((LatLon(61.875000, -99.375000)), 2.584437500),
        TestData((LatLon(-50.625000, -54.375000)), 1.117625000),
        TestData((LatLon(70.875000, -9.375000)), 0.725000000),
        TestData((LatLon(-23.625000, 65.625000)), 4.131875000),
        TestData((LatLon(63.375000, -169.875000)), 0.733875000),
        TestData((LatLon(52.875000, -114.375000)), 2.827875000),
        TestData((LatLon(82.875000, -91.875000)), 1.929187500),
        TestData((LatLon(78.375000, -150.375000)), 2.375187500),
        TestData((LatLon(36.375000, 106.125000)), 4.097562500),
        TestData((LatLon(52.875000, -51.375000)), 2.504750000),
        TestData((LatLon(-82.125000, 8.625000)), 3.088375000),
        TestData((LatLon(1.875000, 52.125000)), 4.575812500),
        TestData((LatLon(6.375000, -126.375000)), 4.718562500),
        TestData((LatLon(81.375000, 97.125000)), 1.631437500),
        TestData((LatLon(-37.125000, -22.875000)), 2.310125000),
        TestData((LatLon(12.375000, -160.875000)), 4.735187500),
        TestData((LatLon(-38.625000, 167.625000)), 2.284250000),
        TestData((LatLon(-14.625000, 73.125000)), 4.673875000),
        TestData((LatLon(-4.125000, -174.375000)), 4.801000000),
        TestData((LatLon(49.875000, 155.625000)), 1.420312500),
        TestData((LatLon(85.875000, 53.625000)), 2.088312500),
        TestData((LatLon(60.375000, 85.125000)), 2.369312500),
        TestData((LatLon(-5.625000, 50.625000)), 4.629437500),
        TestData((LatLon(46.875000, 19.125000)), 2.749250000),]
    println(" ")
    errors = []
    @testset "iturP839 (Itu-R P.839-4) isotherm height: random test" begin
        for testdata in randomdata
            error = abs(ItuRP839.isothermheight(testdata.testinput) - (testdata.answer))
            push!(errors, error)
            @test error < allowableerror
        end
    end
    println("MAX ERROR: $(maximum(errors))\n")

    ituisothermdata = [
        TestData((LatLon(3.133, 101.70)), 4.59797440000),
        TestData((LatLon(22.900, -43.23)), 3.79877866667),
        TestData((LatLon(23.000, 30.00)), 4.16800000000),
        TestData((LatLon(25.780, -80.22)), 4.20946133333),
        TestData((LatLon(28.717, 77.30)), 4.89820404444),
        TestData((LatLon(33.940, 18.43)), 2.20330275556),
        TestData((LatLon(41.900, 12.49)), 2.68749333333),
        TestData((LatLon(51.500, -0.14)), 2.09273333333),
    ]
    errors = []
    @testset "iturP839 (Itu-R P.839-4) isotherm height: itu data test" begin
        for testdata in ituisothermdata
            error = abs(ItuRP839.isothermheight(testdata.testinput) - (testdata.answer))
            push!(errors, error)
            @test error < allowableerror
        end
    end
    println("MAX ERROR: $(maximum(errors))\n")

    iturainheightdata = [
        TestData((LatLon(3.133, 101.70)), 4.95797440000),
        TestData((LatLon(22.900, -43.23)), 4.15877866667),
        TestData((LatLon(23.000, 30.00)), 4.52800000000),
        TestData((LatLon(25.780, -80.22)), 4.56946133333),
        TestData((LatLon(28.717, 77.30)), 5.25820404444),
        TestData((LatLon(33.940, 18.43)), 2.56330275556),
        TestData((LatLon(41.900, 12.49)), 3.04749333333),
        TestData((LatLon(51.500, -0.14)), 2.45273333333),]
    errors = []
    @testset "iturP839 (Itu-R P.839-4) rain height: itu data test" begin
        for testdata in iturainheightdata
            error = abs(ItuRP839.rainheightannual(testdata.testinput) - (testdata.answer))
            push!(errors, error)
            @test error < allowableerror
        end
    end
    println("MAX ERROR: $(maximum(errors))\n")
end

println("\n<===== " * "ITUR P839.4 "^5 * " =====")
testItuRP839()
println("===== " * "ITUR P839.4 "^5 * "=====> \n")
