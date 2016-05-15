<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="db2latex/docbook.xsl"/>
	<xsl:variable name="latex.use.fancyhdr">0</xsl:variable>
	<xsl:template name="latex.thead.row.entry">
		<xsl:text>{\sc\sffamily\bfseries </xsl:text>
		<xsl:apply-templates/>
		<xsl:text>}</xsl:text>
	</xsl:template>

	<xsl:template name="latex.tbody.row.entry">
		<xsl:text>{\textsf{ </xsl:text>
		<xsl:apply-templates/>
		<xsl:text>}}</xsl:text>
	</xsl:template>


	<xsl:param name="latex.hyperref.param.common">bookmarksnumbered,colorlinks,backref,bookmarks,breaklinks,linktocpage,plainpages=false,unicode</xsl:param>
	<xsl:variable name="latex.document.font">default</xsl:variable>
	<xsl:param name="tfoot.frame">1</xsl:param>
	<xsl:param name="latex.math.support">0</xsl:param>
	<xsl:param name="latex.use.ltxtable">1</xsl:param>
	<xsl:param name="latex.book.preamble.post.l10n"/>
	<xsl:param name="latex.book.preamble.post">
	    <xsl:text>\usepackage[rm,bf,compact,medium]{titlesec}&#10;</xsl:text>
    	    <xsl:text>\titleformat{\chapter}[display]{\bfseries\Large}{\filleft{\chaptertitlename}
			{\thechapter}}{2ex}{\titlerule\vspace{1ex}\filright}[\vspace{1ex}\titlerule]</xsl:text>
<!--	    <xsl:text>\usepackage{lmodern}</xsl:text> -->
	    <xsl:value-of select="$latex.book.preamble.post.l10n"/>
        </xsl:param>
	<xsl:param name="latex.book.title.style" />
	<xsl:template name="latex.fancyvrb.options">
		<xsl:text>frame=lines</xsl:text>
	</xsl:template>
	<xsl:param name="latex.documentclass.book">a4paper,10pt,twoside,openright</xsl:param>
	<xsl:param name="admon.graphics.path" />
	<xsl:param name="latex.url.quotation">1</xsl:param>
	<xsl:param name="latex.hyphenation.tttricks">0</xsl:param>
	<xsl:param name="latex.use.url">0</xsl:param>
	<xsl:param name="latex.admonition.title.style">\bfseries \large</xsl:param>
	<xsl:param name="latex.use.parskip">1</xsl:param>
	<xsl:param name="latex.inline.monoseq.style">\bfseries </xsl:param>
	
        <xsl:template match="filename">
            <xsl:call-template name="inline.boldseq">
                <xsl:with-param name="hyphenation">\docbookhyphenatefilename</xsl:with-param>
            </xsl:call-template>
        </xsl:template>
	
	<xsl:template name="generate.typeset.url">
	<xsl:param name="hyphenation"/>
	<xsl:param name="url" select="@url"/>
	<xsl:param name="prepend" select="' '"/>
	<xsl:value-of select="$prepend"/>
	<xsl:if test="$latex.url.quotation=1">
		<xsl:call-template name="gentext.dingbat">
		<xsl:with-param name="dingbat">urlstartquote</xsl:with-param>
		</xsl:call-template>
	</xsl:if>
	<xsl:text>\href{</xsl:text>
	<xsl:call-template name="scape-href">
	<xsl:with-param name="string" select="$url"/>
	</xsl:call-template>
	<xsl:text>}{\sffamily\textbf{</xsl:text>
	<xsl:call-template name="generate.string.url">
	<xsl:with-param name="hyphenation" select="$hyphenation"/>
	<xsl:with-param name="string" select="$url"/>
	</xsl:call-template>
	<xsl:text>}}</xsl:text>
	<xsl:if test="$latex.url.quotation=1">
	<xsl:call-template name="gentext.dingbat">
	<xsl:with-param name="dingbat">urlendquote</xsl:with-param>
	</xsl:call-template>
	</xsl:if>
	</xsl:template>

	<xsl:param name="latex.admonition.environment">
		<xsl:text>\newenvironment{admminipage}[1]</xsl:text>
		<xsl:text>{ \begin{minipage}{#1}</xsl:text>
		<xsl:text>}</xsl:text>
		
		<xsl:text>{ </xsl:text>
		<xsl:text> \end{minipage}</xsl:text>
		<xsl:text>}</xsl:text>

		<xsl:text>\newlength{\admlength}</xsl:text>
		<xsl:text>\newlength{\leftskiplength}</xsl:text>
		<xsl:text>\newenvironment{admonition}[2]</xsl:text>
		<xsl:text>{</xsl:text>
		<xsl:text> \hspace{0mm}\newline&#10;</xsl:text>
		<xsl:text> \noindent </xsl:text>
		<xsl:text>\rule{\textwidth}{.5pt}\vspace{1em} </xsl:text>
		<xsl:text> \setlength{\admlength}{\textwidth}</xsl:text>
		<xsl:text> \admminipage{\admlength} </xsl:text>
		
		<xsl:text>\settowidth{\leftskiplength}{#2} { </xsl:text>
		<xsl:value-of select="$latex.admonition.title.style"/>
		<xsl:text> #2}</xsl:text>
		<xsl:text> \newline </xsl:text>
		<xsl:text> \sffamily\scseries </xsl:text>
		<xsl:text> \begin{minipage}{\admlength}</xsl:text>
		<xsl:text> \vspace{1em}</xsl:text>
		<xsl:text> \parskip=0.5\baselineskip \advance\parskip by 0pt
		plus 2pt\leftskip=\leftskiplength</xsl:text>
		<xsl:text>} </xsl:text>
		
		<xsl:text>{ </xsl:text>
		<xsl:text>\vspace{1em} </xsl:text>
		<xsl:text> \end{minipage}</xsl:text>
		<xsl:text> \rule{\textwidth}{.5pt}\vspace{1em} </xsl:text>
		<xsl:text> \endadmminipage </xsl:text>
		<xsl:text> \par </xsl:text>
		<xsl:text>}</xsl:text>
	</xsl:param>
</xsl:stylesheet>

