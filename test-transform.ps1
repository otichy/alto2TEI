Param(
  [string]$SaxonJar = "C:\Users\ondre\SaxonHE10-8J\saxon-he-10.8.jar",
  [string]$Source = "bpt6k9912811_f13.xml",
  [string]$Stylesheet = "alto2tei.xsl",
  [string]$Output = "output-tei.xml"
)

# Run the XSLT transform with Saxon HE.
Write-Host "Running transform..." -ForegroundColor Cyan
java -jar $SaxonJar -s:$Source -xsl:$Stylesheet -o:$Output

# Load the result and perform lightweight structural checks.
[xml]$doc = Get-Content $Output
$ns = New-Object System.Xml.XmlNamespaceManager($doc.NameTable)
$ns.AddNamespace("tei", "http://www.tei-c.org/ns/1.0")

function Assert-Succeeds {
  param(
    [bool]$Condition,
    [string]$Message
  )
  if (-not $Condition) {
    throw $Message
  }
}

Assert-Succeeds ($doc.SelectSingleNode("/tei:TEI", $ns) -ne $null) "Missing TEI root element."
Assert-Succeeds ($doc.SelectSingleNode("/tei:TEI/tei:text/tei:body/tei:ab", $ns).InnerText.Trim().Length -gt 0) "MainZone text is empty."
Assert-Succeeds ($doc.SelectSingleNode("/tei:TEI/tei:text/tei:body/tei:note[@type='runningTitle']", $ns).InnerText.Trim().Length -gt 0) "RunningTitle note is empty."
Assert-Succeeds ($doc.SelectSingleNode("/tei:TEI/tei:text/tei:body/tei:note[@type='margin']", $ns).InnerText.Trim().Length -gt 0) "Margin note is empty."

Write-Host "Transform completed and basic checks passed. Output: $Output" -ForegroundColor Green
