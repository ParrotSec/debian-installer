<?xml version="1.0"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="text"/>

<xsl:template match="language_entries">

<xsl:apply-templates/>
</xsl:template>

<xsl:template match="language_entry">
<xsl:value-of select="@code"/>:<xsl:choose>
	<xsl:when test="string-length(@coord_name)">
		<xsl:value-of select="@coord_name"/>
	</xsl:when>
      </xsl:choose> &lt;<xsl:choose>
	<xsl:when test="string-length(@coord_email)">
		<xsl:value-of select="@coord_email"/>
	</xsl:when>
</xsl:choose>&gt;<xsl:choose>
	<xsl:when test="string-length(@bkp_coord_email)">,<xsl:value-of select="@bkp_coord_email"/>
	</xsl:when>
</xsl:choose>
</xsl:template>
</xsl:transform>
