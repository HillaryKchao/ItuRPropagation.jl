using DelimitedFiles
using Test
using ItuRPropagations

struct TestData
    testinput
    answer
end

function testAScintillation()
    interpolatedallowableerror = 1.0e-5
    # data from P618-13 A_Scint in Validation Excel file (9.5)
    
    Ascinitudata = [
        TestData((LatLon(51.500, -0.140), 14.25, 1.00, 31.0769912357, 1.0, 65.00), 0.261931888971004),
        TestData((LatLon(41.900, 12.490), 14.25, 1.00, 40.2320359964, 1.0, 65.00), 0.224052194804805),
        TestData((LatLon(33.940, 18.430), 14.25, 1.00, 46.3596926119, 1.0, 65.00), 0.232799419720570),
        TestData((LatLon(51.500, -0.140), 14.25, 0.10, 31.0769912357, 1.0, 65.00), 0.422845379428857),
        TestData((LatLon(41.900, 12.490), 14.25, 0.10, 40.2320359964, 1.0, 65.00), 0.361694926479890),
        TestData((LatLon(33.940, 18.430), 14.25, 0.10, 46.3596926119, 1.0, 65.00), 0.375815863235573),
        TestData((LatLon(51.500, -0.140), 14.25, 0.01, 31.0769912357, 1.0, 65.00), 0.628287291011781),
        TestData((LatLon(41.900, 12.490), 14.25, 0.01, 40.2320359964, 1.0, 65.00), 0.537426531271792),
        TestData((LatLon(33.940, 18.430), 14.25, 0.01, 46.3596926119, 1.0, 65.00), 0.558408208103073),
        TestData((LatLon(51.500, -0.140), 20.00, 1.00, 31.0769912357, 1.0, 65.00), 0.316526337653611),
        TestData((LatLon(41.900, 12.490), 20.00, 1.00, 40.2320359964, 1.0, 65.00), 0.270357535365229),
        TestData((LatLon(33.940, 18.430), 20.00, 1.00, 46.3596926119, 1.0, 65.00), 0.280679921764322),
        TestData((LatLon(51.500, -0.140), 20.00, 0.10, 31.0769912357, 1.0, 65.00), 0.510979017752146),
        TestData((LatLon(41.900, 12.490), 20.00, 0.10, 40.2320359964, 1.0, 65.00), 0.436447181257934),
        TestData((LatLon(33.940, 18.430), 20.00, 0.10, 46.3596926119, 1.0, 65.00), 0.453110953701538),
        TestData((LatLon(51.500, -0.140), 20.00, 0.01, 31.0769912357, 1.0, 65.00), 0.759241175251794),
        TestData((LatLon(41.900, 12.490), 20.00, 0.01, 40.2320359964, 1.0, 65.00), 0.648497608162728),
        TestData((LatLon(33.940, 18.430), 20.00, 0.01, 46.3596926119, 1.0, 65.00), 0.673257572338688),
        TestData((LatLon(22.900, -43.230), 14.25, 1.00, 22.2783346841, 1.0, 65.00), 0.620097436074396),
        TestData((LatLon(25.780, -80.220), 14.25, 1.00, 52.6789848590, 1.0, 65.00), 0.266474933645413),
        TestData((LatLon(22.900, -43.230), 14.25, 0.10, 22.2783346841, 1.0, 65.00), 1.001043960969430),
        TestData((LatLon(25.780, -80.220), 14.25, 0.10, 52.6789848590, 1.0, 65.00), 0.430179367881579),
        TestData((LatLon(22.900, -43.230), 14.25, 0.01, 22.2783346841, 1.0, 65.00), 1.487407049997120),
        TestData((LatLon(25.780, -80.220), 14.25, 0.01, 52.6789848590, 1.0, 65.00), 0.639184540837464),
        TestData((LatLon(22.900, -43.230), 20.00, 1.00, 22.2783346841, 1.0, 65.00), 0.750596809110413),
        TestData((LatLon(25.780, -80.220), 20.00, 1.00, 52.6789848590, 1.0, 65.00), 0.321044785033016),
        TestData((LatLon(22.900, -43.230), 20.00, 0.10, 22.2783346841, 1.0, 65.00), 1.211713448840580),
        TestData((LatLon(25.780, -80.220), 20.00, 0.10, 52.6789848590, 1.0, 65.00), 0.518273297971632),
        TestData((LatLon(22.900, -43.230), 20.00, 0.01, 22.2783346841, 1.0, 65.00), 1.800431546119510),
        TestData((LatLon(25.780, -80.220), 20.00, 0.01, 52.6789848590, 1.0, 65.00), 0.770079424365861),
        TestData((LatLon(28.717, 77.300), 14.25, 1.00, 48.2411705405, 1.0, 65.00), 0.215641260468414),
        TestData((LatLon(3.133, 101.700), 14.25, 1.00, 85.8045956575, 1.0, 65.00), 0.221671285226398),
        TestData((LatLon(9.050, 38.700), 14.25, 1.00, 20.1433580863, 1.0, 65.00), 0.485339887394634),
        TestData((LatLon(28.717, 77.300), 14.25, 0.10, 48.2411705405, 1.0, 65.00), 0.348116874816176),
        TestData((LatLon(3.133, 101.700), 14.25, 0.10, 85.8045956575, 1.0, 65.00), 0.357851344783815),
        TestData((LatLon(9.050, 38.700), 14.25, 0.10, 20.1433580863, 1.0, 65.00), 0.783500358217404),
        TestData((LatLon(28.717, 77.300), 14.25, 0.01, 48.2411705405, 1.0, 65.00), 0.517251503443568),
        TestData((LatLon(3.133, 101.700), 14.25, 0.01, 85.8045956575, 1.0, 65.00), 0.531715522829720),
        TestData((LatLon(9.050, 38.700), 14.25, 0.01, 20.1433580863, 1.0, 65.00), 1.164168609897260),
        TestData((LatLon(28.717, 77.300), 20.00, 1.00, 48.2411705405, 1.0, 65.00), 0.259932532395325),
        TestData((LatLon(3.133, 101.700), 20.00, 1.00, 85.8045956575, 1.0, 65.00), 0.266539119270210),
        TestData((LatLon(9.050, 38.700), 20.00, 1.00, 20.1433580863, 1.0, 65.00), 0.587744646101907),
        TestData((LatLon(28.717, 77.300), 20.00, 0.10, 48.2411705405, 1.0, 65.00), 0.419617751463519),
        TestData((LatLon(3.133, 101.700), 20.00, 0.10, 85.8045956575, 1.0, 65.00), 0.430282984875208),
        TestData((LatLon(9.050, 38.700), 20.00, 0.10, 20.1433580863, 1.0, 65.00), 0.948815773690511),
        TestData((LatLon(28.717, 77.300), 20.00, 0.01, 48.2411705405, 1.0, 65.00), 0.623491501038919),
        TestData((LatLon(3.133, 101.700), 20.00, 0.01, 85.8045956575, 1.0, 65.00), 0.639338500756143),
        TestData((LatLon(9.050, 38.700), 20.00, 0.01, 20.1433580863, 1.0, 65.00), 1.409803491116440),
    ]
    println(" ")
    errors = []
    @testset "iturP618 (Itu-R P.618-13) scintillation attenuation As: ITU test data" begin
        for testdata in Ascinitudata
            value = ItuRP618.scintillationattenuation(testdata.testinput...)
            error = abs(value - testdata.answer)
            @test error < interpolatedallowableerror
            push!(errors, error)
        end
    end
    println("Ascintillation MAX ERROR: $(maximum(errors)) dB\n")
end

function testRain()
    allowableerror = 1e-1
    rainheightdata = [
        TestData((LatLon(51.500000, -0.140000), 14.250000, 1.000000, 31.07699123565700, EnumHorizontalPolarization), 0.49531706902299),
        TestData((LatLon(41.900000, 12.490000), 14.250000, 1.000000, 40.23203599636160, EnumHorizontalPolarization), 0.62326300082278),
        TestData((LatLon(33.940000, 18.430000), 14.250000, 1.000000, 46.35969261186340, EnumHorizontalPolarization), 0.42101702485133),
        TestData((LatLon(51.500000, -0.140000), 14.250000, 0.100000, 31.07699123565700, EnumHorizontalPolarization), 2.18584742205216),
        TestData((LatLon(41.900000, 12.490000), 14.250000, 0.100000, 40.23203599636160, EnumHorizontalPolarization), 2.69676513267543),
        TestData((LatLon(33.940000, 18.430000), 14.250000, 0.100000, 46.35969261186340, EnumHorizontalPolarization), 1.91338757191163),
        TestData((LatLon(51.500000, -0.140000), 14.250000, 0.010000, 31.07699123565700, EnumHorizontalPolarization), 6.79807226654774),
        TestData((LatLon(41.900000, 12.490000), 14.250000, 0.010000, 40.23203599636160, EnumHorizontalPolarization), 8.22326500858181),
        TestData((LatLon(33.940000, 18.430000), 14.250000, 0.010000, 46.35969261186340, EnumHorizontalPolarization), 5.94180609616685),
        TestData((LatLon(51.500000, -0.140000), 14.250000, 0.001000, 31.07699123565700, EnumHorizontalPolarization), 14.89982247909140),
        TestData((LatLon(41.900000, 12.490000), 14.250000, 0.001000, 40.23203599636160, EnumHorizontalPolarization), 17.67155766252020),
        TestData((LatLon(33.940000, 18.430000), 14.250000, 0.001000, 46.35969261186340, EnumHorizontalPolarization), 12.98151686733570),
        TestData((LatLon(51.500000, -0.140000), 29.000000, 1.000000, 31.07699123565700, EnumHorizontalPolarization), 2.20778604313018),
        TestData((LatLon(41.900000, 12.490000), 29.000000, 1.000000, 40.23203599636160, EnumHorizontalPolarization), 2.82346563387206),
        TestData((LatLon(33.940000, 18.430000), 29.000000, 1.000000, 46.35969261186340, EnumHorizontalPolarization), 1.96063611295817),
        TestData((LatLon(51.500000, -0.140000), 29.000000, 0.100000, 31.07699123565700, EnumHorizontalPolarization), 8.57005837401297),
        TestData((LatLon(41.900000, 12.490000), 29.000000, 0.100000, 40.23203599636160, EnumHorizontalPolarization), 10.73100773183010),
        TestData((LatLon(33.940000, 18.430000), 29.000000, 0.100000, 46.35969261186340, EnumHorizontalPolarization), 7.80832250816542),
        TestData((LatLon(51.500000, -0.140000), 29.000000, 0.010000, 31.07699123565700, EnumHorizontalPolarization), 23.44444523338890),
        TestData((LatLon(41.900000, 12.490000), 29.000000, 0.010000, 40.23203599636160, EnumHorizontalPolarization), 28.74272193279860),
        TestData((LatLon(33.940000, 18.430000), 29.000000, 0.010000, 46.35969261186340, EnumHorizontalPolarization), 21.24861967911690),
        TestData((LatLon(51.500000, -0.140000), 29.000000, 0.001000, 31.07699123565700, EnumHorizontalPolarization), 45.19865637900720),
        TestData((LatLon(41.900000, 12.490000), 29.000000, 0.001000, 40.23203599636160, EnumHorizontalPolarization), 54.25561152467520),
        TestData((LatLon(33.940000, 18.430000), 29.000000, 0.001000, 46.35969261186340, EnumHorizontalPolarization), 40.68133015510290),
        TestData((LatLon(22.900000, -43.230000), 14.250000, 1.000000, 22.27833468405570, EnumHorizontalPolarization), 1.70690128117124),
        TestData((LatLon(25.780000, -80.220000), 14.250000, 1.000000, 52.67898485903060, EnumHorizontalPolarization), 1.43731252281186),
        TestData((LatLon(22.900000, -43.230000), 14.250000, 0.100000, 22.27833468405570, EnumHorizontalPolarization), 8.27164743807979),
        TestData((LatLon(25.780000, -80.220000), 14.250000, 0.100000, 52.67898485903060, EnumHorizontalPolarization), 6.29724724380841),
        TestData((LatLon(22.900000, -43.230000), 14.250000, 0.010000, 22.27833468405570, EnumHorizontalPolarization), 18.94410355725360),
        TestData((LatLon(25.780000, -80.220000), 14.250000, 0.010000, 52.67898485903060, EnumHorizontalPolarization), 16.42980702992490),
        TestData((LatLon(22.900000, -43.230000), 14.250000, 0.001000, 22.27833468405570, EnumHorizontalPolarization), 29.91171295755590),
        TestData((LatLon(25.780000, -80.220000), 14.250000, 0.001000, 52.67898485903060, EnumHorizontalPolarization), 29.93094769618550),
        TestData((LatLon(22.900000, -43.230000), 29.000000, 1.000000, 22.27833468405570, EnumHorizontalPolarization), 6.81336807857281),
        TestData((LatLon(25.780000, -80.220000), 29.000000, 1.000000, 52.67898485903060, EnumHorizontalPolarization), 6.65485565084259),
        TestData((LatLon(22.900000, -43.230000), 29.000000, 0.100000, 22.27833468405570, EnumHorizontalPolarization), 29.31896843932280),
        TestData((LatLon(25.780000, -80.220000), 29.000000, 0.100000, 52.67898485903060, EnumHorizontalPolarization), 25.56295492013820),
        TestData((LatLon(22.900000, -43.230000), 29.000000, 0.010000, 22.27833468405570, EnumHorizontalPolarization), 59.62576354799020),
        TestData((LatLon(25.780000, -80.220000), 29.000000, 0.010000, 52.67898485903060, EnumHorizontalPolarization), 58.47438336195480),
        TestData((LatLon(22.900000, -43.230000), 29.000000, 0.001000, 22.27833468405570, EnumHorizontalPolarization), 83.59963910315690),
        TestData((LatLon(25.780000, -80.220000), 29.000000, 0.001000, 52.67898485903060, EnumHorizontalPolarization), 93.39562548120770),
        TestData((LatLon(28.717000, 77.300000), 14.250000, 1.000000, 48.24117054051150, EnumVerticalPolarization), 1.27446361306621),
        TestData((LatLon(3.133000, 101.700000), 14.250000, 1.000000, 85.80459565750080, EnumVerticalPolarization), 2.00102665367488),
        TestData((LatLon(9.050000, 38.700000), 14.250000, 1.000000, 20.14335808626120, EnumVerticalPolarization), 1.01235397270698),
        TestData((LatLon(28.717000, 77.300000), 14.250000, 0.100000, 48.24117054051150, EnumVerticalPolarization), 5.48634696858230),
        TestData((LatLon(3.133000, 101.700000), 14.250000, 0.100000, 85.80459565750080, EnumVerticalPolarization), 11.00145491625440),
        TestData((LatLon(9.050000, 38.700000), 14.250000, 0.100000, 20.14335808626120, EnumVerticalPolarization), 5.88107131164706),
        TestData((LatLon(28.717000, 77.300000), 14.250000, 0.010000, 48.24117054051150, EnumVerticalPolarization), 14.87213732579040),
        TestData((LatLon(3.133000, 101.700000), 14.250000, 0.010000, 85.80459565750080, EnumVerticalPolarization), 21.61057916215600),
        TestData((LatLon(9.050000, 38.700000), 14.250000, 0.010000, 20.14335808626120, EnumVerticalPolarization), 12.28976032869100),
        TestData((LatLon(28.717000, 77.300000), 14.250000, 0.001000, 48.24117054051150, EnumVerticalPolarization), 28.23603149313740),
        TestData((LatLon(3.133000, 101.700000), 14.250000, 0.001000, 85.80459565750080, EnumVerticalPolarization), 28.81950408673640),
        TestData((LatLon(9.050000, 38.700000), 14.250000, 0.001000, 20.14335808626120, EnumVerticalPolarization), 17.44199306433560),
        TestData((LatLon(28.717000, 77.300000), 29.000000, 1.000000, 48.24117054051150, EnumVerticalPolarization), 5.88782187083951),
        TestData((LatLon(3.133000, 101.700000), 29.000000, 1.000000, 85.80459565750080, EnumVerticalPolarization), 10.21314770327510),
        TestData((LatLon(9.050000, 38.700000), 29.000000, 1.000000, 20.14335808626120, EnumVerticalPolarization), 3.70158393969583),
        TestData((LatLon(28.717000, 77.300000), 29.000000, 0.100000, 48.24117054051150, EnumVerticalPolarization), 22.22622901942000),
        TestData((LatLon(3.133000, 101.700000), 29.000000, 0.100000, 85.80459565750080, EnumVerticalPolarization), 48.81996806773300),
        TestData((LatLon(9.050000, 38.700000), 29.000000, 0.100000, 20.14335808626120, EnumVerticalPolarization), 19.23910378060920),
        TestData((LatLon(28.717000, 77.300000), 29.000000, 0.010000, 48.24117054051150, EnumVerticalPolarization), 52.83372061576140),
        TestData((LatLon(3.133000, 101.700000), 29.000000, 0.010000, 85.80459565750080, EnumVerticalPolarization), 83.37856226717360),
        TestData((LatLon(9.050000, 38.700000), 29.000000, 0.010000, 20.14335808626120, EnumVerticalPolarization), 35.97037673264470),
        TestData((LatLon(28.717000, 77.300000), 29.000000, 0.001000, 48.24117054051150, EnumVerticalPolarization), 87.96233698741400),
        TestData((LatLon(3.133000, 101.700000), 29.000000, 0.001000, 85.80459565750080, EnumVerticalPolarization), 96.67521081506350),
        TestData((LatLon(9.050000, 38.700000), 29.000000, 0.001000, 20.14335808626120, EnumVerticalPolarization), 45.67419097503200),


    ]    
    errors = []
    @testset "iturP618 (Itu-R P.618-13) rain attenuation: ITU test data" begin
        for testdata in rainheightdata
            value = ItuRP618.rainattenuation(testdata.testinput...)
            error = abs(value - testdata.answer)
            @test error < allowableerror
            push!(errors, error)
        end
    end
    println("Attenuation MAX ERROR: $(maximum(errors)) dB\n")
end



function testXPD()
    allowableerror = 1e-1
    itudata = [
        TestData((LatLon(51.50,-0.14),14.25,1.0000,31.076991235657000000000000,EnumHorizontalPolarization),49.477699444521),
        TestData((LatLon(41.90,12.49),14.25,1.0000,40.232035996361600000000000,EnumHorizontalPolarization),49.377148506422),
        TestData((LatLon(33.94,18.43),14.25,1.0000,46.359692611863400000000000,EnumHorizontalPolarization),53.938570663594),
        TestData((LatLon(51.50,-0.14),14.25,0.1000,31.076991235657000000000000,EnumHorizontalPolarization),40.203026378451),
        TestData((LatLon(41.90,12.49),14.25,0.1000,40.232035996361600000000000,EnumHorizontalPolarization),40.260013719723),
        TestData((LatLon(33.94,18.43),14.25,0.1000,46.359692611863400000000000,EnumHorizontalPolarization),44.682656753034),
        TestData((LatLon(51.50,-0.14),14.25,0.0100,31.076991235657000000000000,EnumHorizontalPolarization),32.887585906060),
        TestData((LatLon(41.90,12.49),14.25,0.0100,40.232035996361600000000000,EnumHorizontalPolarization),33.120273006447),
        TestData((LatLon(33.94,18.43),14.25,0.0100,46.359692611863400000000000,EnumHorizontalPolarization),37.629186814178),
        TestData((LatLon(51.50,-0.14),14.25,0.0010,31.076991235657000000000000,EnumHorizontalPolarization),28.054504739615),
        TestData((LatLon(41.90,12.49),14.25,0.0010,40.232035996361600000000000,EnumHorizontalPolarization),28.481053047487),
        TestData((LatLon(33.94,18.43),14.25,0.0010,46.359692611863400000000000,EnumHorizontalPolarization),33.075103319058),
        TestData((LatLon(51.50,-0.14),29.00,1.0000,31.076991235657000000000000,EnumHorizontalPolarization),44.190517392222),
        TestData((LatLon(41.90,12.49),29.00,1.0000,40.232035996361600000000000,EnumHorizontalPolarization),43.836438512418),
        TestData((LatLon(33.94,18.43),29.00,1.0000,46.359692611863400000000000,EnumHorizontalPolarization),48.369648929624),
        TestData((LatLon(51.50,-0.14),29.00,0.1000,31.076991235657000000000000,EnumHorizontalPolarization),34.928404541993),
        TestData((LatLon(41.90,12.49),29.00,0.1000,40.232035996361600000000000,EnumHorizontalPolarization),34.739990776513),
        TestData((LatLon(33.94,18.43),29.00,0.1000,46.359692611863400000000000,EnumHorizontalPolarization),39.126902825237),
        TestData((LatLon(51.50,-0.14),29.00,0.0100,31.076991235657000000000000,EnumHorizontalPolarization),27.862900264989),
        TestData((LatLon(41.90,12.49),29.00,0.0100,40.232035996361600000000000,EnumHorizontalPolarization),27.860873094480),
        TestData((LatLon(33.94,18.43),29.00,0.0100,46.359692611863400000000000,EnumHorizontalPolarization),32.343668757899),
        TestData((LatLon(51.50,-0.14),29.00,0.0010,31.076991235657000000000000,EnumHorizontalPolarization),23.548934946237),
        TestData((LatLon(41.90,12.49),29.00,0.0010,40.232035996361600000000000,EnumHorizontalPolarization),23.754015846227),
        TestData((LatLon(33.94,18.43),29.00,0.0010,46.359692611863400000000000,EnumHorizontalPolarization),28.333811192171),
        TestData((LatLon(22.90,-43.23),14.25,1.0000,22.278334684055700000000000,EnumHorizontalPolarization),38.650729880165),
        TestData((LatLon(25.78,-80.22),14.25,1.0000,52.678984859030600000000000,EnumHorizontalPolarization),46.239920794586),
        TestData((LatLon(22.90,-43.23),14.25,0.1000,22.278334684055700000000000,EnumHorizontalPolarization),27.963453596075),
        TestData((LatLon(25.78,-80.22),14.25,0.1000,52.678984859030600000000000,EnumHorizontalPolarization),36.834657986173),
        TestData((LatLon(22.90,-43.23),14.25,0.0100,22.278334684055700000000000,EnumHorizontalPolarization),22.644928134071),
        TestData((LatLon(25.78,-80.22),14.25,0.0100,52.678984859030600000000000,EnumHorizontalPolarization),30.868800072357),
        TestData((LatLon(22.90,-43.23),14.25,0.0010,22.278334684055700000000000,EnumHorizontalPolarization),20.292923176067),
        TestData((LatLon(25.78,-80.22),14.25,0.0010,52.678984859030600000000000,EnumHorizontalPolarization),27.632369902851),
        TestData((LatLon(22.90,-43.23),29.00,1.0000,22.278334684055700000000000,EnumHorizontalPolarization),33.646884724984),
        TestData((LatLon(25.78,-80.22),29.00,1.0000,52.678984859030600000000000,EnumHorizontalPolarization),40.086834376043),
        TestData((LatLon(22.90,-43.23),29.00,0.1000,22.278334684055700000000000,EnumHorizontalPolarization),22.854139025594),
        TestData((LatLon(25.78,-80.22),29.00,0.1000,52.678984859030600000000000,EnumHorizontalPolarization),30.675964546246),
        TestData((LatLon(22.90,-43.23),29.00,0.0100,22.278334684055700000000000,EnumHorizontalPolarization),17.882553722006),
        TestData((LatLon(25.78,-80.22),29.00,0.0100,52.678984859030600000000000,EnumHorizontalPolarization),25.042466611704),
        TestData((LatLon(22.90,-43.23),29.00,0.0010,22.278334684055700000000000,EnumHorizontalPolarization),16.169228611235),
        TestData((LatLon(25.78,-80.22),29.00,0.0010,52.678984859030600000000000,EnumHorizontalPolarization),22.427035185086),
        TestData((LatLon(28.72,77.30),14.25,1.0000,48.241170540511500000000000,EnumVerticalPolarization),45.794051782409),
        TestData((LatLon(3.13,101.70),14.25,1.0000,85.804595657500800000000000,EnumVerticalPolarization),74.875777158294),
        TestData((LatLon(9.05,38.70),14.25,1.0000,20.143358086261200000000000,EnumVerticalPolarization),42.526403837859),
        TestData((LatLon(28.72,77.30),14.25,0.1000,48.241170540511500000000000,EnumVerticalPolarization),36.508436515388),
        TestData((LatLon(3.13,101.70),14.25,0.1000,85.804595657500800000000000,EnumVerticalPolarization),65.273303493136),
        TestData((LatLon(9.05,38.70),14.25,0.1000,20.143358086261200000000000,EnumVerticalPolarization),30.564398425943),
        TestData((LatLon(28.72,77.30),14.25,0.0100,48.241170540511500000000000,EnumVerticalPolarization),30.189885819857),
        TestData((LatLon(3.13,101.70),14.25,0.0100,85.804595657500800000000000,EnumVerticalPolarization),63.370501794343),
        TestData((LatLon(9.05,38.70),14.25,0.0100,20.143358086261200000000000,EnumVerticalPolarization),26.192025321070),
        TestData((LatLon(28.72,77.30),14.25,0.0010,48.241170540511500000000000,EnumVerticalPolarization),26.537260642245),
        TestData((LatLon(3.13,101.70),14.25,0.0010,85.804595657500800000000000,EnumVerticalPolarization),64.717261458060),
        TestData((LatLon(9.05,38.70),14.25,0.0010,20.143358086261200000000000,EnumVerticalPolarization),25.008801412376),
        TestData((LatLon(28.72,77.30),29.00,1.0000,48.241170540511500000000000,EnumVerticalPolarization),39.721342845611),
        TestData((LatLon(3.13,101.70),29.00,1.0000,85.804595657500800000000000,EnumVerticalPolarization),67.739321796182),
        TestData((LatLon(9.05,38.70),29.00,1.0000,20.143358086261200000000000,EnumVerticalPolarization),38.523476815820),
        TestData((LatLon(28.72,77.30),29.00,0.1000,48.241170540511500000000000,EnumVerticalPolarization),30.442770190502),
        TestData((LatLon(3.13,101.70),29.00,0.1000,85.804595657500800000000000,EnumVerticalPolarization),58.023471337021),
        TestData((LatLon(9.05,38.70),29.00,0.1000,20.143358086261200000000000,EnumVerticalPolarization),26.349497925519),
        TestData((LatLon(28.72,77.30),29.00,0.0100,48.241170540511500000000000,EnumVerticalPolarization),24.437965241337),
        TestData((LatLon(3.13,101.70),29.00,0.0100,85.804595657500800000000000,EnumVerticalPolarization),56.633772641015),
        TestData((LatLon(9.05,38.70),29.00,0.0100,20.143358086261200000000000,EnumVerticalPolarization),22.356293521661),
        TestData((LatLon(28.72,77.30),29.00,0.0010,48.241170540511500000000000,EnumVerticalPolarization),21.383360195039),
        TestData((LatLon(3.13,101.70),29.00,0.0010,85.804595657500800000000000,EnumVerticalPolarization),58.824705116650),
        TestData((LatLon(9.05,38.70),29.00,0.0010,20.143358086261200000000000,EnumVerticalPolarization),21.851235725655),

    ]    
    errors = []
    @testset "iturP618 (Itu-R P.618-13) XPD: ITU test data" begin
        for testdata in itudata
            ap = ItuRP618.rainattenuation(testdata.testinput...)
            value = ItuRP618.crosspolarizationdiscrimination(testdata.testinput[2], testdata.testinput[3], testdata.testinput[4], ap, testdata.testinput[5])
            error = abs(value - testdata.answer)
            @test error < allowableerror
            push!(errors, error)
        end
    end
    println("XPD rain MAX ERROR: $(maximum(errors)) dB\n")
end

println("\n<===== " * "ITUR P618.13 "^5 * " =====")
testAScintillation()
testRain()
testXPD()
println("===== " * "ITUR P618.13 "^5 * "=====> \n")
