# https://www.microsoft.com/en-us/download/details.aspx?id=53595
$head = @"
<style type="text/css">
<!--
table {
    border: 1px solid;
}
td, th {
    border: 1px solid;
}
-->
</style>
"@

[xml]$xml = Get-Content  -Path "${env:ProgramFiles}\Microsoft Data Migration Assistant\RuleMetadataStore.xml"

$html = $xml.RuleMetadataStore.RuleMetadataCollection.RuleMetaData | `
Select RuleSeverity, ChangeCategory, RuleId, DisplayName, Title, Impact, Recommendation, AdditionalInformation | `
ConvertTo-Html -Head $head 
[System.Web.HttpUtility]::HtmlDecode($html)  | Out-File -FilePath ".\DMARules.html" -Force

.\DMARules.html