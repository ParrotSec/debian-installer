<?xml version="1.0"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html"/>

<xsl:template match="language_entries">
<html>
<head>
<title>Debian-Installer languages support, statistics and translators</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
</head>
<body>
<p align="center"><strong>World population coverage</strong></p>
  <table border="1" align="center">
    <tr>
      <th>
Debian releases
      </th>
      <th>
Potato
      </th>
      <th>
Woody
      </th>
      <th>
Sarge
      </th>
      <th>
Etch
      </th>
      <th>
Lenny
      </th>
      <th>
Squeeze
      </th>
      <th>
Wheezy
      </th>
      <th>
Work in progress
      </th>
    </tr>
    <tr>
      <td>
Number of supported languages
      </td>
      <td align="center">
<xsl:value-of select="count(//language_entry[@supported = 'potato'])"/>
      </td>
      <td align="center">
        <xsl:value-of select="count(//language_entry[@supported = 'woody'] | //language_entry[@supported = 'potato'])"/>
      </td>
      <td align="center">
<xsl:value-of select="count(//language_entry[@supported = 'sarge'] | //language_entry[@supported = 'woody'] | //language_entry[@supported = 'potato'])"/>
      </td>
      <td align="center">
<xsl:value-of select="count(//language_entry[@supported = 'etch'] | //language_entry[@supported = 'sarge'] | //language_entry[@supported = 'woody'] | //language_entry[@supported = 'potato'])"/>
      </td>
      <td align="center">
<xsl:value-of select="count(//language_entry[@supported = 'lenny'] | //language_entry[@supported = 'etch'] | //language_entry[@supported = 'sarge'] | //language_entry[@supported = 'woody'] | //language_entry[@supported = 'potato'])"/>
      </td>
      <td align="center">
<xsl:value-of select="count(//language_entry[@supported = 'squeeze'] | //language_entry[@supported = 'lenny'] | //language_entry[@supported = 'etch'] | //language_entry[@supported = 'sarge'] | //language_entry[@supported = 'woody'] | //language_entry[@supported = 'potato'])"/>
      </td>
      <td align="center">
<xsl:value-of select="count(//language_entry[@supported = 'wheezy'] | //language_entry[@supported = 'squeeze'] | //language_entry[@supported = 'lenny'] | //language_entry[@supported = 'etch'] | //language_entry[@supported = 'sarge'] | //language_entry[@supported = 'woody'] | //language_entry[@supported = 'potato'])"/>
      </td>
      <td align="center">
<xsl:value-of select="count(//language_entry)"/>
      </td>
    </tr>
    <tr>
      <td>
Percent world population
      </td>
      <td align="center">
<xsl:value-of select="round(sum(//@speakers[../@supported = 'potato']) div 6892758426 * 100)"/> to <xsl:value-of select="round(sum(//@speakers_corr[../@supported = 'potato']) div 6892758426 * 100)"/>%.
      </td>
      <td align="center">
<xsl:value-of select="round(sum(//@speakers[../@supported = 'woody'] | //@speakers[../@supported = 'potato']) div 6892758426 * 100)"/> to <xsl:value-of select="round(sum(//@speakers_corr[../@supported = 'woody'] | //@speakers_corr[../@supported = 'potato']) div 6892758426 * 100)"/>%
      </td>
      <td align="center">
<xsl:value-of select="round(sum(//@speakers[../@supported = 'sarge'] | //@speakers[../@supported = 'woody'] | //@speakers[../@supported = 'potato']) div 6892758426 * 100)"/> to <xsl:value-of select="round(sum(//@speakers_corr[../@supported = 'sarge'] | //@speakers_corr[../@supported = 'woody'] | //@speakers_corr[../@supported = 'potato']) div 6892758426 * 100)"/>%
      </td>
      <td align="center">
<xsl:value-of select="round(sum(//@speakers[../@supported = 'etch'] | //@speakers[../@supported = 'sarge'] | //@speakers[../@supported = 'woody'] | //@speakers[../@supported = 'potato']) div 6892758426 * 100)"/> to <xsl:value-of select="round(sum(//@speakers_corr[../@supported = 'etch'] | //@speakers_corr[../@supported = 'sarge'] | //@speakers_corr[../@supported = 'woody'] | //@speakers_corr[../@supported = 'potato']) div 6892758426 * 100)"/>%
      </td>
      <td align="center">
<xsl:value-of select="round(sum(//@speakers[../@supported = 'lenny'] | //@speakers[../@supported = 'etch'] | //@speakers[../@supported = 'sarge'] | //@speakers[../@supported = 'woody'] | //@speakers[../@supported = 'potato']) div 6892758426 * 100)"/> to <xsl:value-of select="round(sum(//@speakers_corr[../@supported = 'etch'] | //@speakers_corr[../@supported = 'sarge'] | //@speakers_corr[../@supported = 'woody'] | //@speakers_corr[../@supported = 'potato']) div 6892758426 * 100)"/>%
      </td>
      <td align="center">
<xsl:value-of select="round(sum(//@speakers[../@supported = 'squeeze'] | //@speakers[../@supported = 'lenny'] | //@speakers[../@supported = 'etch'] | //@speakers[../@supported = 'sarge'] | //@speakers[../@supported = 'woody'] | //@speakers[../@supported = 'potato']) div 6892758426 * 100)"/> to <xsl:value-of select="round(sum(//@speakers_corr[../@supported = 'etch'] | //@speakers_corr[../@supported = 'sarge'] | //@speakers_corr[../@supported = 'woody'] | //@speakers_corr[../@supported = 'potato']) div 6892758426 * 100)"/>%
      </td>
      <td align="center">
<xsl:value-of select="round(sum(//@speakers[../@supported = 'wheezy'] | //@speakers[../@supported = 'squeeze'] | //@speakers[../@supported = 'lenny'] | //@speakers[../@supported = 'etch'] | //@speakers[../@supported = 'sarge'] | //@speakers[../@supported = 'woody'] | //@speakers[../@supported = 'potato']) div 6892758426 * 100)"/> to <xsl:value-of select="round(sum(//@speakers_corr[../@supported = 'etch'] | //@speakers_corr[../@supported = 'sarge'] | //@speakers_corr[../@supported = 'woody'] | //@speakers_corr[../@supported = 'potato']) div 6892758426 * 100)"/>%
      </td>
      <td align="center">
<xsl:value-of select="round(sum(//@speakers) div 6892758426 * 100)"/> to <xsl:value-of select="round(sum(//@speakers_corr) div 6892758426 * 100)"/>%
      </td>
    </tr>
</table>

<!--
<p align="center"><strong>World geographical coverage</strong></p>
  <table border="1" align="center">
  <tr>
    <th>
Releases
    </th>
    <th>
Official
    </th>
    <th>
Most widely spoken
    </th>
  </tr>
  <tr>
    <td colspan="3">
<em>Official</em>: countries where one of the official languages is supported:
<br></br>
<em>Most widely spoken</em>: countries where the most widely spoken language is supported:
    </td>
</tr>
  <tr>
      <td align="center">
Potato
      </td>
      <td align="center">
<xsl:variable name="codes">
  <xsl:for-each select="//@countries_official[../@supported = 'potato']">
<xsl:value-of select="string()"/>
</xsl:for-each>
</xsl:variable>
<img src="http://www.world66.com/community/mymaps/worldmap?visited={$codes}" width="200" height="100"/>
      </td>
      <td align="center">
<xsl:variable name="codes">
  <xsl:for-each select="//@countries_most_spoken[../@supported = 'potato']">
<xsl:value-of select="string()"/>
</xsl:for-each>
</xsl:variable>
<img src="http://www.world66.com/community/mymaps/worldmap?visited={$codes}" width="200" height="100"/>
      </td>
    </tr>
    <tr>
      <td align="center">
Woody
      </td>
      <td align="center">
<xsl:variable name="codes">
  <xsl:for-each select="//@countries_official[../@supported = 'woody'] | //@countries_official[../@supported = 'potato']">
<xsl:value-of select="string()"/>
</xsl:for-each>
</xsl:variable>
<img src="http://www.world66.com/community/mymaps/worldmap?visited={$codes}" width="200" height="100"/>
      </td>
      <td align="center">
<xsl:variable name="codes">
  <xsl:for-each select="//@countries_most_spoken[../@supported = 'woody'] | //@countries_most_spoken[../@supported = 'potato']">
<xsl:value-of select="string()"/>
</xsl:for-each>
</xsl:variable>
<img src="http://www.world66.com/community/mymaps/worldmap?visited={$codes}" width="200" height="100"/>
      </td>
  </tr>
  <tr>
      <td align="center">
Sarge
      </td>
      <td align="center">
<xsl:variable name="codes">
  <xsl:for-each select="//@countries_official[../@supported = 'sarge'] | //@countries_official[../@supported = 'woody'] | //@countries_official[../@supported = 'potato']">
<xsl:value-of select="string()"/>
</xsl:for-each>
</xsl:variable>
<img src="http://www.world66.com/community/mymaps/worldmap?visited={$codes}" width="200" height="100"/>
      </td>
      <td align="center">
<xsl:variable name="codes">
  <xsl:for-each select="//@countries_most_spoken[../@supported = 'sarge'] | //@countries_most_spoken[../@supported = 'woody'] | //@countries_most_spoken[../@supported = 'potato']">
<xsl:value-of select="string()"/>
</xsl:for-each>
</xsl:variable>
<img src="http://www.world66.com/community/mymaps/worldmap?visited={$codes}" width="200" height="100"/>
      </td>
    </tr>

    <tr>
      <td align="center">
Etch
      </td>
      <td align="center">
<xsl:variable name="codes">
  <xsl:for-each select="//@countries_official[../@supported = 'etch'] | //@countries_official[../@supported = 'sarge'] | //@countries_official[../@supported = 'woody'] | //@countries_official[../@supported = 'potato']">
<xsl:value-of select="string()"/>
</xsl:for-each>
</xsl:variable>
<img src="http://www.world66.com/community/mymaps/worldmap?visited={$codes}" width="200" height="100"/>
      </td>
      <td align="center">
<xsl:variable name="codes">
  <xsl:for-each select="//@countries_most_spoken[../@supported = 'etch'] | //@countries_most_spoken[../@supported = 'sarge'] | //@countries_most_spoken[../@supported = 'woody'] | //@countries_most_spoken[../@supported = 'potato']">
<xsl:value-of select="string()"/>
</xsl:for-each>
</xsl:variable>
<img src="http://www.world66.com/community/mymaps/worldmap?visited={$codes}" width="200" height="100"/>
      </td>
    </tr>
    <tr>
      <td align="center">
Lenny
      </td>
      <td align="center">
<xsl:variable name="codes">
  <xsl:for-each select="//@countries_official[../@supported = 'lenny'] | //@countries_official[../@supported = 'etch'] | //@countries_official[../@supported = 'sarge'] | //@countries_official[../@supported = 'woody'] | //@countries_official[../@supported = 'potato']">
<xsl:value-of select="string()"/>
</xsl:for-each>
</xsl:variable>
<img src="http://www.world66.com/community/mymaps/worldmap?visited={$codes}" width="200" height="100"/>
      </td>
      <td align="center">
<xsl:variable name="codes">
  <xsl:for-each select="//@countries_most_spoken[../@supported = 'lenny'] | //@countries_most_spoken[../@supported = 'etch'] | //@countries_most_spoken[../@supported = 'sarge'] | //@countries_most_spoken[../@supported = 'woody'] | //@countries_most_spoken[../@supported = 'potato']">
<xsl:value-of select="string()"/>
</xsl:for-each>
</xsl:variable>
<img src="http://www.world66.com/community/mymaps/worldmap?visited={$codes}" width="200" height="100"/>
      </td>
    </tr>
    <tr>
      <td align="center">
Squeeze
      </td>
      <td align="center">
<xsl:variable name="codes">
  <xsl:for-each select="//@countries_official[../@supported = 'squeeze'] | //@countries_official[../@supported = 'lenny'] | //@countries_official[../@supported = 'etch'] | //@countries_official[../@supported = 'sarge'] | //@countries_official[../@supported = 'woody'] | //@countries_official[../@supported = 'potato']">
<xsl:value-of select="string()"/>
</xsl:for-each>
</xsl:variable>
<img src="http://www.world66.com/community/mymaps/worldmap?visited={$codes}" width="200" height="100"/>
      </td>
      <td align="center">
<xsl:variable name="codes">
  <xsl:for-each select="//@countries_most_spoken[../@supported = 'squeeze'] |  //@countries_most_spoken[../@supported = 'lenny'] | //@countries_most_spoken[../@supported = 'etch'] | //@countries_most_spoken[../@supported = 'sarge'] | //@countries_most_spoken[../@supported = 'woody'] | //@countries_most_spoken[../@supported = 'potato']">
<xsl:value-of select="string()"/>
</xsl:for-each>
</xsl:variable>
<img src="http://www.world66.com/community/mymaps/worldmap?visited={$codes}" width="200" height="100"/>
      </td>
    </tr>
    <tr>
      <td align="center">
Wheezy
      </td>
      <td align="center">
<xsl:variable name="codes">
  <xsl:for-each select="/@countries_official[../@supported = 'wheezy'] | //@countries_official[../@supported = 'squeeze'] | //@countries_official[../@supported = 'lenny'] | //@countries_official[../@supported = 'etch'] | //@countries_official[../@supported = 'sarge'] | //@countries_official[../@supported = 'woody'] | //@countries_official[../@supported = 'potato']">
<xsl:value-of select="string()"/>
</xsl:for-each>
</xsl:variable>
<img src="http://www.world66.com/community/mymaps/worldmap?visited={$codes}" width="200" height="100"/>
      </td>
      <td align="center">
<xsl:variable name="codes">
  <xsl:for-each select="/@countries_most_spoken[../@supported = 'wheezy'] |  //@countries_most_spoken[../@supported = 'squeeze'] |  //@countries_most_spoken[../@supported = 'lenny'] | //@countries_most_spoken[../@supported = 'etch'] | //@countries_most_spoken[../@supported = 'sarge'] | //@countries_most_spoken[../@supported = 'woody'] | //@countries_most_spoken[../@supported = 'potato']">
<xsl:value-of select="string()"/>
</xsl:for-each>
</xsl:variable>
<img src="http://www.world66.com/community/mymaps/worldmap?visited={$codes}" width="200" height="100"/>
      </td>
    </tr>
    <tr>
      <td align="center">
Future
      </td>
      <td align="center">
<xsl:variable name="codes">
  <xsl:for-each select="//@countries_official">
<xsl:value-of select="string()"/>
</xsl:for-each>
</xsl:variable>
<img src="http://www.world66.com/community/mymaps/worldmap?visited={$codes}" width="200" height="100"/>
      </td>
      <td align="center">
<xsl:variable name="codes">
  <xsl:for-each select="//@countries_most_spoken">
<xsl:value-of select="string()"/>
</xsl:for-each>
</xsl:variable>
<img src="http://www.world66.com/community/mymaps/worldmap?visited={$codes}" width="200" height="100"/>
      </td>
    </tr>
    
</table>
-->

<p align="center"><strong><a href="http://www.debian.org/devel/debian-installer">Debian Installer</a> translators and translation teams</strong></p>
  <p></p>

<table border="1">
<tr>
<th>Code</th>
<th>Language</th>
<th>Supported</th>
<th>Coordinator for installer</th>
<th>Backup Coordinator / translator for installer</th>
<th>Coordinator for installation-guide</th>
<th>Number of Speakers (Ethnologue)</th>
<th>Number of Speakers (Ethnologue <em>corrected</em>)</th>
<th>Repository</th>
</tr>
<xsl:apply-templates/>
</table>



<p><strong>References:</strong></p>
<ul>
  <li>
  Number of speakers per language: <strong>Gordon,
     Raymond G., Jr. (ed.), 2005.</strong> <em>Ethnologue: Languages of the World, Fifteenth
     edition.</em> Dallas, Tex.: SIL International. Online version:
     <a href="http://www.ethnologue.com/">http://www.ethnologue.com/</a>.
     <br></br>
       Please note that Ethnologue refers to a number of
       <strong>native</strong> speakers of a given language. This
       explains some very low numbers and also explains why, while we
       are currently covering all major languages of the world, we
       "only" cover less than 60% of the world population. Having
       numbers for people who are completely literate in a given
       language is far less easier and estimations often vary
       considerably. For instance, English has an estimate of 300M up
       to 500M "speakers" (310M for Ethnologue), depending on sources,
       while French has 80M to 135M (Ethnologue gives a very low
       number or 64M which is roughly the population of France
       alone).
   </li>
  <li>
<em>Corrected</em> number of speakers: above data <em>corrected</em>
by Debian Installer developers when they feel it to be
badly representing reality.
   </li>
  <li>
    World population: <a href="http://www.geohive.com">www.geohive.com</a> as of 2011-04-21 (link dead)
   </li>
  <li>
    Maps: <a href="http://www.world66.com/myworld66/visitedCountries">Visited countries</a> (link dead)
   </li>
  <li>
    XSL Transform wizardry courtesy of Eugeniy Meshcheryakov
   </li>
  <li>
    Data collected by Christian Perrier
   </li>
</ul>
</body>
</html>
</xsl:template>

<xsl:template match="language_entry">
<tr>
<td><xsl:value-of select="@code"/></td>
<xsl:choose>
	<xsl:when test="string-length(@team_email)">
		<td><a href="mailto:{@team_email}"><xsl:value-of select="@english_name"/></a></td>
	</xsl:when>
	<xsl:otherwise>
		<td><xsl:value-of select="@english_name"/></td>
	</xsl:otherwise>
</xsl:choose>
<td>
<xsl:choose>
	<xsl:when test="@supported = 'true'">
		SUPPORTED
	</xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="@nlp_step"/>&#160;
	</xsl:otherwise>
</xsl:choose>
</td>
<td>
<xsl:if test="string-length(@coord_name)">
	<xsl:value-of select="@coord_name"/>
</xsl:if>
&#160;
</td>
<td>
<xsl:if test="string-length(@bkp_coord_name)">
	<xsl:value-of select="@bkp_coord_name"/>
</xsl:if>
&#160;
</td>
<td>
<xsl:if test="string-length(@manual_coord_name)">
	<xsl:value-of select="@manual_coord_name"/>
</xsl:if>
&#160;
</td>
<td><xsl:value-of select="@speakers"/>&#160;</td>
<td><xsl:value-of select="@speakers_corr"/>&#160;</td>
<td><xsl:value-of select="@team_repository"/>&#160;</td>
</tr>
</xsl:template>
</xsl:transform>
