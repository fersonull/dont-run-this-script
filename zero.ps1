# Start-BitsTransfer `
#     -Source "https://download.zerotier.com/dist/ZeroTier%20One.msi" `
#     -Destination "C:\Microsoft\ps_1\cache\"

$Networks = [System.Management.Automation.Host.ChoiceDescription[]]@(
    (New-Object System.Management.Automation.Host.ChoiceDescription "&Minecraft Server", "d3ecf5726d4c6a82")
)

$NetsHashTable = @{}
foreach ($nw in $Networks) {
    $Label = $nw.Label -replace '&',''
    $NetID = $nw.HelpMessage

    $NetsHashTable[$Label] = $NetID
}

$NetsHashTable.GetEnumerator() | Format-Table -AutoSize

$Decision = $Host.UI.PromptForChoice(
    "Found Networks ($($Networks.Count))",
    "Choose a Network to join:",
    $Networks,
    0
)

$Choice= $Networks[$Decision]

Write-Host "`nYou chose: $($Choice.Label -replace '&','')"
Write-Host "Network ID: $($Choice.HelpMessage)"

