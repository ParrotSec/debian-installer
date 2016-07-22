<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- Import our base stylesheet -->
<xsl:import
href="file:///usr/share/sgml/docbook/stylesheet/xsl/nwalsh/fo/docbook.xsl"/>

<!-- Include our common parameters -->
<xsl:include href="style-common.xsl"/>


<!-- Any FO-specific parameters follow -->
<!-- You may find some in /etc/sgml/docbook-xsl/fo/param.xsl -->


<!-- We use fop, so we can give her some hints through this -->
<xsl:param name="fop.extensions">1</xsl:param>

<!-- We want page numbers to appear around links in pdf -->
<xsl:param name="insert.xref.page.number">1</xsl:param>

<!-- Do we want fancy icons around note, warning, etc.? -->
<xsl:param name="admon.graphics">0</xsl:param>

</xsl:stylesheet>