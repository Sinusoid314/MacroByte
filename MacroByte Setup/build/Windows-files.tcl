# options: -translation lf -encoding utf-8

proc ::InstallJammer::InitFiles {} {
    File ::C8B987E4-36B6-4A99-9EC9-335184CD5B82 -name Distribution -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%> -type dir -attributes 0000 -filemethod 0
    File ::1AC4EED2-6994-46D3-B384-B6A216D9DDE4 -name Compiler -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Compiler -type dir -attributes 0000 -filemethod 0
    File ::F296AFB3-A525-41D7-8B38-7AF8DE07EB62 -name Compiler.exe -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Compiler -size 217600 -mtime 1300862204 -attributes 1000 -filemethod 0
    File ::0433FE11-9F7B-4D56-913F-6DD102EB4E48 -name MBRData.txt -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Compiler -size 545 -mtime 1301167787 -attributes 1000 -filemethod 0
    File ::1A083D0F-343E-4BC0-B847-8AE6C63F194D -name Editor -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor -type dir -attributes 0000 -filemethod 0
    File ::1B17634D-1462-4211-96CF-E1D04BA09775 -name Editor.exe -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor -size 83968 -mtime 1300862247 -attributes 1000 -filemethod 0
    File ::819B2051-8735-4BD8-915C-0A07289E69D0 -name mbcRes.txt -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor -size 23 -mtime 1301167787 -attributes 1000 -filemethod 0
    File ::5D1D8152-29A8-4C74-AD32-7A3CAE707CE4 -name tmpSrc.bas -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor -size 173 -mtime 1301167787 -attributes 1000 -filemethod 0
    File ::BF466CB9-A6B9-4FA9-80B5-5A63A00D2A0B -name Examples -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -type dir -attributes 0000 -filemethod 0
    File ::98A167F6-9D33-45C7-99CA-48D4406ECB71 -name abs.bas -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -size 230 -mtime 1299751056 -attributes 1000 -filemethod 0
    File ::D49C7039-F837-4860-A562-A1022872442D -name examp1.bas -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -size 96 -mtime 1282010965 -attributes 1000 -filemethod 0
    File ::1580503D-A6F1-4746-B114-B33FC58D845B -name examp2.bas -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -size 197 -mtime 1283755307 -attributes 1000 -filemethod 0
    File ::25C8FC78-D0D6-4216-92AB-447A44D315F7 -name examp3.bas -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -size 279 -mtime 1284513543 -attributes 1000 -filemethod 0
    File ::4CC7FDC2-9604-4085-A981-8045AEE2FF72 -name examp4.bas -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -size 337 -mtime 1284513754 -attributes 1000 -filemethod 0
    File ::2612FA5E-FCB8-467A-8C37-EB03ECF40CDD -name examp5.bas -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -size 275 -mtime 1286587845 -attributes 1000 -filemethod 0
    File ::F9E4186D-6B76-4AB0-AEB3-8674306A90B2 -name examp6.bas -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -size 408 -mtime 1285116661 -attributes 1000 -filemethod 0
    File ::19809CE1-1520-4B72-91BC-6208D452EAD7 -name examp7.bas -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -size 141 -mtime 1299750966 -attributes 1000 -filemethod 0
    File ::20DD4781-5491-4555-9EAB-6C98A9C0404C -name examp8.bas -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -size 294 -mtime 1285117006 -attributes 1000 -filemethod 0
    File ::60419419-B7FE-4496-9199-C857ADE6C73A -name example9.bas -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -size 171 -mtime 1290325500 -attributes 1000 -filemethod 0
    File ::54142DD1-2FEB-46C0-A90F-4EE17F623815 -name example10.bas -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -size 204 -mtime 1292370920 -attributes 1000 -filemethod 0
    File ::03587A81-0AE0-443A-B225-9F73D4DD638D -name example11.bas -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -size 302 -mtime 1292371126 -attributes 1000 -filemethod 0
    File ::A8074ABC-E3AA-4F9D-9142-2B1028781110 -name example12.bas -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -size 424 -mtime 1292372619 -attributes 1000 -filemethod 0
    File ::19B288AA-9341-440F-940F-F9EFC470D9D8 -name example13.bas -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -size 168 -mtime 1298885507 -attributes 1000 -filemethod 0
    File ::976168AC-59BE-4EC3-B6F1-ADFD56C6C8AC -name Examples.txt -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -size 63 -mtime 1264757748 -attributes 1000 -filemethod 0
    File ::834B8E44-9F8E-4D78-A4CA-EEE48C3271EB -name files1.bas -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -size 513 -mtime 1299652931 -attributes 1000 -filemethod 0
    File ::16C9B5BF-30E3-44ED-BF21-AEDA195C9EB0 -name files2.bas -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -size 813 -mtime 1299652169 -attributes 1000 -filemethod 0
    File ::D4A5B664-BD32-4DC9-9A5D-B0361C9370F7 -name files3.bas -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -size 1250 -mtime 1299659614 -attributes 1000 -filemethod 0
    File ::FB82D72F-4593-4EEA-8A4C-9FD52D2D36CC -name FizzBuzz.bas -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -size 602 -mtime 1285117105 -attributes 1000 -filemethod 0
    File ::CA3C544B-B760-4565-8938-B21AB8B49E8D -name HiLo.bas -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -size 898 -mtime 1284248796 -attributes 1000 -filemethod 0
    File ::BEAD3289-CC82-4E33-A051-5EFC7A15D444 -name LetterCount.bas -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -size 1012 -mtime 1301044441 -attributes 1000 -filemethod 0
    File ::B4F2C1A7-A74D-4863-AD2F-FF6A7FCF09FD -name MBRData.txt -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -size 1366 -mtime 1260836559 -attributes 1000 -filemethod 0
    File ::F1122874-9297-4208-A99D-3BBC11BD522D -name not.bas -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -size 304 -mtime 1299751985 -attributes 1000 -filemethod 0
    File ::C586B804-43B5-454A-8516-F024BEE83176 -name Runtime.bas -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -size 768 -mtime 1260341802 -attributes 1000 -filemethod 0
    File ::DBBA9A95-4CF0-4284-8F4D-4E1B7C5385B5 -name testFile.txt -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Examples -size 41 -mtime 1299660794 -attributes 1000 -filemethod 0
    File ::12085527-1EA1-425A-8D0D-444136AD634A -name Help -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Help -type dir -attributes 0000 -filemethod 0
    File ::E5D11484-9446-457B-8BE2-F433D57FB38B -name {Macrobyte v1.0 Help.chm} -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Editor/Help -size 19723 -mtime 1300787753 -attributes 1000 -filemethod 0
    File ::AA018639-6633-4F0E-BC7A-34AE367FC6CC -name Runtime -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Runtime -type dir -attributes 0000 -filemethod 0
    File ::C0884550-A1B2-4098-96D9-ED61CF37AA76 -name mbcDat.mbr -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Runtime -size 574 -mtime 1301167787 -attributes 1000 -filemethod 0
    File ::09FF266D-3C3A-48BB-B92F-61840E7952B3 -name Run.exe -parent B5C7506B-8444-4685-8CCA-2E041A8BB55B -directory <%InstallDir%>/Runtime -size 573407 -mtime 1301985473 -attributes 1000 -filemethod 0

}
