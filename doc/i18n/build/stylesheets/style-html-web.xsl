<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- Import our general html stylesheet -->
<xsl:include href="style-html.xsl"/>

<!-- What extention to use for resulting html. -->
<xsl:param name="html.ext" select="concat('.html.',/book/@lang)"/>

</xsl:stylesheet>
