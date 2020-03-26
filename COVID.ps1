$array = @()

#Grab state numbers for current day
$stateMTPull = invoke-webrequest -uri https://covidtracking.com/api/states/daily?state=MT
$stateMTcontent = $stateMTPull.Content | ConvertFrom-Json
$stateMTCurrentDay =  $stateMTcontent[0]
$date = [datetime]::ParseExact($stateMTCurrentDay.Date, "yyyyMMdd", $null)
$dateFormated = $date.ToString('MM/dd/yyyy')

#Grab US stats and get hospitalization %
$USPull = invoke-webrequest -uri https://covidtracking.com/api/us
$usContent = $uspull.content | ConvertFrom-Json
$hospitalizationPercentageUS = $uscontent.Hospitalized / $usContent.totaltestresults

#calcualte out how many should be hospitalized from whatever $stateMTCurrentDay returns against the national average
$shouldBeHosp = $estHospitalizedMT = $stateMTCurrentDay.Positive * $hospitalizationPercentageUS


#outputs it to gridview for the spreadsheet
$OB = New-Object -TypeName psobject
$OB | Add-Member -MemberType NoteProperty -Name "Confirmed" -Value $stateMTCurrentDay.positive
$OB | Add-Member -MemberType NoteProperty -Name "Date" -Value $dateFormated
$OB | Add-Member -MemberType NoteProperty -Name "TestsNegative" -Value $stateMTCurrentDay.negative
$OB | Add-Member -MemberType NoteProperty -Name "TestsPending" -Value $stateMTCurrentDay.pending
$OB | Add-Member -MemberType NoteProperty -Name "Hospitalized" -Value $stateMTCurrentDay.hospitalized
$OB | Add-Member -MemberType NoteProperty -Name "Deaths" -Value $stateMTCurrentDay.death
$OB | Add-Member -MemberType NoteProperty -Name "Estemated Hospitalized" -Value $shouldBeHosp
$array += $OB
$array | Out-GridView