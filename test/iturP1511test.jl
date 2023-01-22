using DelimitedFiles
using Test
using ItuRPropagations

struct TestData
    testinput
    answer
end

function testItuRP1511itu()
    ituRP836allowableerror = 1.0e-6
    ituRP836_6data = [
        TestData(LatLon(3.133, 101.7), 51.2514559528945),
        TestData(LatLon(23.0, 30.0), 187.593750000001),
        TestData(LatLon(25.78, -80.22), 8.61727999508758),
        TestData(LatLon(28.717, 77.3), 209.38369895),
        TestData(LatLon(41.9, 12.49), 46.1229880100015),
        TestData(LatLon(51.5, -0.14), 31.382983999999),
    ]
    println(" ")
    errors = []
    @testset "iturP1511 Topo Height: ITU-R P1511-2 ITU Data" begin
        for testdata in ituRP836_6data
            # topoheight return in km, testdata.answer is in m
            predictedvalue = ItuRP1511.topographicheight(testdata.testinput) * 1_000.0
            testvalue = testdata.answer
            error = abs(predictedvalue - testvalue)
            @test error < ituRP836allowableerror
            push!(errors, error)
        end
    end
    println("Topograhic height MAX: $(maximum(errors)) m\n")
end

println("\n<===== " * "ITUR P1511.2 "^5 * " =====")
testItuRP1511itu()
println("===== " * "ITUR P1511.2 "^5 * "=====> \n")