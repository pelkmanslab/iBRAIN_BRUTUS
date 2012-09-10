<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dt="http://xsltsl.org/date-time" xmlns:str="http://xsltsl.org/string">
	<xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes"/>
	<xsl:include href="date-time.xsl"/>
	<xsl:include href="string.xsl"/>
	<xsl:template match="/">
		<html style="height: auto; background-image: url('/img/border_bottom.png'); background-repeat: repeat-x;">
			<HEAD>
				<TITLE>iBRAIN project overview</TITLE>
				<SCRIPT LANGUAGE="JavaScript" SRC="/js/ibrain3.js"/>
				<LINK REL="stylesheet" HREF="/css/ibrain3.css"/>
			</HEAD>
			<body style="height: auto; margin-left: 25px;" onload="checkIfPageIsStillFresh();">
				<xsl:apply-templates select="ibrain_log/ibrain_meta/error"/>				
				<h2 class="Message">Please select a project from the <i>Project list</i></h2>
				updated at 
				<xsl:call-template name="dt:format-date-time">
					<xsl:with-param name="year">20<xsl:value-of select="substring(/ibrain_log/ibrain_meta/start,1,2)"/>
					</xsl:with-param>
					<xsl:with-param name="month">
						<xsl:value-of select="substring(/ibrain_log/ibrain_meta/start,3,2)"/>
					</xsl:with-param>
					<xsl:with-param name="day">
						<xsl:value-of select="substring(/ibrain_log/ibrain_meta/start,5,2)"/>
					</xsl:with-param>
					<xsl:with-param name="hour">
						<xsl:value-of select="substring(/ibrain_log/ibrain_meta/start,8,2)"/>
					</xsl:with-param>
					<xsl:with-param name="minute">
						<xsl:value-of select="substring(/ibrain_log/ibrain_meta/start,11,2)"/>
					</xsl:with-param>
					<xsl:with-param name="second">
						<xsl:value-of select="substring(/ibrain_log/ibrain_meta/start,14,2)"/>
					</xsl:with-param>
					<xsl:with-param name="time-zon"/>
					<xsl:with-param name="format" select="'%H:%M, on %A %d %B %Y'"/>
				</xsl:call-template><br/>			
				<img alt="" src="/img/page_div_margins.jpg" width="90%" height="5"/>
				<br/><br/>
				<div id="reportStalePage2" class="reportStalePage2Offline">
					<table border="0" cellpadding="0" cellspacing="2" width="400px">
						<tbody>
							<tr>
								<td><h4>Alert: iBRAIN is offline</h4></td>
							</tr>
							<tr>
								<td valign="top" style="font-size: 12px;">
									It seems iBRAIN has last been updated long ago <div id="reportStalePage" style="font-size: 12px; font-weight: bold; display: none;">
										<xsl:call-template name="dt:format-date-time">
											<xsl:with-param name="year">20<xsl:value-of select="substring(/ibrain_log/ibrain_meta/start,1,2)"/>
											</xsl:with-param>
											<xsl:with-param name="month">
												<xsl:value-of select="substring(/ibrain_log/ibrain_meta/start,3,2)"/>
											</xsl:with-param>
											<xsl:with-param name="day">
												<xsl:value-of select="substring(/ibrain_log/ibrain_meta/start,5,2)"/>
											</xsl:with-param>
											<xsl:with-param name="hour">
												<xsl:value-of select="substring(/ibrain_log/ibrain_meta/start,8,2)"/>
											</xsl:with-param>
											<xsl:with-param name="minute">
												<xsl:value-of select="substring(/ibrain_log/ibrain_meta/start,11,2)"/>
											</xsl:with-param>
											<xsl:with-param name="second">
												<xsl:value-of select="substring(/ibrain_log/ibrain_meta/start,14,2)"/>
											</xsl:with-param>
											<xsl:with-param name="time-zon"/>
											<xsl:with-param name="format" select="'%a, %d %b %Y %H:%M:%S GMT+0100'"/>
										</xsl:call-template>
									</div>, which indicates that something is wrong. A simple check list:
									<ul>
										<li>Is Brutus up-and-running? (<a href="http://www.clusterwiki.ethz.ch/brutus/Brutus_wiki" target="_blank">see the Brutus Wiki</a>)</li>
										<li>Is the NAS up-and-running? </li>
										<li><del>Is the iBRAIN-laptop up-and-running?</del></li>
										<li>Is <del>Berend</del> Yauhen up-and-running? </li>
									</ul>
									If any of these requirements is not met, iBRAIN will most likely fail.
								</td>
							</tr>
						</tbody>
					</table>
				</div>				
			
				<div style="float: left; border: 1px #dddddd solid; background-color: white; margin: 5px; margin-right: 10px;">
					<table border="0" cellpadding="0" cellspacing="2">
						<tbody>
							<tr>
								<td><h4>Recently running and pending jobs</h4></td>
							</tr>
							<tr>
								<td valign="top">
									<img alt="recent job history" src="../jobs_latest.png"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div style="float: left; border: 1px #dddddd solid; background-color: white; margin: 5px; margin-right: 10px;">
					<table border="0" cellpadding="0" cellspacing="2">
						<tbody>
							<tr>
								<td><h4>History of running and pending jobs</h4></td>
							</tr>
							<tr>
								<td valign="top">
									<img alt="full job history" src="../jobs.png"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div><!-- br style="clear: both;"/ -->
				<div style="float: left; border: 1px #dddddd solid; background-color: white; margin: 5px; margin-right: 10px;">
					<table border="0" cellpadding="0" cellspacing="2">
						<tbody>
							<tr>
								<xsl:choose>
									<xsl:when test="number(/ibrain_log/ibrain_meta/share_2_free) &lt; 150000000">
										<td><h4 style="color: red;">WARNING: share-2-$ disk usage: <xsl:value-of select="round(number(/ibrain_log/ibrain_meta/share_2_free) div 1048576)"/>GB free</h4></td>										
									</xsl:when>
									<xsl:otherwise>
										<td><h4>share-2-$ disk usage: <xsl:value-of select="round(number(/ibrain_log/ibrain_meta/share_2_free) div 1048576)"/>GB free</h4></td>
									</xsl:otherwise>
								</xsl:choose>
							</tr>
							<tr>
								<td valign="top">
									<img alt="recent job history" src="../disk1.png"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div style="float: left; border: 1px #dddddd solid; background-color: white; margin: 5px; margin-right: 10px;">
					<table border="0" cellpadding="0" cellspacing="2">
						<tbody>
							<tr>
								<xsl:choose>
									<xsl:when test="number(/ibrain_log/ibrain_meta/share_3_free) &lt; 150000000">
										<td><h4 style="color: red;">WARNING: share-3-$ disk usage: <xsl:value-of select="round(number(/ibrain_log/ibrain_meta/share_3_free) div 1048576)"/>GB free</h4></td>										
									</xsl:when>
									<xsl:otherwise>
										<td><h4>share-3-$ disk usage: <xsl:value-of select="round(number(/ibrain_log/ibrain_meta/share_3_free) div 1048576)"/>GB free</h4></td>
									</xsl:otherwise>
								</xsl:choose>
							</tr>
							<tr>
								<td valign="top">
									<img alt="recent job history" src="../disk2.png"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div>				
				<xsl:apply-templates select="ibrain_log/ibrain_meta/job_overview"/>
				<xsl:apply-templates select="ibrain_log/ibrain_meta/latest_result_files"/>
				<xsl:apply-templates select="ibrain_log/ibrain_meta"/>
			</body>
		</html>
	</xsl:template>
	<!-- simple table displaying what is currently running -->
	<xsl:template match="job_overview">
		<div style="float: left; border: 1px #dddddd solid;  background-color: white; margin: 5px; margin-right: 10px;">
			<table cellpadding="0" cellspacing="2" border="0">
				<tbody>
				<tr>
					<th colspan="4">Overview of current jobs on Brutus cluster</th>
				</tr>
				<tr>
					<td align="right">all</td>
					<td align="right">running</td>
					<td align="left"><img alt="" src="/img/empty.gif" width="1" height="1"/></td>
					<td align="left">type</td>
				</tr>
					<xsl:for-each select="all/job">
						<xsl:sort data-type="number" order="descending" select="@count"/>
						<tr style="border-top: 1px #555555; ">
							<td align="right" style="font-size: 11px;">
								<xsl:value-of select="normalize-space(@count)"/>
							</td>
							<td align="right" style="font-size: 11px;">
								<!-- look up how many instances of the current job name are running -->
								<xsl:choose>
									<xsl:when test="//running/job[@name = current()/@name]/@count">
										<strong><xsl:value-of select="//running/job[@name = current()/@name]/@count"/></strong>
									</xsl:when>
									<xsl:otherwise>
										0
									</xsl:otherwise>
								</xsl:choose>
							</td>
							<td align="center">
								<xsl:choose>
									<xsl:when test="@type = 'shell_script'">
										<img alt="script" src="/img/console.png" width="16" height="16"/>
									</xsl:when>
									<xsl:when test="@type = 'matlab'">
										<img alt="matlab" src="/img/matlab_file.png" width="16" height="16"/>
									</xsl:when>
								</xsl:choose>
							</td>
							<td align="left" style="font-size: 11px;">
								<xsl:value-of select="normalize-space(@name)"/>
							</td>
						</tr>

						<!-- xsl:if test="string-length(normalize-space(node())) &lt; 1000">
							<xsl:value-of select="normalize-space(node())"/>
						</xsl:if>
						<xsl:if test="string-length(normalize-space(node())) &gt; 999">
							<xsl:value-of select="substring(normalize-space(node()), 1, 1000)"/><xsl:text> </xsl:text> <strong> ... (Message truncated to 1000 characters, complain if you want to see it all).</strong>
						</xsl:if -->

						<xsl:for-each select="job_count_per_user">
							<xsl:sort data-type="number" order="descending" select="@count"/>
							<tr>
								<td align="right" style="font-size: 10px; color: #555555; ">
									<xsl:value-of select="normalize-space(@count)"/>
								</td>
								<td align="right" style="font-size: 10px; color: #555555; ">
									<!-- look up how many instances of the current job name are running -->
									<xsl:choose>
										<xsl:when test="//running/job[@name = current()/../@name]/job_count_per_user[@username = current()/@username]/@count">
											<strong><xsl:value-of select="//running/job[@name = current()/../@name]/job_count_per_user[@username = current()/@username]/@count"/></strong>
										</xsl:when>
										<xsl:otherwise>
											0
										</xsl:otherwise>
									</xsl:choose>
								</td>
								<td align="center">
									<img alt="" src="/img/empty.gif" width="1" height="1"/>
								</td>
								<td align="left" style="font-size: 10px; color: #555555; padding-left: 10px;">
									<xsl:value-of select="normalize-space(@username)"/>
								</td>
							</tr>
						</xsl:for-each>	
						
					</xsl:for-each>					
				</tbody>
			</table>
		</div>
	</xsl:template>
	<xsl:template match="latest_result_files">
		<div style="float: left; border: 1px #dddddd solid;  background-color: white; margin: 5px; margin-right: 10px;">
			<table cellpadding="0" cellspacing="2" border="0">
				<tbody>
					<tr>
						<th align="left" colspan="2">Latest result files</th>
					</tr>
					<xsl:for-each select="result_file">
						<tr>
							<td align="left" style="font-size: 10px;"><xsl:value-of select="substring(@date_last_modified,3,17)"/></td>
							<td align="left" style="font-size: 10px;">
								<a href="{normalize-space(node())}">/<xsl:value-of select="substring-after(normalize-space(node()),'/Data/')"/></a>
							</td>
						</tr>
					</xsl:for-each>                 
				</tbody>
			</table>
		</div>
	</xsl:template>
	<xsl:template match="error">
		<div style="border: 2px #666666 solid; margin: 15px; background-color: red;">
			<table cellpadding="0" cellspacing="2" border="0">
				<tbody>
					<tr>
						<td align="center"><h1>Fatal error in iBRAIN</h1></td>
					</tr>
					<tr>
						<td align="left"><h3><xsl:value-of select="node()"/></h3></td>
					</tr>
					<tr>
						<td align="left" style="background-color: white; font-size: 10px;"><xsl:value-of select="./output/node()"/></td>
					</tr>					
				</tbody>
			</table>
		</div>
	</xsl:template>		
	<xsl:template match="ibrain_meta">
		<div style="float: left; border: 1px #dddddd solid; background-color: white; margin: 5px; margin-right: 10px;">
			<table cellpadding="0" cellspacing="2" border="0">
				<tbody>
				<tr>
					<td colspan="3" align="left">iBRAIN meta information</td>
				</tr>
					<xsl:for-each select="*[not(name()='job_overview') and not(name()='latest_result_files') and not(name()='running') and not(name()='job') and not(name()='job_count_per_user')]">
						<tr>
							<td align="right" style="font-size: 10px; color: #555555;"><xsl:value-of select="name()"/></td>
							<td align="center" style="font-size: 10px; color: #555555;">=</td>
							<td align="left" style="font-size: 10px; color: #555555;"><xsl:value-of select="node()"/></td>				
						</tr>
				</xsl:for-each>					
				</tbody>
			</table>
		</div>
	</xsl:template>	
	<!-- unmatched elements -->
	<xsl:template match="*">
		<!-- do nothing with unmatched elements -->
	</xsl:template>
</xsl:stylesheet>
