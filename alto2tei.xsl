<?xml version="1.0" encoding="UTF-8"?>
<!--
  Transform ALTO 4.x into a minimal TEI document.
  - Declares ALTO as the default XPath namespace for concise paths.
  - Lifts text from three zone types: MainZone, RunningTitleZone, MarginTextZone.
  - Outputs a lean TEI skeleton with one <ab> and two <note> elements.
-->
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xpath-default-namespace="http://www.loc.gov/standards/alto/ns-v4#"
  exclude-result-prefixes="xs">

  <!-- Pretty-print XML output for readability. -->
  <xsl:output method="xml" indent="yes"/>

  <!-- Helper: concatenate all String/@CONTENT values within blocks whose TAGREFS include IDs for a given LABEL. -->
  <xsl:function name="tei:zone-text" as="xs:string?">
    <xsl:param name="doc" as="element(alto)"/>
    <xsl:param name="label" as="xs:string"/>
    <xsl:variable name="ids" select="$doc/Tags/OtherTag[@LABEL=$label]/@ID"/>
    <xsl:variable name="blocks" select="$doc/Layout//TextBlock[tokenize(@TAGREFS, '\s+') = $ids]"/>
    <xsl:sequence select="string-join($blocks//String/@CONTENT, ' ')"/>
  </xsl:function>

  <!-- Entry point builds a minimal TEI shell plus the requested content. -->
  <xsl:template match="/">
    <tei:TEI>
      <tei:teiHeader>
        <tei:fileDesc>
          <tei:titleStmt>
            <tei:title>ALTO to TEI (Main + Running Title + Margin)</tei:title>
          </tei:titleStmt>
          <tei:publicationStmt>
            <tei:p>Unpublished; generated via XSLT conversion.</tei:p>
          </tei:publicationStmt>
          <tei:sourceDesc>
            <tei:p>
              Source ALTO file:
              <xsl:value-of select="normalize-space(/alto/Description/sourceImageInformation/fileName)"/>
            </tei:p>
          </tei:sourceDesc>
        </tei:fileDesc>
      </tei:teiHeader>

      <tei:text>
        <tei:body>
          <!-- MainZone text becomes the core paragraph. -->
          <tei:ab>
            <xsl:value-of select="tei:zone-text(/alto, 'MainZone')" disable-output-escaping="no"/>
          </tei:ab>

          <!-- RunningTitleZone captured as a note for consistency. -->
          <tei:note type="runningTitle">
            <xsl:value-of select="tei:zone-text(/alto, 'RunningTitleZone')"/>
          </tei:note>

          <!-- MarginTextZone captured as a note to preserve marginalia. -->
          <tei:note type="margin">
            <xsl:value-of select="tei:zone-text(/alto, 'MarginTextZone')"/>
          </tei:note>
        </tei:body>
      </tei:text>
    </tei:TEI>
  </xsl:template>
</xsl:stylesheet>
