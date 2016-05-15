<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- Some advanced features, not everybody supports it though -->
<!-- <xsl:param name="use.extensions">1</xsl:param> -->

<!-- Sections are not numbered by default. We want to switch numbering on -->
<xsl:param name="section.autolabel">1</xsl:param>

<!-- We want continuous numbering (don't restart with new chapter) -->
<xsl:param name="section.label.includes.component.label">1</xsl:param>

<!-- We want gray background in examples -->
<xsl:param name="shade.verbatim">1</xsl:param>

</xsl:stylesheet>